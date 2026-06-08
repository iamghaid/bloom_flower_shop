import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'theme.dart';
import 'petal_painter.dart';
import 'models.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _scrollProgress = ValueNotifier<double>(0.0);
  String _activeCategory = 'All';
  final Set<String> _cart = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final max = _scrollController.position.maxScrollExtent;
      if (max > 0) {
        _scrollProgress.value =
            (_scrollController.offset / max).clamp(0.0, 1.0);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollProgress.dispose();
    super.dispose();
  }

  List<FlowerProduct> get _filtered => _activeCategory == 'All'
      ? kProducts
      : kProducts.where((p) => p.category == _activeCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _HeroSection(),
                _FeaturesBar(),
                _ShopSection(
                  filtered: _filtered,
                  activeCategory: _activeCategory,
                  cart: _cart,
                  onCategoryChanged: (c) =>
                      setState(() => _activeCategory = c),
                  onAddToCart: (id) => setState(() => _cart.add(id)),
                ),
                _TestimonialSection(),
                _NewsletterSection(),
                _Footer(),
              ],
            ),
          ),

          // Sticky navbar
          Positioned(
            top: 0, left: 0, right: 0,
            child: _NavBar(cart: _cart, scrollProgress: _scrollProgress),
          ),

          // Scroll progress line
          Positioned(
            top: 0, left: 0, right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollProgress,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 2,
                backgroundColor: Colors.transparent,
                color: AppColors.rose.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── NAV BAR ────────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  final Set<String> cart;
  final ValueNotifier<double> scrollProgress;
  const _NavBar({required this.cart, required this.scrollProgress});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return ValueListenableBuilder<double>(
      valueListenable: scrollProgress,
      builder: (_, v, __) => AnimatedContainer(
        duration: 200.ms,
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.cream.withOpacity(v > 0.02 ? 0.96 : 1.0),
          boxShadow: v > 0.02
              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16)]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              // Logo
              Text('Bloom',
                style: GoogleFontsHelper.cormorant(
                  fontSize: 26,
                  weight: FontWeight.w600,
                  color: AppColors.bark,
                  letterSpacing: 1,
                )),
              const Spacer(),
              if (!isMobile) ...[
                _NavLink('Shop'),
                _NavLink('Story'),
                _NavLink('Care'),
                const SizedBox(width: 12),
              ],
              // Cart
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.bark, size: 22),
                    onPressed: () => _showCart(context),
                  ),
                  if (cart.isNotEmpty)
                    Positioned(
                      right: 6, top: 6,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.rose,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${cart.length}',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 9,
                              fontWeight: FontWeight.w700,
                            )),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Your Bag',
          style: GoogleFontsHelper.cormorant(
            fontSize: 24, weight: FontWeight.w600, color: AppColors.bark)),
        content: cart.isEmpty
            ? Text('Your bag is empty.',
                style: GoogleFontsHelper.mulish(color: AppColors.muted))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: cart.map((id) {
                  final p = kProducts.firstWhere((x) => x.id == id);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(p.emoji, style: const TextStyle(fontSize: 26)),
                    title: Text(p.name,
                      style: GoogleFontsHelper.mulish(
                        weight: FontWeight.w600, color: AppColors.bark)),
                    trailing: Text('\$${p.price.toStringAsFixed(0)}',
                      style: GoogleFontsHelper.cormorant(
                        fontSize: 18, weight: FontWeight.w600,
                        color: AppColors.rose)),
                  );
                }).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
              style: GoogleFontsHelper.mulish(color: AppColors.muted)),
          ),
          if (cart.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order placed! 🌸',
                      style: GoogleFontsHelper.mulish(color: Colors.white)),
                    backgroundColor: AppColors.rose,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rose,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Checkout',
                style: GoogleFontsHelper.mulish(
                  weight: FontWeight.w700, color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  const _NavLink(this.label);

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label,
              style: GoogleFontsHelper.mulish(
                fontSize: 14,
                weight: FontWeight.w500,
                color: _hovered ? AppColors.rose : AppColors.bark,
              )),
            AnimatedContainer(
              duration: 200.ms,
              height: 1.5,
              width: _hovered ? 24.0 : 0.0,
              color: AppColors.rose,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HERO SECTION ───────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          // Gradient bg
          Container(decoration: const BoxDecoration(gradient: AppColors.heroGradient)),

          // Falling petals
          const Positioned.fill(child: FallingPetals()),

          // Decorative circle
          Positioned(
            right: -80, top: size.height * 0.1,
            child: Container(
              width: 420, height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.rose.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            left: -60, bottom: size.height * 0.1,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.leaf.withOpacity(0.06),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.only(top: 68, left: isMobile ? 28 : 80, right: isMobile ? 28 : 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FRESH DAILY • SAME-DAY DELIVERY',
                  style: AppTypography.label(context),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                const SizedBox(height: 20),
                Text(
                  isMobile ? 'Flowers\nthat speak\nfrom the\nheart.' : 'Flowers\nthat speak\nfrom the heart.',
                  style: AppTypography.displayLarge(context),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms)
                    .slideY(begin: 0.15, curve: Curves.easeOut),
                const SizedBox(height: 24),
                SizedBox(
                  width: isMobile ? double.infinity : 400,
                  child: Text(
                    'Artisan bouquets curated by hand, delivered to your door within hours. Every stem chosen at peak bloom.',
                    style: AppTypography.bodyLarge(context),
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 700.ms),
                const SizedBox(height: 44),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _HeroButton(label: 'Shop Now', primary: true),
                    _HeroButton(label: 'Our Story', primary: false),
                  ],
                ).animate(delay: 800.ms).fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1),
              ],
            ),
          ),

          // Scroll hint
          Positioned(
            bottom: 32, left: 0, right: 0,
            child: Column(
              children: [
                Text('scroll', style: AppTypography.label(context)),
                const SizedBox(height: 8),
                const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.rose, size: 20),
              ],
            ).animate(delay: 1400.ms).fadeIn(duration: 800.ms),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatefulWidget {
  final String label;
  final bool primary;
  const _HeroButton({required this.label, required this.primary});

  @override
  State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          decoration: BoxDecoration(
            color: widget.primary
                ? (AppColors.rose)
                : Colors.transparent,
            border: Border.all(
              color: widget.primary ? AppColors.rose : AppColors.bark.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: widget.primary && _hovered
                ? [BoxShadow(color: AppColors.rose.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))]
                : [],
          ),
          transform: Matrix4.identity()
            ..translate(0.0, _hovered ? -3.0 : 0.0),
          child: Text(widget.label,
            style: GoogleFontsHelper.mulish(
              fontSize: 14,
              weight: FontWeight.w700,
              color: widget.primary ? Colors.white : AppColors.bark,
              letterSpacing: 0.5,
            )),
        ),
      ),
    );
  }
}

