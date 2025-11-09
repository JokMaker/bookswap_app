import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swap_provider.dart';
import '../../models/swap_model.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(AppStrings.settings),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            SizedBox(height: 24),
            _buildSwapOffersSection(),
            SizedBox(height: 24),
            _buildNotificationSection(),
            SizedBox(height: 24),
            _buildSignOutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          color: const Color(0xFF16213E),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFFFC107),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.currentUser?.displayName ?? 'User',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            authProvider.currentUser?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white60,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.verified,
                                size: 16,
                                color: authProvider.currentUser?.emailVerified == true
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                authProvider.currentUser?.emailVerified == true
                                    ? 'Email Verified'
                                    : 'Email Not Verified',
                                style: TextStyle(
                                  color: authProvider.currentUser?.emailVerified == true
                                      ? Colors.green
                                      : Colors.orange,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwapOffersSection() {
    return Consumer<SwapProvider>(
      builder: (context, swapProvider, child) {
        List<SwapModel> pendingOffers = swapProvider.receivedSwaps
            .where((swap) => swap.status == SwapStatus.pending)
            .toList();

        return Card(
          color: const Color(0xFF16213E),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Swap Offers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Sent',
                      swapProvider.userSwaps.length.toString(),
                      Icons.send,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Received',
                      swapProvider.receivedSwaps.length.toString(),
                      Icons.inbox,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Pending',
                      pendingOffers.length.toString(),
                      Icons.hourglass_empty,
                      Colors.orange,
                    ),
                  ],
                ),
                if (pendingOffers.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'Recent Pending Offers:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  ...pendingOffers.take(3).map((swap) => ListTile(
                    leading: Icon(Icons.book, color: Color(0xFFFFC107)),
                    title: Text(swap.bookTitle, style: TextStyle(color: Colors.white)),
                    subtitle: Text('From: ${swap.requesterEmail}', style: TextStyle(color: Colors.white60)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _updateSwapStatus(swap.id, SwapStatus.accepted),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _updateSwapStatus(swap.id, SwapStatus.rejected),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      color: const Color(0xFF16213E),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Preferences',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Push Notifications', style: TextStyle(color: Colors.white)),
              subtitle: Text('Receive notifications for new swap offers', style: TextStyle(color: Colors.white60)),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeThumbColor: const Color(0xFFFFC107),
            ),
            SwitchListTile(
              title: Text('Email Notifications', style: TextStyle(color: Colors.white)),
              subtitle: Text('Receive email updates for swap activities', style: TextStyle(color: Colors.white60)),
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
              activeThumbColor: const Color(0xFFFFC107),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutSection() {
    return Card(
      color: const Color(0xFF16213E),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: authProvider.isLoading
                      ? CircularProgressIndicator()
                      : Text(AppStrings.signOut),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateSwapStatus(String swapId, SwapStatus status) async {
    try {
      await Provider.of<SwapProvider>(context, listen: false)
          .updateSwapStatus(swapId, status);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Swap ${status.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating swap: ${e.toString()}')),
        );
      }
    }
  }

  void _signOut() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }
  }
}