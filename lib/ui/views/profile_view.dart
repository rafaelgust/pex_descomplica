import 'package:flutter/material.dart';

import '../view_models/profile_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileViewModel _viewModel = ProfileViewModel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.onPrimary,
      child: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading) {
            return Center(child: const CircularProgressIndicator());
          }

          if (_viewModel.errorMessage?.isNotEmpty == true) {
            return Center(child: Text(_viewModel.errorMessage!));
          }

          final userData = _viewModel.userData;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              // Enable scrolling for longer profiles
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(
                            context,
                          ).primaryColor, // Use theme color for emphasis
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (userData != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              Image.network(
                                userData.urlAvatar,
                                fit: BoxFit.cover,
                              ).image,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Name: ${userData.fullName}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Role: ${userData.role.name}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Status: ${userData.verified == true ? 'Verificado' : 'Não Verificado'}',
                          style: TextStyle(
                            color: _getStatusColor(userData.verified),
                          ),
                        ),
                        Text(
                          'Email: ${userData.email}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Last Activity: ${userData.updated}',
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 24),
                      ],
                    )
                  else
                    const Text(
                      "No user data available.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(bool? status) {
    switch (status) {
      case true:
        return Colors.green;
      case false:
        return Colors.red;
      case null:
        return Colors.orange;
    }
  }
}
