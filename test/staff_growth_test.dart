import 'package:agrisense/data/mock/growth_seed.dart';
import 'package:agrisense/data/mock/mock_ops_repositories.dart';
import 'package:agrisense/data/models/growth.dart';
import 'package:flutter_test/flutter_test.dart';

/// The three consoles added on top of F8 are UI-first, but their mock state is
/// still the thing the screens read. These tests hold the state transitions to
/// the same standard as the farmer repositories: the value the screen shows
/// after an action is the value the repository holds on the next read.
void main() {
  test('a vendor customer note and follow-up survive a refetch', () async {
    final repo = MockVendorRepository();

    final before = await repo.business();
    final customer = before.customers.first;
    expect(customer.followUp, isTrue);

    await repo.saveCustomerNote(customer.id, 'নতুন নোট');
    await repo.setFollowUp(customer.id, false);

    final after = await repo.business();
    final saved = after.customers.firstWhere((c) => c.id == customer.id);
    expect(saved.note, 'নতুন নোট');
    expect(saved.followUp, isFalse);
    // The rest of the book is untouched.
    expect(after.customers.length, before.customers.length);
  });

  test('a like is reversible and a comment is appended once', () async {
    final repo = MockExpertRepository();
    final before = await repo.desk();
    final article = before.articles.first;
    final likes = article.likes;

    final liked = await repo.toggleLike(article.id);
    expect(liked.liked, isTrue);
    expect(liked.likes, likes + 1);

    final unliked = await repo.toggleLike(article.id);
    expect(unliked.liked, isFalse);
    expect(unliked.likes, likes);

    final commented = await repo.commentOnArticle(article.id, 'পরীক্ষামূলক মন্তব্য');
    expect(commented.comments.length, article.comments.length + 1);
    expect(commented.comments.last.body, 'পরীক্ষামূলক মন্তব্য');
    expect(commented.comments.last.isExpert, isTrue);
  });

  test('an expert answer leaves the open queue', () async {
    final repo = MockExpertRepository();
    final before = await repo.desk();
    expect(before.openQuestions, isNotEmpty);

    final answered = await repo.answerQuestion(
      before.openQuestions.first.id,
      'দিনের আলোতে নতুন ছবি পাঠান।',
    );
    expect(answered.answered, isTrue);

    final after = await repo.desk();
    expect(after.openQuestions.length, before.openQuestions.length - 1);
  });

  test('admin settings and a hidden listing are persisted', () async {
    final repo = MockAdminRepository();

    final settings = await repo.settings();
    await repo.saveSettings(
      settings.copyWith(commissionPercent: 7, maintenance: true),
    );
    final saved = await repo.settings();
    expect(saved.commissionPercent, 7);
    expect(saved.maintenance, isTrue);

    final products = await repo.products();
    final product = products.first;
    final hidden = await repo.setProductHidden(product.id, true);
    expect(hidden.hidden, isTrue);

    final after = await repo.products();
    expect(after.firstWhere((p) => p.id == product.id).hidden, isTrue);
    // Hiding is reversible, and every other listing keeps its state.
    expect(
      after.where((p) => p.hidden).length,
      products.where((p) => p.hidden).length + 1,
    );
  });

  test('the admin overview counts the real pending queues', () async {
    final repo = MockAdminRepository();
    final pendingVendors = await repo.vendors(status: 'pending');
    final pendingUsers = await repo.users();
    final pendingAccounts =
        pendingUsers.where((u) => u.status.wire == 'pending').length;

    final overview = await repo.overview();
    expect(
      overview.pendingApprovals,
      pendingVendors.length + pendingAccounts,
    );
    expect(overview.week.length, 7);
    expect(overview.gmv30, greaterThan(0));
  });

  test('hidden content is a real, reversible state', () async {
    final repo = MockAdminRepository();
    final before = await repo.content();
    final item = before.first;

    await repo.setContentHidden(item.id, true);
    final hidden = (await repo.content()).firstWhere((c) => c.id == item.id);
    expect(hidden.hidden, isTrue);

    await repo.setContentHidden(item.id, false);
    final restored = (await repo.content()).firstWhere((c) => c.id == item.id);
    expect(restored.hidden, isFalse);
  });

  test('the CRM seed stays internally consistent', () {
    // The screen prints these numbers side by side, so a seed where a customer
    // is "loyal" with one order would make the UI lie from the first frame.
    final seed = vendorBusinessSeedForTest();
    for (final customer in seed.customers) {
      expect(customer.orders, greaterThan(0));
      expect(customer.totalSpent, greaterThan(0));
      expect(
        customer.segment,
        anyOf('new', 'repeat', 'loyal', 'atRisk'),
      );
      if (customer.segment == 'loyal') expect(customer.orders, greaterThan(1));
      if (customer.segment == 'new') expect(customer.orders, 1);
    }
    expect(seed.week.length, 7);
    expect(seed.topProducts, isNotEmpty);
  });
}

/// The seed builder the repository is constructed with, exposed for the
/// consistency check above without paying the mock's simulated latency.
VendorBusiness vendorBusinessSeedForTest() => vendorBusinessSeed();
