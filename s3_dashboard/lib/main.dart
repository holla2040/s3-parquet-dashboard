import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:js' as js;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S3 Parquet Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DashboardPage(title: 'S3 Parquet Data Dashboard'),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.title});

  final String title;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<FlSpot> chartData = [];
  bool isLoading = false;
  String statusMessage = "Ready to load data";

  // Placeholder for your S3 bucket and file details
  final String bucketUrl = "https://your-bucket.s3.amazonaws.com";
  final String fileName = "your-data.parquet";

  @override
  void initState() {
    super.initState();
    // Load some sample data for demonstration
    _loadSampleData();
  }

  void _loadSampleData() {
    setState(() {
      // Sample data points for the chart
      chartData = [
        const FlSpot(1, 10),
        const FlSpot(2, 15),
        const FlSpot(3, 12),
        const FlSpot(4, 20),
        const FlSpot(5, 18),
        const FlSpot(6, 25),
        const FlSpot(7, 22),
      ];
      statusMessage = "Sample data loaded";
    });
  }

  Future<void> _loadParquetData() async {
    setState(() {
      isLoading = true;
      statusMessage = "Loading parquet data from S3...";
    });

    try {
      // This is where you'd integrate with parquet-wasm or similar
      // For now, simulating API call
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Replace with actual S3 + Parquet processing
      // You would:
      // 1. Fetch parquet file from S3
      // 2. Use parquet-wasm to parse it
      // 3. Convert to chart data points
      
      setState(() {
        chartData = [
          const FlSpot(1, 30),
          const FlSpot(2, 35),
          const FlSpot(3, 32),
          const FlSpot(4, 40),
          const FlSpot(5, 38),
          const FlSpot(6, 45),
          const FlSpot(7, 42),
        ];
        statusMessage = "Parquet data loaded successfully";
      });
    } catch (e) {
      setState(() {
        statusMessage = "Error loading data: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status and controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      statusMessage,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _loadSampleData,
                          child: const Text('Load Sample Data'),
                        ),
                        ElevatedButton(
                          onPressed: isLoading ? null : _loadParquetData,
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Load from S3'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Chart
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Data Visualization',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: chartData,
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withOpacity(0.3),
                                ),
                              ),
                            ],
                            minX: 0,
                            maxX: 8,
                            minY: 0,
                            maxY: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Metadata section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Metadata',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Data Points: ${chartData.length}'),
                    Text('Source: ${chartData.isEmpty ? "No data" : "S3 Bucket"}'),
                    Text('Last Updated: ${DateTime.now().toString().split('.')[0]}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
