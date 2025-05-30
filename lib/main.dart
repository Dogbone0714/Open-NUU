import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open NUU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'TW'),
        Locale('en', 'US'),
      ],
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1; // 預設選中首頁

  final List<Widget> _pages = [
    const ProfilePage(),
    const MainPage(),
    const MenuPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '個人資訊',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首頁',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            selectedIcon: Icon(Icons.menu),
            label: '選單',
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('個人資訊'),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            SizedBox(height: 16),
            Text('學生資訊'),
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open NUU'),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '歡迎使用 Open NUU',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '開始使用您的應用程式',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('選單'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.calendar_month_outlined),
            title: Text('課表查詢'),
          ),
          const ListTile(
            leading: Icon(Icons.score_outlined),
            title: Text('成績查詢'),
          ),
          const ListTile(
            leading: Icon(Icons.event_note_outlined),
            title: Text('行事曆'),
          ),
          const ListTile(
            leading: Icon(Icons.campaign_outlined),
            title: Text('校園公告'),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu_outlined),
            title: const Text('餐廳資訊'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RestaurantPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.departure_board_outlined),
            title: const Text('校車時刻'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BusSchedulePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('餐廳資訊'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '請選擇校區',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildCampusCard(
              context,
              '二坪山校區',
              Icons.location_city,
              const ErpingRestaurantPage(),
            ),
            const SizedBox(height: 16),
            _buildCampusCard(
              context,
              '八甲校區',
              Icons.apartment,
              const BajiaRestaurantPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '點擊查看詳細資訊',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErpingRestaurantPage extends StatelessWidget {
  const ErpingRestaurantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二坪山校區餐廳'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ErpingStudentRestaurantPage()),
              );
            },
            child: _buildRestaurantCard(
              '二坪學生餐廳',
              '位於紅夢樓一樓',
              [
                '營業時間：',
                '週一至週日',
                '早餐 06:30-13:00',
                '午餐 11:00-13:00',
                '晚餐 16:50-19:00',
                '',
                '點擊查看店家詳細資訊',
              ],
              Icons.restaurant,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LandscapeRestaurantPage()),
              );
            },
            child: _buildRestaurantCard(
              '景觀餐廳',
              '位於好漢坡旁',
              '營業時間：週一至週日 10:00-20:00\n點擊查看店家詳細資訊',
              Icons.food_bank,
            ),
          ),
          _buildRestaurantCard(
            '二坪 7-11',
            '位於操場旁、建築一館 1 F',
            '營業時間：週一至週日 07:00-23:00',
            Icons.store,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(
    String title,
    String location,
    dynamic hours,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              location,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (hours is String)
              Text(
                hours,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              )
            else if (hours is List<String>)
              ...hours.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      line,
                      style: TextStyle(
                        fontSize: 14,
                        color: line.endsWith('：') ? Colors.black87 : Colors.black54,
                        fontWeight: line.endsWith('：') ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class ErpingStudentRestaurantPage extends StatelessWidget {
  const ErpingStudentRestaurantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二坪學生餐廳'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildShopCard(
            '巧麟中西式早餐店',
            [
              '位置：紅夢樓一樓',
              '營業時間：',
              '週一至週日 06:30-13:00',
              '假日 07：00－10：30',
              '主打特色：',
              '漢堡、三明治、蛋餅',
              '麵食、飯類、咖啡、奶茶',
            ],
            Icons.breakfast_dining,
            const ['assets/images/menu_qiaolin_1.jpg', 'assets/images/menu_qiaolin_2.jpg'],
          ),
          _buildShopCard(
            '蓮莊餐飲',
            [
              '位置：紅夢樓一樓',
              '營業時間：',
              '週一至週日',
              '午餐 11:00-13:30',
              '晚餐 16:50-18:30',
              '',
              '主打特色：',
              '快餐、炒飯(麵)及麵食',
            ],
            Icons.lunch_dining,
            const ['assets/images/menu_lianzhuang_1.jpg'],
          ),
          _buildShopCard(
            '小食堂滷味&飲品',
            [
              '位置：紅夢樓一樓',
              '營業時間：',
              '週一至週日 10:00-19:00',
              '',
              '主打特色：',
              '各式滷味、手工粉圓',
            ],
            Icons.soup_kitchen,
          ),
          _buildShopCard(
            '荷香園-麵麵聚到',
            [
              '位置：紅夢樓一樓',
              '營業時間：',
              '週一至週日',
              '午餐 11:00-13:30',
              '晚餐 16:50-18:30',
              '',
              '主打特色：',
              '各式麵食、湯麵',
            ],
            Icons.ramen_dining,
          ),
          _buildShopCard(
            '凍心炸冰淇淋',
            [
              '位置：紅夢樓一樓',
              '營業時間：',
              '週一至週日 11:00-18:00',
              '',
              '主打特色：',
              '炸冰淇淋、氣泡飲',
            ],
            Icons.icecream,
          ),
          _buildShopCard(
            '愛在蔬食',
            [
              '位置：紅夢樓一樓',
              '營業時間：',
              '週一至週日',
              '午餐 11:00-13:30',
              '晚餐 16:50-18:30',
              '',
              '主打特色：',
              '蔬食自助餐、素食便當',
            ],
            Icons.eco,
            const ['assets/images/menu_vegan_1.jpg'],
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(String title, List<String> content, IconData icon, [List<String>? menuImages]) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.orange),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...content.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 14,
                      color: line.endsWith('：') ? Colors.black87 : Colors.black54,
                      fontWeight: line.endsWith('：') ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                )),
            if (menuImages != null) ...[
              const SizedBox(height: 16),
              const Text(
                '菜單預覽：',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: menuImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewPage(
                                imageUrl: menuImages[index],
                                title: '$title - 菜單 ${index + 1}',
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: menuImages[index],
                          child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                menuImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LandscapeRestaurantPage extends StatelessWidget {
  const LandscapeRestaurantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('景觀餐廳'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildShopCard(
            context,
            '石灶麻辣',
            [
              '位於景觀餐廳一樓後棟'
              '營業時間：',
              '週一至週日 10:00-20:00',
              '',
            ],
            Icons.whatshot,
            const ['assets/images/menu_shizao_1.jpg'],
          ),
          _buildShopCard(
            context,
            '彭爸麵食館',
            [
              '位於景觀餐廳二樓',
              '營業時間：',
              '週一至週六 午晚餐',
              '',
            ],
            Icons.ramen_dining,
            const ['assets/images/menu_pengba_1.jpg'],
          ),
          _buildShopCard(
            context,
            '星空下複合式餐飲',
            [
              '位於景觀餐廳 1 F',
              '營業時間：',
              '週一至週日 10:30-20:00',
              '**星期六公休',
            ],
            Icons.restaurant_menu,
            const ['assets/images/menu_starsky_1.jpg'],
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(
    BuildContext context,
    String title,
    List<String> content,
    IconData icon,
    List<String>? menuImages,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.orange),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...content.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 14,
                      color: line.endsWith('：') ? Colors.black87 : Colors.black54,
                      fontWeight: line.endsWith('：') ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                )),
            if (menuImages != null) ...[
              const SizedBox(height: 16),
              const Text(
                '菜單預覽：',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: menuImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewPage(
                                imageUrl: menuImages[index],
                                title: '$title - 菜單 ${index + 1}',
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: menuImages[index],
                          child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                menuImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ImageViewPage extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ImageViewPage({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: imageUrl,
            child: Image.asset(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class BajiaRestaurantPage extends StatelessWidget {
  const BajiaRestaurantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('八甲校區餐廳'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildRestaurantCard(
            '八甲學生餐廳',
            '位於學生活動中心',
            '營業時間：週一至週五 07:00-19:00',
            Icons.restaurant,
          ),
          _buildRestaurantCard(
            '八甲 7-11',
            '位於理工學院一館 1 F',
            '營業時間：週一至週日 07:00-23:00',
            Icons.store,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(
    String title,
    String location,
    String hours,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(location),
            const SizedBox(height: 8),
            Text(hours),
          ],
        ),
      ),
    );
  }
}

class BusSchedulePage extends StatefulWidget {
  const BusSchedulePage({Key? key}) : super(key: key);

  @override
  State<BusSchedulePage> createState() => _BusSchedulePageState();
}

class _BusSchedulePageState extends State<BusSchedulePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _busImages = [
    'assets/images/bus_schedule_1.png',
    'assets/images/bus_schedule_2.png',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('校車時刻表'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _busImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Image.asset(
                      _busImages[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _busImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
                Text('${_currentPage + 1} / ${_busImages.length}'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _currentPage < _busImages.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
