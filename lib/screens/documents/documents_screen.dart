import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../data/models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';

/// Écran des documents (coffre-fort)
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  DocumentType? _filterType;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();

    // Filtrer les documents
    var filteredDocuments = provider.documents.where((doc) {
      if (_filterType != null && doc.type != _filterType) return false;
      if (_searchQuery.isNotEmpty) {
        return doc.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    // Documents à signer en premier
    final toSign = filteredDocuments.where((d) => d.requiresSignature && !d.isSigned).toList();
    final others = filteredDocuments.where((d) => !d.requiresSignature || d.isSigned).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Mes documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              // Télécharger tous
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Recherche et filtres
          Padding(
            padding: AppSpacing.screenPaddingHorizontal,
            child: Column(
              children: [
                AppSpacing.verticalGapMd,
                SearchInput(
                  controller: _searchController,
                  hint: 'Rechercher un document...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                  onClear: () => setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  }),
                ),
                AppSpacing.verticalGapMd,
                // Filtres par type
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'Tous',
                        isSelected: _filterType == null,
                        onTap: () => setState(() => _filterType = null),
                      ),
                      ...DocumentType.values.take(5).map((type) {
                        return _FilterChip(
                          label: type.label,
                          isSelected: _filterType == type,
                          onTap: () => setState(() => _filterType = type),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des documents
          Expanded(
            child: filteredDocuments.isEmpty
                ? const EmptyView(
                    title: 'Aucun document',
                    message: 'Vous n\'avez pas encore de document dans cette catégorie.',
                    icon: Icons.folder_open_outlined,
                  )
                : ListView(
                    padding: AppSpacing.screenPadding,
                    children: [
                      // Documents à signer
                      if (toSign.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'À signer',
                          count: toSign.length,
                          color: AppColors.warning,
                        ),
                        AppSpacing.verticalGapSm,
                        ...toSign.map((doc) => _DocumentTile(
                          document: doc,
                          onTap: () => _showDocumentDetails(context, doc),
                        )),
                        AppSpacing.verticalGapLg,
                      ],

                      // Autres documents
                      if (others.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'Tous les documents',
                          count: others.length,
                        ),
                        AppSpacing.verticalGapSm,
                        ...others.map((doc) => _DocumentTile(
                          document: doc,
                          onTap: () => _showDocumentDetails(context, doc),
                        )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showDocumentDetails(BuildContext context, DocumentModel document) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dividerLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                AppSpacing.verticalGapLg,

                // Icône du document
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: _getTypeColor(document.type).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTypeIcon(document.type),
                      color: _getTypeColor(document.type),
                      size: 32,
                    ),
                  ),
                ),
                AppSpacing.verticalGapMd,

                // Titre
                Center(
                  child: Text(
                    document.title,
                    style: AppTypography.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: AppSpacing.xs),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(document.type).withValues(alpha: 0.1),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Text(
                      document.type.label,
                      style: AppTypography.caption.copyWith(
                        color: _getTypeColor(document.type),
                      ),
                    ),
                  ),
                ),
                AppSpacing.verticalGapLg,

                // Détails
                AppCard(
                  child: Column(
                    children: [
                      _DetailRow(label: 'Date', value: dateFormat.format(document.date)),
                      const Divider(),
                      _DetailRow(label: 'Type', value: document.fileType.toUpperCase()),
                      const Divider(),
                      _DetailRow(label: 'Taille', value: document.fileSizeFormatted),
                      if (document.year != null) ...[
                        const Divider(),
                        _DetailRow(label: 'Année', value: document.year!),
                      ],
                    ],
                  ),
                ),
                AppSpacing.verticalGapLg,

                // Document à signer
                if (document.requiresSignature && !document.isSigned) ...[
                  AlertCard(
                    title: 'Signature requise',
                    message: 'Ce document nécessite votre signature électronique pour être validé.',
                    type: AlertCardType.warning,
                  ),
                  AppSpacing.verticalGapLg,
                  AppButton(
                    label: 'Signer le document',
                    leadingIcon: Icons.draw,
                    onPressed: () {
                      Navigator.pop(context);
                      _showSignatureDialog(context, document);
                    },
                  ),
                  AppSpacing.verticalGapMd,
                ],

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Aperçu',
                        variant: AppButtonVariant.outline,
                        leadingIcon: Icons.visibility_outlined,
                        onPressed: () {},
                      ),
                    ),
                    AppSpacing.horizontalGapMd,
                    Expanded(
                      child: AppButton(
                        label: 'Télécharger',
                        leadingIcon: Icons.download,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalGapMd,
                AppButton(
                  label: 'Partager',
                  variant: AppButtonVariant.secondary,
                  leadingIcon: Icons.share_outlined,
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSignatureDialog(BuildContext context, DocumentModel document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signer le document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'En signant ce document, vous confirmez avoir pris connaissance de son contenu et acceptez ses termes.',
            ),
            AppSpacing.verticalGapMd,
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: AppColors.success),
                  AppSpacing.horizontalGapSm,
                  const Expanded(
                    child: Text(
                      'Signature sécurisée et horodatée',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document signé avec succès !'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Signer'),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.statement:
        return AppColors.primary;
      case DocumentType.certificate:
        return AppColors.success;
      case DocumentType.contract:
        return AppColors.info;
      case DocumentType.notice:
        return AppColors.warning;
      case DocumentType.tax:
        return AppColors.accent;
      case DocumentType.correspondence:
        return AppColors.primaryLight;
      case DocumentType.other:
        return AppColors.textSecondaryLight;
    }
  }

  IconData _getTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.statement:
        return Icons.receipt_long;
      case DocumentType.certificate:
        return Icons.verified;
      case DocumentType.contract:
        return Icons.description;
      case DocumentType.notice:
        return Icons.info_outline;
      case DocumentType.tax:
        return Icons.account_balance;
      case DocumentType.correspondence:
        return Icons.mail_outline;
      case DocumentType.other:
        return Icons.insert_drive_file;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.backgroundLight,
            borderRadius: AppSpacing.borderRadiusFull,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color? color;

  const _SectionHeader({
    required this.title,
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          title,
          style: AppTypography.labelMedium.copyWith(
            color: color ??
                (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
          ),
        ),
        AppSpacing.horizontalGapSm,
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: Text(
            count.toString(),
            style: AppTypography.caption.copyWith(
              color: color ?? AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;

  const _DocumentTile({
    required this.document,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd/MM/yyyy');

    Color typeColor;
    IconData typeIcon;
    switch (document.type) {
      case DocumentType.statement:
        typeColor = AppColors.primary;
        typeIcon = Icons.receipt_long;
        break;
      case DocumentType.certificate:
        typeColor = AppColors.success;
        typeIcon = Icons.verified;
        break;
      case DocumentType.contract:
        typeColor = AppColors.info;
        typeIcon = Icons.description;
        break;
      case DocumentType.notice:
        typeColor = AppColors.warning;
        typeIcon = Icons.info_outline;
        break;
      case DocumentType.tax:
        typeColor = AppColors.accent;
        typeIcon = Icons.account_balance;
        break;
      default:
        typeColor = AppColors.textSecondaryLight;
        typeIcon = Icons.insert_drive_file;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(typeIcon, color: typeColor, size: 24),
            ),
            AppSpacing.horizontalGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          document.title,
                          style: AppTypography.labelMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (document.isNew)
                        Container(
                          margin: const EdgeInsets.only(left: AppSpacing.xs),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                          child: Text(
                            'Nouveau',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                    ],
                  ),
                  AppSpacing.verticalGapXxs,
                  Row(
                    children: [
                      Text(
                        dateFormat.format(document.date),
                        style: AppTypography.caption,
                      ),
                      AppSpacing.horizontalGapSm,
                      Text(
                        document.fileSizeFormatted,
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (document.requiresSignature && !document.isSigned)
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.draw,
                  color: AppColors.warningDark,
                  size: 16,
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
