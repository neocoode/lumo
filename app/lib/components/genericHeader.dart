import 'package:flutter/material.dart';

class GenericHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onUserPressed;
  final IconData? userIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const GenericHeader({
    super.key,
    required this.title,
    this.onBackPressed,
    this.onUserPressed,
    this.userIcon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = backgroundColor ?? Colors.transparent;
    final defaultTextColor = textColor ?? Colors.white;
    final defaultIconColor = iconColor ?? Colors.white;
    final defaultUserIcon = userIcon ?? Icons.person_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: defaultBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão voltar
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: defaultIconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: defaultIconColor,
                size: 20,
              ),
            ),
          ),
          
          // Título centralizado
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: defaultTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Ícone de usuário
          GestureDetector(
            onTap: onUserPressed,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: defaultIconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                defaultUserIcon,
                color: defaultIconColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
