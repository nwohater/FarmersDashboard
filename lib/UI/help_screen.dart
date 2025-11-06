import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Tips',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color(0xFF0f0f1e),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      'assets/images/tractor1.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Farmer's Dashboard Help",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn how to use your dashboard effectively',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

              // Requirements Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade900.withOpacity(0.2),
                      Colors.amber.shade900.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade800.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade900.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.info_outline, color: Colors.amber.shade300, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Requirements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This app requires the FS25_FarmersDashboard mod to be installed on your Farming Simulator 25 server.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Make sure the mod is properly installed and activated on your server before attempting to connect.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dashboard Overview Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1a1a2e),
                      const Color(0xFF16213e).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.shade800.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade900.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.dashboard_outlined,
                            color: Colors.teal.shade300,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'What\'s on the Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDashboardItem(
                      Icons.calendar_today_outlined,
                      'Date & Time',
                      'Current game date and time',
                    ),
                    _buildDashboardItem(
                      Icons.wb_sunny_outlined,
                      'Current Weather',
                      'Real-time weather conditions and temperature',
                    ),
                    _buildDashboardItem(
                      Icons.cloud_outlined,
                      'Weather Forecast',
                      'Upcoming weather predictions for planning',
                    ),
                    _buildDashboardItem(
                      Icons.account_balance_wallet_outlined,
                      'Farm Finances',
                      'Each farm\'s current money and loan status',
                    ),
                    _buildDashboardItem(
                      Icons.grass_outlined,
                      'Field Status',
                      'Detailed status of each field for every farm',
                    ),
                    _buildDashboardItem(
                      Icons.local_offer_outlined,
                      'Sale Items',
                      'Current special deals and items for sale in-game',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Pull to Refresh Section
              _buildHelpSection(
                icon: Icons.refresh,
                title: 'Pull to Refresh',
                description:
                    'Pull down on the dashboard to refresh data from your server. This will check for the latest updates from your farming game.',
                color: Colors.blue.shade400,
              ),

              const SizedBox(height: 16),

              // Server Selection Section
              _buildHelpSection(
                icon: Icons.swap_horiz,
                title: 'Switch Servers',
                description:
                    'Tap the two arrows (↔) next to the server name to quickly switch between your saved servers without going to settings.',
                color: Colors.orange.shade400,
              ),

              const SizedBox(height: 16),

              // Settings Section
              _buildHelpSection(
                icon: Icons.settings_outlined,
                title: 'Manage Servers',
                description:
                    'Tap the gear icon (⚙️) in the top-right corner to add, edit, or remove server connections. You can also set a default server here.',
                color: Colors.green.shade400,
              ),

              const SizedBox(height: 16),

              // Connection Issues Section
              _buildHelpSection(
                icon: Icons.error_outline,
                title: 'Connection Issues?',
                description:
                    'If you see "No data to display", try the Retry button to reload from the current server, or use Change Server to switch to a different connection.',
                color: Colors.red.shade400,
              ),

              const SizedBox(height: 24),

              // Tips Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade900.withOpacity(0.2),
                      Colors.purple.shade900.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.shade800.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade900.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.lightbulb_outline, color: Colors.purple.shade300, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Pro Tips',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTip('Set a default server for automatic loading'),
                    _buildTip(
                      'Use descriptive server names for easy identification',
                    ),
                    _buildTip('Keep your server credentials secure'),
                    _buildTip(
                      'Check your internet connection if refresh fails',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
    );
  }

  Widget _buildHelpSection({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.purple.shade300, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade900.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.teal.shade400,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
