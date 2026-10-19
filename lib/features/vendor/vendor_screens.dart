import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/states.dart';
import '../../data/models/enums.dart';
import '../../data/models/ops.dart';
import '../../data/models/product.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../staff/staff_design.dart';
import '../staff/staff_widgets.dart';

/// Own listings, own orders (with the buyer contact only a vendor may see) and
/// ratings in one call, so the dashboard numbers cannot disagree with the lists
/// behind them (task F8).
final vendorDeskProvider = FutureProvider<VendorDesk>(
  (ref) async => ref.watch(vendorRepositoryProvider).desk(),
);

/// Product list: stock and price at a glance, with the two things a vendor
/// actually does all day — change stock and edit a listing — one tap away.
class VendorProductsScreen extends ConsumerStatefulWidget {
  const VendorProductsScreen({super.key});

  @override
  ConsumerState<VendorProductsScreen> createState() =>
      _VendorProductsScreenState();
}

enum _StockFilter { all, low, out }

class _VendorProductsScreenState extends ConsumerState<VendorProductsScreen> {
  _StockFilter _filter = _StockFilter.all;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final desk = ref.watch(vendorDeskProvider);

    return AppScreen(
      title: l.navProducts,
      showBack: false,
      header: StaffTabHeader(
        title: l.navProducts,
        subtitle: l.vendorProductsSubtitle,
        icon: Icons.inventory_2_rounded,
        actions: [
          IconButton(
            tooltip: l.vendorAddProduct,
            onPressed: () => _openEditor(null),
            icon: const Icon(Icons.add_rounded),
          ),
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () => ref.invalidate(vendorDeskProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: desk.when(
        loading: () => const LoadingState(rows: 4),
        error: (error, _) => ErrorState(
          body: staffErrorText(error, l),
          onRetry: () => ref.invalidate(vendorDeskProvider),
        ),
        data: (data) {
          final products = switch (_filter) {
            _StockFilter.all => data.products,
            _StockFilter.low => data.lowStock,
            _StockFilter.out => data.outOfStock,
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OpsFilters(
                labels: [
                  l.filterAll,
                  l.vendorLowStock,
                  l.vendorOutOfStock,
                ],
                index: _filter.index,
                onChanged: (i) =>
                    setState(() => _filter = _StockFilter.values[i]),
              ),
              const SizedBox(height: Space.md),
              if (products.isEmpty)
                EmptyState(
                  icon: Icons.inventory_2_rounded,
                  title: l.vendorNoProducts,
                  body: l.vendorNoProductsBody,
                  actionLabel: l.vendorAddProduct,
                  onAction: () => _openEditor(null),
                )
              else
                for (final product in products)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xs),
                    child: _ProductCard(
                      product: product,
                      onEdit: () => _openEditor(product),
                      onDelete: () => _delete(product),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openEditor(Product? product) async {
    final l = AppL10n.of(context);
    final saved = await showStaffSheet<bool>(
      context,
      title: product == null ? l.vendorAddProduct : l.vendorEditProduct,
      child: _ProductSheet(product: product),
    );
    if (saved == true && mounted) {
      ref.invalidate(vendorDeskProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.vendorProductSaved)),
      );
    }
  }

  Future<void> _delete(Product product) async {
    final l = AppL10n.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.vendorDeleteTitle),
        content: Text(l.vendorDeleteConfirm(product.label(locale))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(vendorRepositoryProvider).deleteProduct(product.id);
      ref.invalidate(vendorDeskProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.vendorProductDeleted)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(staffErrorText(error, l))),
        );
      }
    }
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final f = AppFormat.of(context);
    final p = context.palette;
    final low = product.stock > 0 && product.stock <= 10;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductThumb(product: product),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.label(locale),
                      style: context.texts.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Space.xxs),
                    Wrap(
                      spacing: Space.xs,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (product.stock == 0)
                          OpsPill(
                            label: l.vendorOutOfStock,
                            tone: OpsTone.danger,
                          )
                        else if (low)
                          OpsPill(
                            label: l.vendorLowStock,
                            tone: OpsTone.warning,
                          ),
                        Text(
                          '${l.productCategory(product.category)} · '
                          '${f.taka(product.price)}',
                          style: context.texts.bodySmall
                              ?.copyWith(color: p.onSurfaceMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.xs),
          // The stepper and the two actions do not fit on one 348dp row beside
          // each other, so they wrap onto their own lines instead of squeezing
          // the stock number out of the card.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Space.sm,
            runSpacing: Space.xs,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StockButton(
                    icon: Icons.remove_rounded,
                    tooltip: l.vendorStockMinus,
                    onPressed: product.stock == 0
                        ? null
                        : () => _setStock(context, ref, product.stock - 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.xxs),
                    child: Text(
                      l.vendorStockLeft(f.number(product.stock)),
                      style: context.texts.titleSmall,
                    ),
                  ),
                  _StockButton(
                    icon: Icons.add_rounded,
                    tooltip: l.vendorStockPlus,
                    onPressed: () => _setStock(context, ref, product.stock + 1),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: Sizes.iconInline),
                    label: Text(l.actionEdit),
                  ),
                  IconButton(
                    tooltip: l.actionDelete,
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline_rounded, color: p.error),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _setStock(
    BuildContext context,
    WidgetRef ref,
    int next,
  ) async {
    final l = AppL10n.of(context);
    try {
      await ref.read(vendorRepositoryProvider).setStock(product.id, next);
      ref.invalidate(vendorDeskProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(staffErrorText(error, l))),
        );
      }
    }
  }
}

