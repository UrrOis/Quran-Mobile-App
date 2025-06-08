import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.12),
            blurRadius: 16,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          currentIndex: currentIndex,
          onTap: onTap,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/mosque.svg',
                width: 24,
                height: 24,
                color: currentIndex == 2 ? Colors.white : Colors.white70,
              ),
              label: 'Sholat',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/quran.svg',
                width: 24,
                height: 24,
                color: currentIndex == 3 ? Colors.white : Colors.white70,
              ),
              label: 'Quran',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Lokasi',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/wallet.svg',
                width: 24,
                height: 24,
                color: currentIndex == 5 ? Colors.white : Colors.white70,
              ),
              label: 'Uang',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
