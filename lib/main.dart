import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zoiqmkqtmpwjuzonhapc.supabase.co',
    anonKey: 'sb_publishable_6MdxZvn758au3aVeKQhHBg_SsGkaUeu',
  );

  runApp(const SmoovieApp());
}

final supabase = Supabase.instance.client;

const smooviePink = Color(0xFFFF4D7D);
const smooviePurple = Color(0xFF8E5CFF);

class SmoovieApp extends StatelessWidget {
  const SmoovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smoovie',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0C0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: smooviePink,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.045),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: smooviePink,
              width: 1.5,
            ),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSubscription;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _session = supabase.auth.currentSession;

    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      setState(() => _session = data.session);
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return const WelcomeScreen();
    }

    return const ProfileGate();
  }
}

class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  bool _loading = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await supabase
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _hasProfile = profile != null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _profileCreated() {
    setState(() => _hasProfile = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasProfile) {
      return OnboardingScreen(onCompleted: _profileCreated);
    }

    return const HomeScreen();
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [smooviePink, smooviePurple],
                  ),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Smoovie',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Poznawaj nowych ludzi,\nrozmawiaj i łap vibe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.4,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: smooviePink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Utwórz konto',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Mam już konto',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Kontynuując, akceptujesz regulamin i politykę prywatności.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Wpisz e-mail i hasło.');
      return;
    }

    setState(() => _loading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (error) {
      if (!mounted) return;
      _showMessage(_translateAuthError(error.message));
    } catch (_) {
      if (!mounted) return;
      _showMessage('Wystąpił nieoczekiwany błąd.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Witaj ponownie',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Zaloguj się do swojego konta.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _hidePassword,
              decoration: InputDecoration(
                labelText: 'Hasło',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _hidePassword = !_hidePassword);
                  },
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Zaloguj się'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.length < 2) {
      _showMessage('Nazwa musi mieć co najmniej 2 znaki.');
      return;
    }

    if (!_looksLikeEmail(email)) {
      _showMessage('Wpisz poprawny adres e-mail.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Hasło musi mieć co najmniej 6 znaków.');
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': name},
      );

      if (!mounted) return;

      if (response.user == null) {
        _showMessage('Nie udało się utworzyć konta.');
        return;
      }

      if (response.session == null) {
        _showMessage(
          'Konto utworzone. Sprawdź e-mail i potwierdź konto.',
        );
      } else {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      _showMessage(_translateAuthError(error.message));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Utwórz konto',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Zacznijmy od podstaw.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nazwa'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Hasło'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Utwórz konto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InterestChoice {
  final String provider;
  final String externalId;
  final String type;
  final String name;
  final String? imageUrl;

  const InterestChoice({
    required this.provider,
    required this.externalId,
    required this.type,
    required this.name,
    this.imageUrl,
  });

  String get key => '$provider:$type:$externalId';

  Map<String, dynamic> toInsert(String userId) {
    return {
      'user_id': userId,
      'provider': provider,
      'external_id': externalId,
      'type': type,
      'name': name,
      'image_url': imageUrl,
    };
  }
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();

  final List<InterestChoice> _selectedInterests = [];
  final List<String> _selectedEmojis = [];

  int _page = 0;
  DateTime? _birthDate;
  String? _gender;
  bool _saving = false;

  static const int maxInterests = 10;
  static const int maxEmojis = 4;

  @override
  void initState() {
    super.initState();

    final metadata = supabase.auth.currentUser?.userMetadata;
    _nameController.text =
        metadata?['display_name']?.toString() ?? '';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  bool _isSelected(InterestChoice item) {
    return _selectedInterests.any((e) => e.key == item.key);
  }

  void _toggleInterest(InterestChoice item) {
    setState(() {
      final index =
          _selectedInterests.indexWhere((e) => e.key == item.key);

      if (index >= 0) {
        _selectedInterests.removeAt(index);
        return;
      }

      if (_selectedInterests.length >= maxInterests) {
        _showMessage(
          'Możesz wybrać maksymalnie $maxInterests zainteresowań.',
        );
        return;
      }

      _selectedInterests.add(item);
    });
  }

  void _toggleEmoji(String emoji) {
    setState(() {
      if (_selectedEmojis.contains(emoji)) {
        _selectedEmojis.remove(emoji);
        return;
      }

      if (_selectedEmojis.length >= maxEmojis) {
        _showMessage(
          'Możesz wybrać maksymalnie $maxEmojis emoji.',
        );
        return;
      }

      _selectedEmojis.add(emoji);
    });
  }

  void _next() {
    if (_page == 0 && _nameController.text.trim().length < 2) {
      _showMessage('Wpisz swoją nazwę.');
      return;
    }

    if (_page == 1 && _birthDate == null) {
      _showMessage('Wybierz datę urodzenia.');
      return;
    }

    if (_page == 2 && _gender == null) {
      _showMessage('Wybierz płeć.');
      return;
    }

    if (_page == 4 && _selectedInterests.length < 3) {
      _showMessage('Wybierz co najmniej 3 zainteresowania.');
      return;
    }

    if (_page == 5 && _selectedEmojis.length != maxEmojis) {
      _showMessage('Wybierz dokładnie $maxEmojis emoji.');
      return;
    }

    if (_page < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _back() {
    if (_page == 0) return;

    _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();

    final initialDate = DateTime(
      now.year - 18,
      now.month,
      now.day,
    );

    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (date != null) {
      setState(() => _birthDate = date);
    }
  }

  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    if (_cityController.text.trim().isEmpty) {
      _showMessage('Wpisz miasto.');
      return;
    }

    setState(() => _saving = true);

    try {
      await supabase.from('profiles').upsert({
        'id': user.id,
        'display_name': _nameController.text.trim(),
        'birth_date': _birthDate!.toIso8601String().split('T').first,
        'gender': _gender,
        'bio': _bioController.text.trim(),
        'city': _cityController.text.trim(),
        'interests': _selectedInterests.map((e) => e.name).toList(),
        'profile_emojis': _selectedEmojis,
      });

      await supabase
          .from('user_interests')
          .delete()
          .eq('user_id', user.id);

      if (_selectedInterests.isNotEmpty) {
        await supabase.from('user_interests').insert(
              _selectedInterests
                  .map((e) => e.toInsert(user.id))
                  .toList(),
            );
      }

      if (!mounted) return;
      widget.onCompleted();
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Nie udało się zapisać profilu: $error',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const pageCount = 7;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 20, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: _page > 0
                        ? IconButton(
                            onPressed: _back,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: (_page + 1) / pageCount,
                        minHeight: 6,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _page = index);
                },
                children: [
                  _NamePage(controller: _nameController),
                  _BirthDatePage(
                    birthDate: _birthDate,
                    onTap: _selectBirthDate,
                  ),
                  _GenderPage(
                    selectedGender: _gender,
                    onSelected: (gender) {
                      setState(() => _gender = gender);
                    },
                  ),
                  _BioPage(controller: _bioController),
                  _InterestsPage(
                    selectedInterests: _selectedInterests,
                    maxInterests: maxInterests,
                    isSelected: _isSelected,
                    onToggle: _toggleInterest,
                  ),
                  _EmojiPage(
                    selectedEmojis: _selectedEmojis,
                    maxEmojis: maxEmojis,
                    onToggle: _toggleEmoji,
                  ),
                  _CityPage(controller: _cityController),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _saving ? null : _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: smooviePink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          _page == 6 ? 'Zakończ' : 'Dalej',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NamePage extends StatelessWidget {
  final TextEditingController controller;

  const _NamePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _OnboardingContainer(
      title: 'Jak mamy Cię nazywać?',
      subtitle: 'Ta nazwa będzie widoczna na Twoim profilu.',
      child: TextField(
        controller: controller,
        maxLength: 30,
        decoration: const InputDecoration(labelText: 'Nazwa'),
      ),
    );
  }
}

class _BirthDatePage extends StatelessWidget {
  final DateTime? birthDate;
  final VoidCallback onTap;

  const _BirthDatePage({
    required this.birthDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingContainer(
      title: 'Kiedy masz urodziny?',
      subtitle: 'Potrzebujemy tego do dopasowań wiekowych.',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            birthDate == null
                ? 'Wybierz datę urodzenia'
                : '${birthDate!.day.toString().padLeft(2, '0')}.'
                    '${birthDate!.month.toString().padLeft(2, '0')}.'
                    '${birthDate!.year}',
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ),
    );
  }
}

class _GenderPage extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String> onSelected;

  const _GenderPage({
    required this.selectedGender,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingContainer(
      title: 'Jak się identyfikujesz?',
      subtitle: 'Wybierz opcję, która najlepiej Ci odpowiada.',
      child: Column(
        children: [
          _GenderButton(
            title: 'Kobieta',
            value: 'female',
            selected: selectedGender,
            onSelected: onSelected,
          ),
          const SizedBox(height: 12),
          _GenderButton(
            title: 'Mężczyzna',
            value: 'male',
            selected: selectedGender,
            onSelected: onSelected,
          ),
          const SizedBox(height: 12),
          _GenderButton(
            title: 'Inna',
            value: 'other',
            selected: selectedGender,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String title;
  final String value;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _GenderButton({
    required this.title,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final active = selected == value;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        onPressed: () => onSelected(value),
        style: OutlinedButton.styleFrom(
          backgroundColor: active
              ? smooviePink.withValues(alpha: 0.15)
              : null,
          side: BorderSide(
            color: active
                ? smooviePink
                : Colors.white.withValues(alpha: 0.15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class _BioPage extends StatelessWidget {
  final TextEditingController controller;

  const _BioPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _OnboardingContainer(
      title: 'Powiedz coś o sobie',
      subtitle:
          'Możesz dodać krótki opis. Zainteresowania wybierzesz osobno.',
      child: TextField(
        controller: controller,
        minLines: 4,
        maxLines: 6,
        maxLength: 300,
        decoration: const InputDecoration(
          hintText: 'Napisz kilka słów o sobie...',
        ),
      ),
    );
  }
}

enum InterestSection {
  popular,
  anime,
  manga,
  tags,
}

class _InterestsPage extends StatefulWidget {
  final List<InterestChoice> selectedInterests;
  final int maxInterests;
  final bool Function(InterestChoice item) isSelected;
  final ValueChanged<InterestChoice> onToggle;

  const _InterestsPage({
    required this.selectedInterests,
    required this.maxInterests,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  State<_InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<_InterestsPage> {
  final _searchController = TextEditingController();

  InterestSection _section = InterestSection.popular;

  List<InterestChoice> _localTags = [];
  List<InterestChoice> _externalResults = [];

  bool _loadingLocal = true;
  bool _searching = false;
  String? _error;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadLocalTags();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalTags() async {
    try {
      final data = await supabase
          .from('interests_catalog')
          .select('id, name, popularity')
          .eq('is_active', true)
          .order('popularity', ascending: false)
          .order('name', ascending: true);

      if (!mounted) return;

      setState(() {
        _localTags = List<Map<String, dynamic>>.from(data)
            .map(
              (row) => InterestChoice(
                provider: 'local',
                externalId: row['id'].toString(),
                type: 'tag',
                name: row['name'].toString(),
              ),
            )
            .toList();
        _loadingLocal = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingLocal = false;
        _error = 'Nie udało się pobrać tagów.';
      });
    }
  }

  void _changeSection(InterestSection section) {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {
      _section = section;
      _externalResults = [];
      _searching = false;
      _error = null;
    });

    if (section == InterestSection.anime ||
        section == InterestSection.manga) {
      _loadPopularAniList();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    if (_section == InterestSection.popular ||
        _section == InterestSection.tags) {
      setState(() {});
      return;
    }

    final query = value.trim();

    if (query.length < 2) {
      setState(() {
        _externalResults = [];
        _searching = false;
        _error = null;
      });
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _searchAniList(query),
    );
  }

  Future<void> _loadPopularAniList() async {
    if (_section != InterestSection.anime &&
        _section != InterestSection.manga) {
      return;
    }

    final expectedSection = _section;

    setState(() {
      _searching = true;
      _error = null;
    });

    const graphql = r'''
query ($type: MediaType) {
  Page(page: 1, perPage: 30) {
    media(type: $type, sort: POPULARITY_DESC) {
      id
      popularity
      synonyms
      title { romaji english native }
      coverImage { medium large }
    }
  }
}
''';

    try {
      final response = await http.post(
        Uri.parse('https://graphql.anilist.co'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'query': graphql,
          'variables': {
            'type': expectedSection == InterestSection.anime
                ? 'ANIME'
                : 'MANGA',
          },
        }),
      );

      if (!mounted || _section != expectedSection) return;

      if (response.statusCode != 200) {
        setState(() {
          _searching = false;
          _error = 'AniList zwrócił błąd ${response.statusCode}.';
        });
        return;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final page = decoded['data']?['Page'] as Map<String, dynamic>?;
      final media = List<Map<String, dynamic>>.from(
        page?['media'] ?? const [],
      );

      final results = _mapAniListMedia(media, expectedSection);

      setState(() {
        _externalResults = results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || _section != expectedSection) return;

      setState(() {
        _searching = false;
        _error = 'Nie udało się połączyć z AniList.';
      });
    }
  }

  List<InterestChoice> _mapAniListMedia(
    List<Map<String, dynamic>> media,
    InterestSection section,
  ) {
    return media.map((item) {
      final title = item['title'] as Map<String, dynamic>? ?? {};
      final english = title['english']?.toString().trim();
      final romaji = title['romaji']?.toString().trim();
      final native = title['native']?.toString().trim();

      final name = (english != null && english.isNotEmpty)
          ? english
          : (romaji != null && romaji.isNotEmpty)
              ? romaji
              : (native != null && native.isNotEmpty)
                  ? native
                  : 'Bez tytułu';

      final cover = item['coverImage'] as Map<String, dynamic>? ?? {};

      return InterestChoice(
        provider: 'anilist',
        externalId: item['id'].toString(),
        type: section == InterestSection.anime ? 'anime' : 'manga',
        name: name,
        imageUrl:
            cover['large']?.toString() ?? cover['medium']?.toString(),
      );
    }).toList();
  }

  Future<List<InterestChoice>> _fallbackAniListSearch(
    String query,
    InterestSection section,
  ) async {
    const graphql = r'''
query ($type: MediaType) {
  p1: Page(page: 1, perPage: 50) {
    media(type: $type, sort: POPULARITY_DESC) {
      id popularity synonyms
      title { romaji english native }
      coverImage { medium large }
    }
  }
  p2: Page(page: 2, perPage: 50) {
    media(type: $type, sort: POPULARITY_DESC) {
      id popularity synonyms
      title { romaji english native }
      coverImage { medium large }
    }
  }
  p3: Page(page: 3, perPage: 50) {
    media(type: $type, sort: POPULARITY_DESC) {
      id popularity synonyms
      title { romaji english native }
      coverImage { medium large }
    }
  }
  p4: Page(page: 4, perPage: 50) {
    media(type: $type, sort: POPULARITY_DESC) {
      id popularity synonyms
      title { romaji english native }
      coverImage { medium large }
    }
  }
  p5: Page(page: 5, perPage: 50) {
    media(type: $type, sort: POPULARITY_DESC) {
      id popularity synonyms
      title { romaji english native }
      coverImage { medium large }
    }
  }
  p6: Page(page: 6, perPage: 50) {
    media(type: $type, sort: POPULARITY_DESC) {
      id popularity synonyms
      title { romaji english native }
      coverImage { medium large }
    }
  }
  p7: Page(page: 7, perPage: 50) {
    media(type: $type, sort: POPULARITY_DESC) {
      id popularity synonyms
      title { romaji english native }
      coverImage { medium large }
    }
  }
  p8: Page(page: 8, perPage: 50) {
    media(type: $type, sort: POPULARITY_DESC) {
      id popularity synonyms
      title { romaji english native }
      coverImage { medium large }
    }
  }
  p9: Page(page: 9, perPage: 50) {
    media(type: $type, sort: POPULARITY_DESC) {
      id popularity synonyms
      title { romaji english native }
      coverImage { medium large }
    }
  }
  p10: Page(page: 10, perPage: 50) {
    media(type: $type, sort: POPULARITY_DESC) {
      id popularity synonyms
      title { romaji english native }
      coverImage { medium large }
    }
  }
}
''';

    final response = await http.post(
      Uri.parse('https://graphql.anilist.co'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': graphql,
        'variables': {
          'type': section == InterestSection.anime ? 'ANIME' : 'MANGA',
        },
      }),
    );

    if (response.statusCode != 200) return const [];

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? {};
    final media = <Map<String, dynamic>>[];

    for (final key in ['p1','p2','p3','p4','p5','p6','p7','p8','p9','p10']) {
      final page = data[key] as Map<String, dynamic>?;
      media.addAll(
        List<Map<String, dynamic>>.from(page?['media'] ?? const []),
      );
    }

    final q = query.toLowerCase();

    final scored = media.map((item) {
      final title = item['title'] as Map<String, dynamic>? ?? {};

      // STRICT MATCH:
      // bierzemy tylko oficjalne tytuły widoczne użytkownikowi.
      // Nie używamy synonyms, bo potrafią przepuszczać losowe wyniki.
      final names = <String>[
        title['english']?.toString() ?? '',
        title['romaji']?.toString() ?? '',
        title['native']?.toString() ?? '',
      ].map((e) => e.toLowerCase()).toList();

      final starts = names.any((name) => name.startsWith(q));
      final wordStarts = names.any((name) => name
          .split(RegExp(r'[\s:;,.!?()\[\]\-_/]+'))
          .any((word) => word.startsWith(q)));
      final contains = names.any((name) => name.contains(q));
      final popularity = item['popularity'] as int? ?? 0;

      final score = starts ? 3 : wordStarts ? 2 : contains ? 1 : 0;
      return {'item': item, 'score': score, 'popularity': popularity};
    }).where((row) => (row['score'] as int) > 0).toList();

    scored.sort((a, b) {
      final scoreCompare = (b['score'] as int).compareTo(a['score'] as int);
      if (scoreCompare != 0) return scoreCompare;
      return (b['popularity'] as int).compareTo(a['popularity'] as int);
    });

    final filtered = scored
        .map((row) => row['item'] as Map<String, dynamic>)
        .toList();

    return _mapAniListMedia(filtered, section);
  }

  Future<void> _searchAniList(String query) async {
    if (_section != InterestSection.anime &&
        _section != InterestSection.manga) {
      return;
    }

    final expectedSection = _section;

    setState(() {
      _searching = true;
      _error = null;
    });

    const graphql = r'''
query ($search: String, $type: MediaType) {
  Page(page: 1, perPage: 30) {
    media(
      search: $search
      type: $type
      sort: [SEARCH_MATCH, POPULARITY_DESC]
    ) {
      id
      popularity
      synonyms
      title { romaji english native }
      coverImage { medium large }
    }
  }
}
''';

    try {
      final response = await http.post(
        Uri.parse('https://graphql.anilist.co'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'query': graphql,
          'variables': {
            'search': query,
            'type': expectedSection == InterestSection.anime
                ? 'ANIME'
                : 'MANGA',
          },
        }),
      );

      if (!mounted || _section != expectedSection) return;

      if (response.statusCode != 200) {
        setState(() {
          _searching = false;
          _error = 'AniList zwrócił błąd ${response.statusCode}.';
        });
        return;
      }

      final decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      final page =
          decoded['data']?['Page'] as Map<String, dynamic>?;

      final media = List<Map<String, dynamic>>.from(
        page?['media'] ?? const [],
      );

      final q = query.trim().toLowerCase();

      final filteredDirect = media.where((item) {
        final title = item['title'] as Map<String, dynamic>? ?? {};

        // STRICT MATCH:
        // wynik musi zawierać wpisaną frazę w english/romaji/native.
        // Synonimy są celowo pomijane.
        final names = <String>[
          title['english']?.toString() ?? '',
          title['romaji']?.toString() ?? '',
          title['native']?.toString() ?? '',
        ];

        return names.any(
          (name) => name.toLowerCase().contains(q),
        );
      }).toList();

      var results = _mapAniListMedia(
        filteredDirect,
        expectedSection,
      );

      if (results.isEmpty && query.trim().length >= 2) {
        results = await _fallbackAniListSearch(
          query.trim(),
          expectedSection,
        );
      }

      if (!mounted || _section != expectedSection) return;

      setState(() {
        _externalResults = results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || _section != expectedSection) return;

      setState(() {
        _searching = false;
        _error = 'Nie udało się połączyć z AniList.';
      });
    }
  }

  List<InterestChoice> get _visibleLocalTags {
    final query = _searchController.text.trim().toLowerCase();

    final source = _section == InterestSection.popular
        ? _localTags.take(30).toList()
        : _localTags;

    if (query.isEmpty) return source;

    return source
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  String get _searchHint {
    switch (_section) {
      case InterestSection.anime:
        return 'Szukaj anime, np. Nana...';
      case InterestSection.manga:
        return 'Szukaj mangi, np. Berserk...';
      case InterestSection.tags:
        return 'Szukaj tagów, np. F1, Cats...';
      case InterestSection.popular:
        return 'Szukaj popularnych tagów...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAniList = _section == InterestSection.anime ||
        _section == InterestSection.manga;

    final localResults = _visibleLocalTags;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wybierz zainteresowania',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Możesz wybrać zwykłe tagi, anime i mangę. '
            'Filmy, seriale i artystów dodamy jako kolejne źródła.',
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _SectionChip(
                  title: 'Popularne',
                  active: _section == InterestSection.popular,
                  onTap: () =>
                      _changeSection(InterestSection.popular),
                ),
                _SectionChip(
                  title: 'Anime',
                  active: _section == InterestSection.anime,
                  onTap: () =>
                      _changeSection(InterestSection.anime),
                ),
                _SectionChip(
                  title: 'Manga',
                  active: _section == InterestSection.manga,
                  onTap: () =>
                      _changeSection(InterestSection.manga),
                ),
                _SectionChip(
                  title: 'Tagi',
                  active: _section == InterestSection.tags,
                  onTap: () =>
                      _changeSection(InterestSection.tags),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: _searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _debounce?.cancel();
                        _searchController.clear();

                        setState(() {
                          _externalResults = [];
                          _searching = false;
                          _error = null;
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: smooviePink.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.selectedInterests.length}'
                  ' / ${widget.maxInterests}',
                  style: const TextStyle(
                    color: Color(0xFFFFA0BA),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'minimum 3',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          if (widget.selectedInterests.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedInterests
                  .map(
                    (item) => _SelectedInterestChip(
                      item: item,
                      onRemove: () => widget.onToggle(item),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 26),
          if (_error != null)
            _InfoBox(text: _error!)
          else if (_searching)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: CircularProgressIndicator(),
              ),
            )
          else if (isAniList)
            if (_externalResults.isEmpty)
              const _InfoBox(text: 'Brak wyników.')
            else
              Column(
                children: _externalResults
                    .map(
                      (item) => _ExternalInterestTile(
                        item: item,
                        selected: widget.isSelected(item),
                        onTap: () => widget.onToggle(item),
                      ),
                    )
                    .toList(),
              )
          else if (_loadingLocal)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: CircularProgressIndicator(),
              ),
            )
          else if (localResults.isEmpty)
            const _InfoBox(text: 'Nie znaleziono tagów.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: localResults
                  .map(
                    (item) => _ProfileTagButton(
                      text: item.name,
                      selected: widget.isSelected(item),
                      onTap: () => widget.onToggle(item),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;

  const _SectionChip({
    required this.title,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: active
                ? smooviePink
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedInterestChip extends StatelessWidget {
  final InterestChoice item;
  final VoidCallback onRemove;

  const _SelectedInterestChip({
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 12,
        right: 6,
        top: 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: smooviePink.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: smooviePink.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              item.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(100),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExternalInterestTile extends StatelessWidget {
  final InterestChoice item;
  final bool selected;
  final VoidCallback onTap;

  const _ExternalInterestTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected
                ? smooviePink.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? smooviePink
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 58,
                  height: 78,
                  color: Colors.white.withValues(alpha: 0.06),
                  child: item.imageUrl == null
                      ? const Icon(Icons.image_outlined)
                      : Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const Icon(Icons.image_outlined);
                          },
                        ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.type == 'anime' ? 'Anime' : 'Manga',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                color: selected
                    ? smooviePink
                    : Colors.white.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;

  const _InfoBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _ProfileTagButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileTagButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? smooviePink
                : Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFF85A7)
                  : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight:
                  selected ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmojiPage extends StatelessWidget {
  final List<String> selectedEmojis;
  final int maxEmojis;
  final ValueChanged<String> onToggle;

  const _EmojiPage({
    required this.selectedEmojis,
    required this.maxEmojis,
    required this.onToggle,
  });

  static const List<String> emojis = [
    '😀', '😃', '😄', '😁', '😆', '😂',
    '🤣', '🥹', '😊', '😇', '🙂', '🙃',
    '😉', '😌', '😍', '🥰', '😘', '😋',
    '😜', '🤪', '😎', '🥳', '😏', '😒',
    '🥺', '😭', '😤', '😈', '👿', '💀',
    '👻', '🤡', '👽', '🤖', '😺', '😸',
    '😹', '😻', '🙈', '🙉', '🙊', '💋',
    '💘', '💝', '💖', '💗', '💓', '💞',
    '💕', '💔', '❤️', '🩷', '🧡', '💛',
    '💚', '💙', '💜', '🖤', '🤍', '🔥',
    '✨', '⭐', '🌙', '☀️', '🌈', '🌸',
    '🌹', '🍀', '🍓', '🍒', '🍷', '☕',
    '🎧', '🎵', '🎸', '🎮', '⚽', '🏀',
    '🥊', '🏎️', '🚗', '✈️', '📸', '💸',
    '💯', '‼️', '❗', '♈', '♉', '♊',
    '♋', '♌', '♍', '♎', '♏', '♐',
    '♑', '♒', '♓', '🗣️', '🫶', '🤝',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wybierz swoje emoji',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wybierz $maxEmojis emoji, które najlepiej opisują Twój vibe.',
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: selectedEmojis
                  .map(
                    (emoji) => Text(
                      emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 26),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: emojis.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
            ),
            itemBuilder: (context, index) {
              final emoji = emojis[index];
              final selected = selectedEmojis.contains(emoji);

              return InkWell(
                onTap: () => onToggle(emoji),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? smooviePink.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.055),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      width: selected ? 1.8 : 1,
                      color: selected
                          ? smooviePink
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 27),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CityPage extends StatelessWidget {
  final TextEditingController controller;

  const _CityPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _OnboardingContainer(
      title: 'Skąd jesteś?',
      subtitle: 'Na razie wpisz swoje miasto ręcznie.',
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Miasto',
          prefixIcon: Icon(Icons.location_on_outlined),
        ),
      ),
    );
  }
}

class _OnboardingContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _OnboardingContainer({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _interests = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final interestRows = await supabase
          .from('user_interests')
          .select('provider, external_id, type, name, image_url')
          .eq('user_id', user.id)
          .order('id');

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _interests =
            List<Map<String, dynamic>>.from(interestRows);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
  }

  int _calculateAge(String? birthDate) {
    if (birthDate == null) return 0;

    final birth = DateTime.tryParse(birthDate);
    if (birth == null) return 0;

    final now = DateTime.now();

    int age = now.year - birth.year;

    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name =
        _profile?['display_name']?.toString() ?? 'Użytkownik';
    final city = _profile?['city']?.toString() ?? '';
    final bio = _profile?['bio']?.toString() ?? '';
    final age =
        _calculateAge(_profile?['birth_date']?.toString());

    final emojis = List<String>.from(
      _profile?['profile_emojis'] ?? const [],
    );

    final fallbackNames = List<String>.from(
      _profile?['interests'] ?? const [],
    );

    final displayInterests = _interests.isNotEmpty
        ? _interests.map((e) => e['name'].toString()).toList()
        : fallbackNames;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smoovie',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Wyloguj',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF16161E),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [smooviePink, smooviePurple],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 35,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              age > 0 ? '$name, $age' : name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.home_outlined,
                                  size: 19,
                                  color: Colors.white.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  city,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (displayInterests.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: displayInterests.map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            interest.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (emojis.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Wrap(
                        spacing: 12,
                        children: emojis
                            .map(
                              (emoji) => Text(
                                emoji,
                                style:
                                    const TextStyle(fontSize: 28),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                  if (bio.trim().isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text(
                      bio,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _looksLikeEmail(String email) {
  return RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  ).hasMatch(email);
}

String _translateAuthError(String message) {
  final error = message.toLowerCase();

  if (error.contains('invalid login credentials')) {
    return 'Nieprawidłowy e-mail lub hasło.';
  }

  if (error.contains('email not confirmed')) {
    return 'Najpierw potwierdź swój adres e-mail.';
  }

  if (error.contains('already registered')) {
    return 'Konto z tym adresem już istnieje.';
  }

  if (error.contains('rate limit')) {
    return 'Za dużo prób. Spróbuj ponownie później.';
  }

  return message;
}
