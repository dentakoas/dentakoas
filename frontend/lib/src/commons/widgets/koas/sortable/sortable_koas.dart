import 'package:denta_koas/src/commons/widgets/containers/searchable_container.dart';
import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/features/appointment/controller/search_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/create_post/widget/dropdown.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SortableField extends StatelessWidget {
  final int? itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int crossAxisCount;
  final double? mainAxisExtent;
  final bool showDropdownMenu;
  final bool showSearchBar;
  final SearchPostController searchController = Get.put(SearchPostController());
  final FocusNode searchFocusNode = FocusNode();

  SortableField({
    super.key,
    this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisExtent,
    this.showDropdownMenu = true,
    this.showSearchBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        searchFocusNode.unfocus();
      },
      child: Column(
        children: [
          if (showDropdownMenu)
            DDropdownMenu(
              items: const [
                'Name',
                'University',
                'Treatment',
                'Title',
                'Popularity',
                'Newest',
                'Oldest'
              ],
              selectedItem: searchController.selectedSort.value,
              hintText: 'Sort by...',
              prefixIcon: Iconsax.sort,
              onChanged: (value) {
                if (value != null) {
                  searchController.setSort(value);
                }
              },
            ),
          const SizedBox(height: TSizes.spaceBtwSections),
          if (showSearchBar)
            ImprovedSearchContainer(
              focusNode: searchFocusNode,
              text: 'Search something...',
              showBackground: false,
              padding: const EdgeInsets.all(0),
            ),
          if (showDropdownMenu) const SizedBox(height: TSizes.spaceBtwSections),
          Obx(() {
            final posts = searchController.filteredPosts;
            return DGridLayout(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return itemBuilder(context, index);
              },
              crossAxisCount: crossAxisCount,
              mainAxisExtent: mainAxisExtent,
            );
          }),
        ],
      ),
    );
  }
}