/// The listing photo, or a painted tile when there is none. Network images
/// fail politely: the seller still sees the product's category glyph instead of
/// a broken-image box.
class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    final p = context.palette;
    final icon = switch (product.category) {
      'seed' => Icons.grain_rounded,
      'fertilizer' => Icons.compost_rounded,
      'pesticide' => Icons.pest_control_rounded,
      'fungicide' => Icons.sanitizer_rounded,
      'equipment' => Icons.agriculture_rounded,
      _ => Icons.inventory_2_rounded,
    };

    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.primaryContainer,
        borderRadius: Radii.fieldAll,
      ),
      child: Icon(icon, size: size * 0.45, color: p.onPrimaryContainer),
    );

    final url = product.imageUrl;
    if (url == null || url.trim().isEmpty) return fallback;

    return ClipRRect(
      borderRadius: Radii.fieldAll,
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

class _StockButton extends StatelessWidget {
  const _StockButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // The design system's 56dp floor applies to anything a thumb has to hit, so
    // the stock stepper is padded up rather than relying on IconButton's 48.
    return SizedBox(
      width: Sizes.minTapTarget,
      height: Sizes.minTapTarget,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

/// The optional listing photo. A link today, an upload when storage exists —
/// the preview is the point: a vendor can see what the farmer will see.
class _PhotoField extends StatelessWidget {
  const _PhotoField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final url = value.text.trim();
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: Radii.fieldAll,
                child: Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  color: p.surfaceSunken,
                  child: url.isEmpty
                      ? Icon(
                          Icons.add_photo_alternate_outlined,
                          color: p.onSurfaceMuted,
                        )
                      : Image.network(
                          url,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.image_not_supported_outlined,
                            color: p.onSurfaceMuted,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: l.vendorPhotoLink,
                        hintText: l.vendorPhotoHint,
                        helperText: l.vendorPhotoSoon,
                        helperMaxLines: 2,
                      ),
                    ),
                    if (url.isNotEmpty)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: controller.clear,
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: Text(l.vendorPhotoRemove),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Add/edit a listing. One form for both: a vendor editing a product expects the
/// same fields as when they created it.
class _ProductSheet extends ConsumerStatefulWidget {
  const _ProductSheet({this.product});

  final Product? product;

  @override
  ConsumerState<_ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends ConsumerState<_ProductSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.product?.name ?? '');
  late final TextEditingController _nameBn =
      TextEditingController(text: widget.product?.nameBn ?? '');
  late final TextEditingController _price = TextEditingController(
    text: widget.product == null ? '' : widget.product!.price.toString(),
  );
  late final TextEditingController _stock = TextEditingController(
    text: widget.product == null ? '0' : widget.product!.stock.toString(),
  );
  late final TextEditingController _description =
      TextEditingController(text: widget.product?.description ?? '');
  late final TextEditingController _image =
      TextEditingController(text: widget.product?.imageUrl ?? '');
  late String _category = widget.product?.category ?? 'seed';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _nameBn.dispose();
    _price.dispose();
    _stock.dispose();
    _description.dispose();
    _image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          StaffField(
            controller: _name,
            label: l.vendorProductName,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l.vendorFieldRequired : null,
          ),
          StaffField(controller: _nameBn, label: l.vendorProductNameBn),
          _PhotoField(controller: _image),
          StaffChoice<String>(
            label: l.vendorProductCategory,
            selected: _category,
            options: [
              for (final c in kProductCategories)
                (value: c, label: l.productCategory(c)),
            ],
            onChanged: (value) => setState(() => _category = value),
          ),
          StaffField(
            controller: _price,
            label: l.vendorProductPrice,
            keyboardType: TextInputType.number,
            validator: (v) {
              final value = int.tryParse((v ?? '').trim());
              if (value == null || value <= 0) return l.vendorPriceInvalid;
              return null;
            },
          ),
          StaffField(
            controller: _stock,
            label: l.vendorProductStock,
            keyboardType: TextInputType.number,
            validator: (v) {
              final value = int.tryParse((v ?? '').trim());
              if (value == null || value < 0) return l.vendorStockInvalid;
              return null;
            },
          ),
          StaffField(
            controller: _description,
            label: l.vendorProductDescription,
            maxLines: 3,
          ),
          const SizedBox(height: Space.xs),
          AppButton(
            label: l.actionSave,
            isLoading: _saving,
            onPressed: _save,
          ),
          const SizedBox(height: Space.xs),
          AppButton(
            label: l.actionCancel,
            tone: AppButtonTone.quiet,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l = AppL10n.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(vendorRepositoryProvider).saveProduct(
            VendorProductDraft(
              id: widget.product?.id,
              name: _name.text.trim(),
              nameBn: _nameBn.text.trim().isEmpty ? null : _nameBn.text.trim(),
              category: _category,
              price: int.parse(_price.text.trim()),
              stock: int.parse(_stock.text.trim()),
              imageUrl: _image.text.trim().isEmpty
                  ? null
                  : _image.text.trim(),
              description: _description.text.trim().isEmpty
                  ? null
                  : _description.text.trim(),
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(staffErrorText(error, l))),
      );
    }
  }
}

/// The vendor's order queue. Only valid transitions are offered, so the UI can
/// never attempt one the server would refuse (API_SPEC §7).
class VendorOrdersScreen extends ConsumerStatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  ConsumerState<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends ConsumerState<VendorOrdersScreen> {
  int _filter = 0;

  static const List<OrderStatus?> _filters = [
    null,
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final desk = ref.watch(vendorDeskProvider);

    return AppScreen(
      title: l.navOrders,
      showBack: false,
      header: StaffTabHeader(
        title: l.navOrders,
        subtitle: l.vendorOrdersSubtitle,
        icon: Icons.receipt_long_rounded,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () => ref.invalidate(vendorDeskProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: desk.when(
        loading: () => const LoadingState(rows: 4),
        error: (error, _) => ErrorState(
          body: staffErrorText(error, l),
          onRetry: () => ref.invalidate(vendorDeskProvider),
        ),
        data: (data) {
          final wanted = _filters[_filter];
          final orders = wanted == null
              ? data.orders
              : data.orders
                  .where((o) => o.order.status == wanted)
                  .toList(growable: false);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OpsFilters(
                labels: [
                  l.filterAll,
                  l.orderStatusPending,
                  l.orderStatusConfirmed,
                  l.orderStatusShipped,
                  l.orderStatusDelivered,
                ],
                index: _filter,
                onChanged: (i) => setState(() => _filter = i),
              ),
              const SizedBox(height: Space.md),
              if (orders.isEmpty)
                EmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: l.vendorNoOrders,
                  body: l.vendorNoOrdersBody,
                )
              else
                for (final order in orders)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xs),
                    child: _VendorOrderCard(order: order),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _VendorOrderCard extends ConsumerWidget {
  const _VendorOrderCard({required this.order});

  final VendorOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Space.xs,
            runSpacing: Space.xxs,
            children: [
              Text(order.order.orderNo, style: context.texts.titleSmall),
              OpsPill(
                label: order.order.status.label(l),
                tone: _orderTone(order.order.status),
              ),
            ],
          ),
          const SizedBox(height: Space.xxs),
          Text(
            '${order.buyerName} · ${order.buyerMobile}',
            style: context.texts.bodySmall,
          ),
          Text(
            '${order.buyerDistrict} · ${f.dateTime(order.order.createdAt)}',
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
          ),
          if (order.note != null) ...[
            const SizedBox(height: Space.xxs),
            Text(order.note!, style: context.texts.bodySmall),
          ],
          const Divider(),
          for (final item in order.order.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '${f.number(item.quantity)} × ',
                    style: context.texts.bodySmall
                        ?.copyWith(color: p.onSurfaceMuted),
                  ),
                  Expanded(
                    child: Text(
                      item.name,
                      style: context.texts.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(f.taka(item.subtotal), style: context.texts.bodySmall),
                ],
              ),
            ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: Text(l.orderTotal, style: context.texts.bodyMedium),
              ),
              const SizedBox(width: Space.xs),
              Text(
                f.taka(order.order.totalAmount),
                style: context.texts.titleSmall,
              ),
            ],
          ),
          if (order.nextActions.isNotEmpty) ...[
            const SizedBox(height: Space.xs),
            Wrap(
              spacing: Space.xs,
              runSpacing: Space.xs,
              children: [
                for (final status in order.nextActions)
                  _TransitionButton(
                    // Keyed by status so the next step gets a fresh, idle button
                    // instead of reusing the state of the one just pressed.
                    key: ValueKey('${order.order.id}-${status.wire}'),
                    order: order,
                    status: status,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TransitionButton extends ConsumerStatefulWidget {
  const _TransitionButton({
    super.key,
    required this.order,
    required this.status,
  });

  final VendorOrder order;
  final OrderStatus status;

  @override
  ConsumerState<_TransitionButton> createState() => _TransitionButtonState();
}

OpsTone _orderTone(OrderStatus status) => switch (status) {
      OrderStatus.delivered => OpsTone.success,
      OrderStatus.rejected || OrderStatus.cancelled => OpsTone.danger,
      OrderStatus.pending => OpsTone.warning,
      _ => OpsTone.primary,
    };

class _TransitionButtonState extends ConsumerState<_TransitionButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final isReject = widget.status == OrderStatus.rejected;

    return AppButton(
      label: _label(l),
      // Rejecting is destructive and asks for a reason; everything else is the
      // forward step and is styled as such.
      tone: isReject ? AppButtonTone.danger : AppButtonTone.secondary,
      expand: false,
      isLoading: _busy,
      onPressed: _apply,
    );
  }

  String _label(AppL10n l) => switch (widget.status) {
        OrderStatus.confirmed => l.vendorAcceptOrder,
        OrderStatus.rejected => l.vendorRejectOrder,
        OrderStatus.shipped => l.vendorShipOrder,
        OrderStatus.delivered => l.vendorDeliverOrder,
        _ => widget.status.label(l),
      };

  Future<void> _apply() async {
    final l = AppL10n.of(context);
    String? reason;
    if (widget.status == OrderStatus.rejected) {
      reason = await askStaffReason(
        context,
        title: l.vendorRejectTitle,
        hint: l.vendorRejectHint,
        actionLabel: l.vendorRejectOrder,
      );
      if (reason == null) return;
    }

    setState(() => _busy = true);
    try {
      await ref
          .read(vendorRepositoryProvider)
          .updateOrderStatus(widget.order.order.id, widget.status, reason: reason);
      ref.invalidate(vendorDeskProvider);
      if (mounted) {
        // Back to idle before the refreshed list lands, so a step that is still
        // offered (delivering after shipping) does not keep its spinner.
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.vendorOrderUpdated)),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(staffErrorText(error, l))),
        );
      }
    }
  }
}
