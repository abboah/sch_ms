import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';

/// Small building blocks used on every screen. Kept plain and dependency-free so they are easy to test.

/// A raised panel with the portal accent as a top rule, like the cards in the design.
class HrCard extends StatelessWidget {
  const HrCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.accentRule = true, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool accentRule;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // Flutter cannot paint a rounded border whose sides differ in colour (it throws mid-paint and the card's
    // contents never draw), so the border stays uniform and the accent rule is a bar laid over the top edge.
    final box = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: t.raised, borderRadius: BorderRadius.circular(3), border: Border.all(color: t.rule)),
      child: Stack(fit: StackFit.passthrough, children: [
        Padding(padding: padding, child: child),
        if (accentRule) Positioned(top: 0, left: 0, right: 0, child: ColoredBox(color: t.accent, child: const SizedBox(height: 3))),
      ]),
    );
    return onTap == null ? box : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(3), child: box);
  }
}

/// Small uppercase mono label.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: HrText.mono(11, color ?? context.tokens.mute, w: FontWeight.w500, spacing: 1.0));
}

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.sub, this.alert = false});
  final String label;
  final String value;
  final String? sub;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return HrCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Eyebrow(label),
        const SizedBox(height: 2),
        Text(value, style: HrText.mono(24, alert ? t.alert : t.ink)),
        if (sub != null) Text(sub!, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}

enum TagTone { mute, forest, brass, alert, accent }

class TagChip extends StatelessWidget {
  const TagChip(this.text, {super.key, this.tone = TagTone.mute});
  final String text;
  final TagTone tone;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = switch (tone) { TagTone.mute => t.mute, TagTone.forest => t.forest, TagTone.brass => t.brass, TagTone.alert => t.alert, TagTone.accent => t.accent };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(border: Border.all(color: c), borderRadius: BorderRadius.circular(20)),
      child: Text(text.toUpperCase(), style: HrText.mono(11, c, spacing: 0.4)),
    );
  }
}

/// Invoice / payment wording to a tone, as in the web design.
TagTone invoiceTone(String label) => switch (label) {
      'Paid' || 'Succeeded' => TagTone.forest,
      'Overdue' || 'Failed' => TagTone.alert,
      'Partial' || 'Pending' || 'Unpaid' => TagTone.brass,
      _ => TagTone.mute,
    };

/// P / L / A / E. Status is always a letter as well as a colour, never colour alone.
class StatusChip extends StatelessWidget {
  const StatusChip(this.letter, {super.key, this.compact = false});
  final String letter;
  final bool compact;

  static Color colorFor(Tokens t, String letter) => switch (letter) { 'P' => t.forest, 'L' => t.brass, 'A' => t.alert, _ => t.mute };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = colorFor(t, letter);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 9, vertical: 2),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), border: Border.all(color: c), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(letter, style: HrText.mono(12, c, w: FontWeight.w600)),
        if (!compact) ...[const SizedBox(width: 6), Text(statusLabel(letter), style: HrText.sans(12, c, w: FontWeight.w500))],
      ]),
    );
  }
}

enum BannerTone { brass, alert, forest }

class InfoBanner extends StatelessWidget {
  const InfoBanner(this.message, {super.key, this.tone = BannerTone.brass, this.action});
  final String message;
  final BannerTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (bar, bg) = switch (tone) {
      BannerTone.brass => (t.brass, t.brassSoft),
      BannerTone.alert => (t.alert, t.alert.withValues(alpha: 0.10)),
      BannerTone.forest => (t.forest, t.forestSoft),
    };
    // Uniform border plus an overlaid bar: see HrCard for why the sides cannot differ in colour.
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(3), border: Border.all(color: bar.withValues(alpha: 0.4))),
      child: Stack(fit: StackFit.passthrough, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(message, style: Theme.of(context).textTheme.bodyMedium), if (action != null) ...[const SizedBox(height: 6), action!]]),
        ),
        Positioned(top: 0, bottom: 0, left: 0, child: ColoredBox(color: bar, child: const SizedBox(width: 3))),
      ]),
    );
  }
}

class HrAvatar extends StatelessWidget {
  const HrAvatar(this.name, {super.key, this.size = 36});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final initials = name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: t.accentSoft, shape: BoxShape.circle, border: Border.all(color: t.rule)),
      child: Text(initials, style: HrText.mono(size * 0.34, t.accent, w: FontWeight.w600)),
    );
  }
}

/// A grouped list with hairline dividers, like the design's `List`.
class HrList extends StatelessWidget {
  const HrList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(color: t.raised, border: Border.all(color: t.rule), borderRadius: BorderRadius.circular(3)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) Divider(height: 1, color: t.rule.withValues(alpha: 0.7)), children[i]],
      ]),
    );
  }
}

class HrRow extends StatelessWidget {
  const HrRow({super.key, required this.title, this.sub, this.trailing, this.onTap});
  final String title;
  final String? sub;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Expanded(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                if (sub != null) Text(sub!, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (onTap != null) Icon(Icons.chevron_right, color: t.mute),
          ]),
        ),
      ),
    );
  }
}

/// A full-width primary action with the 48dp touch target from the design.
class WideButton extends StatelessWidget {
  const WideButton({super.key, required this.label, required this.onPressed, this.secondary = false, this.busy = false});
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final child = busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(label);
    final action = busy ? null : onPressed;
    return SizedBox(width: double.infinity, child: secondary ? OutlinedButton(onPressed: action, child: child) : FilledButton(onPressed: action, child: child));
  }
}
