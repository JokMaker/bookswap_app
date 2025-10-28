import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/constants.dart';
import 'browse_screen.dart';
import 'my_listings_screen.dart';
import 'chats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      BrowseScreen(),
      MyListingsScreen(),
      ChatsScreen(),
      SettingsScreen(),
    ];
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final swapProvider = Provider.of<SwapProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        bookProvider.listenToAllBooks();
        bookProvider.listenToUserBooks(authProvider.currentUser!.uid);
        swapProvider.listenToUserSwaps(authProvider.currentUser!.uid);
        swapProvider.listenToReceivedSwaps(authProvider.currentUser!.uid);
        chatProvider.listenToUserChatRooms(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: AppStrings.browseListings,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: AppStrings.myListings,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: AppStrings.chats,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppStrings.settings,
          ),
        ],
      ),
    );
  }
}