// ─── FEATURES BAR ───────────────────────────────────────────────────────────

class _FeaturesBar extends StatelessWidget {
  const _FeaturesBar();

  static const _features = [
    ('🌿', 'Hand-Picked Daily'),
    ('🚚', 'Same-Day Delivery'),
    ('♻️', 'Eco Packaging'),
    ('💌', 'Free Gift Note'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      color: AppColors.bark,
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 20 : 0,
          horizontal: isMobile ? 16 : 0),
      height: isMobile ? null : 72,
      child: isMobile
          ? Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 12,
              children: _features
                  .map((f) => _FeatureItem(icon: f.$1, label: f.$2))
                  .toList(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _features
                  .map((f) => _FeatureItem(icon: f.$1, label: f.$2))
                  .toList(),
            ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String label;
  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Text(label,
          style: GoogleFontsHelper.mulish(
            fontSize: 13,
            weight: FontWeight.w600,
            color: AppColors.petal,
            letterSpacing: 0.5,
          )),
      ],
    );
  }
}

// ─── SHOP SECTION ───────────────────────────────────────────────────────────

class _ShopSection extends StatelessWidget {
  final List<FlowerProduct> filtered;
  final String activeCategory;
  final Set<String> cart;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onAddToCart;

  const _ShopSection({
    required this.filtered,
    required this.activeCategory,
    required this.cart,
    required this.onCategoryChanged,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 1000;

    return _AnimateOnScroll(
      sectionKey: 'shop-section',
      child: Container(
        color: AppColors.cream,
        padding: EdgeInsets.symmetric(
            vertical: 80, horizontal: isMobile ? 24 : 64),
        child: Column(
          children: [
            Text('OUR COLLECTION', style: AppTypography.label(context)),
            const SizedBox(height: 12),
            Text('Seasonal Arrangements', style: AppTypography.displayMedium(context)),
            const SizedBox(height: 40),

            // Category filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: kCategories.map((c) => _CategoryChip(
                  label: c,
                  active: c == activeCategory,
                  onTap: () => onCategoryChanged(c),
                )).toList(),
              ),
            ),
            const SizedBox(height: 48),

            // Products grid
            LayoutBuilder(builder: (ctx, constraints) {
              final cols = isMobile ? 1 : isTablet ? 2 : 3;
              final cardWidth = (constraints.maxWidth - (cols - 1) * 24) / cols;
              return Wrap(
                spacing: 24,
                runSpacing: 32,
                children: filtered.asMap().entries.map((entry) {
                  return SizedBox(
                    width: cardWidth,
                    child: _FlowerCard(
                      product: entry.value,
                      inCart: cart.contains(entry.value.id),
                      onAdd: () => onAddToCart(entry.value.id),
                      delay: entry.key * 80,
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.rose : AppColors.petal,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(label,
            style: GoogleFontsHelper.mulish(
              fontSize: 13,
              weight: FontWeight.w600,
              color: active ? Colors.white : AppColors.bark,
            )),
        ),
      ),
    );
  }
}

class _FlowerCard extends StatefulWidget {
  final FlowerProduct product;
  final bool inCart;
  final VoidCallback onAdd;
  final int delay;
  const _FlowerCard({
    required this.product,
    required this.inCart,
    required this.onAdd,
    required this.delay,
  });

  @override
  State<_FlowerCard> createState() => _FlowerCardState();
}

class _FlowerCardState extends State<_FlowerCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: 220.ms,
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _hovered ? -8.0 : 0.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _hovered
              ? [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 32, offset: const Offset(0, 12))]
              : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: AnimatedContainer(
                duration: 220.ms,
                height: 220,
                color: Color(int.parse(
                    widget.product.color.replaceFirst('#', 'FF'),
                    radix: 16)).withOpacity(0.35),
                child: Stack(
                  children: [
                    Center(
                      child: AnimatedDefaultTextStyle(
                        duration: 220.ms,
                        style: TextStyle(fontSize: _hovered ? 88 : 76),
                        child: Text(widget.product.emoji),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: 14, left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(widget.product.category,
                          style: GoogleFontsHelper.mulish(
                            fontSize: 11,
                            weight: FontWeight.w700,
                            color: AppColors.bark,
                            letterSpacing: 0.5,
                          )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.name,
                    style: GoogleFontsHelper.cormorant(
                      fontSize: 22, weight: FontWeight.w600, color: AppColors.bark)),
                  const SizedBox(height: 6),
                  Text(widget.product.tagline,
                    style: GoogleFontsHelper.mulish(
                      fontSize: 13, color: AppColors.muted, height: 1.5)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('\$${widget.product.price.toStringAsFixed(0)}',
                        style: AppTypography.price(context)),
                      const Spacer(),
                      _AddButton(
                        inCart: widget.inCart,
                        onTap: widget.onAdd,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.15, curve: Curves.easeOut);
  }
}

class _AddButton extends StatefulWidget {
  final bool inCart;
  final VoidCallback onTap;
  const _AddButton({required this.inCart, required this.onTap});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: widget.inCart
                ? AppColors.leaf
                : (_hovered ? AppColors.rose : AppColors.petal),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.inCart ? Icons.check : Icons.add,
                size: 15,
                color: widget.inCart || _hovered ? Colors.white : AppColors.bark,
              ),
              const SizedBox(width: 6),
              Text(
                widget.inCart ? 'Added' : 'Add',
                style: GoogleFontsHelper.mulish(
                  fontSize: 13,
                  weight: FontWeight.w700,
                  color: widget.inCart || _hovered ? Colors.white : AppColors.bark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── TESTIMONIALS ───────────────────────────────────────────────────────────

class _TestimonialSection extends StatelessWidget {
  const _TestimonialSection();

  static const _testimonials = [
    ('"The most beautiful bouquet I\'ve ever received. Arrived perfectly fresh and lasted over two weeks."',
     'Layla M.', '⭐⭐⭐⭐⭐'),
    ('"Same-day delivery actually worked! My wife was thrilled. Will absolutely order again."',
     'Khalid R.', '⭐⭐⭐⭐⭐'),
    ('"Bloom\'s preserved rose dome is still sitting on my desk six months later. Absolutely stunning."',
     'Sara T.', '⭐⭐⭐⭐⭐'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return _AnimateOnScroll(
      sectionKey: 'testimonials',
      child: Container(
        color: AppColors.petal,
        padding: EdgeInsets.symmetric(vertical: 80, horizontal: isMobile ? 24 : 64),
        child: Column(
          children: [
            Text('LOVED BY CUSTOMERS', style: AppTypography.label(context)),
            const SizedBox(height: 12),
            Text('What they say', style: AppTypography.displayMedium(context)),
            const SizedBox(height: 48),
            LayoutBuilder(builder: (ctx, constraints) {
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: _testimonials.asMap().entries.map((e) {
                  final t = e.value;
                  return SizedBox(
                    width: isMobile
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 48) / 3,
                    child: _TestimonialCard(
                      quote: t.$1,
                      name: t.$2,
                      stars: t.$3,
                      delay: e.key * 120,
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String quote, name, stars;
  final int delay;
  const _TestimonialCard({
    required this.quote, required this.name,
    required this.stars, required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stars, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 14),
          Text(quote,
            style: GoogleFontsHelper.cormorant(
              fontSize: 17, height: 1.65, color: AppColors.bark,
              style: FontStyle.italic)),
          const SizedBox(height: 18),
          Text('— $name',
            style: GoogleFontsHelper.mulish(
              fontSize: 13, weight: FontWeight.w700, color: AppColors.rose)),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.12);
  }
}

// ─── NEWSLETTER ─────────────────────────────────────────────────────────────

class _NewsletterSection extends StatelessWidget {
  const _NewsletterSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return _AnimateOnScroll(
      sectionKey: 'newsletter',
      child: Container(
        color: AppColors.bark,
        padding: EdgeInsets.symmetric(
            vertical: 72, horizontal: isMobile ? 28 : 64),
        child: Column(
          children: [
            Text('🌸', style: const TextStyle(fontSize: 36))
                .animate().shake(duration: 1200.ms, delay: 400.ms),
            const SizedBox(height: 20),
            Text('Get seasonal offers',
              style: GoogleFontsHelper.cormorant(
                fontSize: isMobile ? 30 : 40,
                weight: FontWeight.w600,
                color: AppColors.cream,
              )),
            const SizedBox(height: 12),
            Text('Fresh arrivals and exclusive discounts, delivered to your inbox.',
              textAlign: TextAlign.center,
              style: GoogleFontsHelper.mulish(
                color: AppColors.muted, height: 1.6)),
            const SizedBox(height: 32),
            SizedBox(
              width: isMobile ? double.infinity : 480,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: TextField(
                        style: GoogleFontsHelper.mulish(
                            color: AppColors.cream, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'your@email.com',
                          hintStyle: GoogleFontsHelper.mulish(
                              color: AppColors.muted, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: AppColors.rose,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text('Subscribe',
                          style: GoogleFontsHelper.mulish(
                            color: Colors.white,
                            weight: FontWeight.w700,
                            fontSize: 14,
                          )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FOOTER ─────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Container(
      color: const Color(0xFF2A1E18),
      padding: EdgeInsets.symmetric(
          vertical: 48, horizontal: isMobile ? 28 : 64),
      child: Column(
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FooterBrand(),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _FooterLinks('Shop', ['Bouquets', 'Arrangements', 'Seasonal', 'Preserved'])),
                        Expanded(child: _FooterLinks('Help', ['Delivery', 'Returns', 'Care Tips', 'FAQ'])),
                      ],
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _FooterBrand()),
                    Expanded(child: _FooterLinks('Shop', ['Bouquets', 'Arrangements', 'Seasonal', 'Preserved'])),
                    Expanded(child: _FooterLinks('Help', ['Delivery', 'Returns', 'Care Tips', 'FAQ'])),
                    Expanded(child: _FooterLinks('About', ['Our Story', 'Farmers', 'Sustainability', 'Press'])),
                  ],
                ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 24),
          Text('© 2025 Bloom. Made with 🌸 for flower lovers everywhere.',
            textAlign: TextAlign.center,
            style: GoogleFontsHelper.mulish(
                color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bloom',
          style: GoogleFontsHelper.cormorant(
            fontSize: 28, weight: FontWeight.w600, color: AppColors.cream)),
        const SizedBox(height: 10),
        Text('Premium fresh flowers,\ndelivered with love.',
          style: GoogleFontsHelper.mulish(
            color: AppColors.muted, height: 1.7, fontSize: 13)),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  final String title;
  final List<String> links;
  const _FooterLinks(this.title, this.links);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: GoogleFontsHelper.mulish(
            fontSize: 12,
            weight: FontWeight.w700,
            color: AppColors.cream,
            letterSpacing: 1.5,
          )),
        const SizedBox(height: 14),
        ...links.map((l) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(l,
            style: GoogleFontsHelper.mulish(
              color: AppColors.muted, fontSize: 13)),
        )),
      ],
    );
  }
}

// ─── ANIMATE ON SCROLL HELPER ───────────────────────────────────────────────

class _AnimateOnScroll extends StatefulWidget {
  final Widget child;
  final String sectionKey;
  const _AnimateOnScroll({required this.child, required this.sectionKey});

  @override
  State<_AnimateOnScroll> createState() => _AnimateOnScrollState();
}

class _AnimateOnScrollState extends State<_AnimateOnScroll> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.sectionKey),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_visible) {
          setState(() => _visible = true);
        }
      },
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, 0.06),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

// ─── FONT HELPERS ───────────────────────────────────────────────────────────

class GoogleFontsHelper {
  static TextStyle cormorant({
    double fontSize = 16,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.bark,
    double? height,
    double? letterSpacing,
    FontStyle style = FontStyle.normal,
  }) {
    return TextStyle(
      fontFamily: 'Cormorant Garamond',
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: style,
    );
  }

  static TextStyle mulish({
    double fontSize = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.muted,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Mulish',
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
