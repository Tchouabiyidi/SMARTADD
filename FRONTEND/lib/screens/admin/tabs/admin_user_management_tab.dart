import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../providers/admin_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_text_field.dart';

class AdminUserManagementTab extends StatefulWidget {
  const AdminUserManagementTab({super.key});

  @override
  State<AdminUserManagementTab> createState() => _AdminUserManagementTabState();
}

class _AdminUserManagementTabState extends State<AdminUserManagementTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUserRoleDialog(BuildContext context, User user) {
    UserRole selectedRole = user.role;
    final fullNameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Edit User (${user.id})'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Name',
                    controller: fullNameController,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Email',
                    hint: 'Email',
                    controller: emailController,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Phone',
                    hint: 'Phone',
                    controller: phoneController,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Assign User Role:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<UserRole>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem<UserRole>(
                        value: role,
                        child: Text(role.displayName),
                      );
                    }).toList(),
                    onChanged: (newRole) {
                      if (newRole != null) {
                        setModalState(() {
                          selectedRole = newRole;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updated = user.copyWith(
                    fullName: fullNameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    role: selectedRole,
                  );
                  final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                  await adminProvider.updateUser(updated);
                  if (context.mounted) {
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User role updated successfully!'), backgroundColor: AppTheme.successGreen),
                    );
                  }
                },
                child: const Text('Save User'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete User Account'),
        content: Text('Are you sure you want to permanently delete user "${user.fullName}" (${user.email})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              await adminProvider.deleteUser(user.id);
              if (context.mounted) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User account deleted.'), backgroundColor: AppTheme.errorRed),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final users = adminProvider.users;

    // Apply Filter & Search
    final query = _searchController.text.toLowerCase().trim();
    final filteredUsers = users.where((u) {
      final matchesQuery = u.fullName.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          u.id.toLowerCase().contains(query);

      if (_selectedRoleFilter == 'ALL') return matchesQuery;
      if (_selectedRoleFilter == 'ADVERTISER') return matchesQuery && u.role == UserRole.advertiser;
      if (_selectedRoleFilter == 'OWNER') return matchesQuery && u.role == UserRole.billboardOwner;
      if (_selectedRoleFilter == 'ADMIN') return matchesQuery && u.role == UserRole.admin;
      return matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('User Management Directory'),
      ),
      body: Column(
        children: [
          // Search & Filter Header Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextField(
                  label: '',
                  hint: 'Search by user name, email, or ID...',
                  controller: _searchController,
                  prefixIcon: const Icon(Icons.search_rounded),
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All Users (${users.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip('ADVERTISER', 'Advertisers (${adminProvider.advertisersCount})'),
                      const SizedBox(width: 8),
                      _buildFilterChip('OWNER', 'Billboard Owners (${adminProvider.ownersCount})'),
                      const SizedBox(width: 8),
                      _buildFilterChip('ADMIN', 'Admins'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // User Cards List
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(
                    child: Text('No users match the search criteria.', style: TextStyle(color: AppTheme.textSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];

                      Color roleColor;
                      switch (user.role) {
                        case UserRole.admin:
                          roleColor = Colors.purple;
                          break;
                        case UserRole.billboardOwner:
                          roleColor = AppTheme.primaryDark;
                          break;
                        case UserRole.advertiser:
                          roleColor = AppTheme.primaryBlue;
                          break;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          leading: CircleAvatar(
                            backgroundColor: roleColor.withValues(alpha: 0.1),
                            child: Icon(
                              user.role == UserRole.admin
                                  ? Icons.admin_panel_settings_rounded
                                  : user.role == UserRole.billboardOwner
                                      ? Icons.store_rounded
                                      : Icons.person_rounded,
                              color: roleColor,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: roleColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.role.displayName.toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('ID: ${user.id} • ${user.email}', style: const TextStyle(fontSize: 12)),
                              if (user.phone != null && user.phone!.isNotEmpty)
                                Text('Phone: ${user.phone}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.manage_accounts_rounded, color: AppTheme.primaryBlue),
                                tooltip: 'Edit User & Role',
                                onPressed: () => _showUserRoleDialog(context, user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed),
                                tooltip: 'Delete User',
                                onPressed: () => _confirmDeleteUser(context, user),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedRoleFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedRoleFilter = value;
          });
        }
      },
    );
  }
}
