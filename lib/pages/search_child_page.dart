
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/pages/child_detail_page.dart';
import 'package:web_page/services/firestore_service.dart';
import 'package:web_page/widgets/app_card.dart';
import 'package:web_page/widgets/sleek_app_bar.dart';

class SearchChildPage extends StatefulWidget {
  const SearchChildPage({super.key});

  @override
  State<SearchChildPage> createState() => _SearchChildPageState();
}

class _SearchChildPageState extends State<SearchChildPage> {
  final searchController = TextEditingController();
  final firestoreService = FirestoreService();

  List<QueryDocumentSnapshot> searchResults = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> searchChild() async {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      setState(() => errorMessage = 'Enter a child ID or name to search.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
      errorMessage = null;
      searchResults = [];
    });

    try {
      final results = await firestoreService.searchChildren(query);

      if (!mounted) return;
      setState(() {
        searchResults = results;
        isLoading = false;
        if (searchResults.isEmpty) {
          errorMessage = 'No child profiles matched your search.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Search failed. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SleekAppBar(
        title: 'Find Existing Child',
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _searchHeader(),
                  const SizedBox(height: 18),
                  Expanded(child: _results()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchHeader() {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionTitle(
            title: 'Search child profiles',
            subtitle:
                'Use the generated child ID for the fastest and most precise search.',
            icon: Icons.manage_search_rounded,
          ),
          const SizedBox(height: 18),
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => searchChild(),
            decoration: InputDecoration(
              labelText: 'Child ID or name',
              hintText: 'e.g. CH0001 or Aarav',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchResults = [];
                          errorMessage = null;
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : searchChild,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search_rounded),
              label: Text(isLoading ? 'Searching...' : 'Search profiles'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _results() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: AppCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                searchResults.isEmpty
                    ? Icons.search_off_rounded
                    : Icons.info_outline_rounded,
                size: 44,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return const Center(
        child: Text(
          'Your search results will appear here.',
          style: TextStyle(color: AppColors.mutedText),
        ),
      );
    }

    return ListView.separated(
      itemCount: searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final child =
            searchResults[index].data() as Map<String, dynamic>;

        return _ChildResultCard(
          child: child,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChildDetailPage(
                childID: child['childID'],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChildResultCard extends StatefulWidget {
  final Map<String, dynamic> child;
  final VoidCallback onTap;

  const _ChildResultCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_ChildResultCard> createState() => _ChildResultCardState();
}

class _ChildResultCardState extends State<_ChildResultCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final childName = child['childName']?.toString().trim() ?? '';
    final initial = childName.isNotEmpty ? childName[0].toUpperCase() : 'C';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hovered ? AppColors.primaryLight : AppColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0E000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(.10),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child['childName']?.toString() ?? 'Unnamed child',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MiniChip(
                          icon: Icons.badge_outlined,
                          text: child['childID']?.toString() ?? '-',
                        ),
                        _MiniChip(
                          icon: Icons.home_outlined,
                          text: (child['address'] ?? child['village'])?.toString() ?? '-',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: hovered ? AppColors.primary : AppColors.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
