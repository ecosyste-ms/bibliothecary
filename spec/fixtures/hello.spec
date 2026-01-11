Name:           hello
Version:        2.10
Release:        1%{?dist}
Summary:        The "Hello World" program from GNU
License:        GPLv3+
URL:            http://ftp.gnu.org/gnu/hello
Source0:        https://ftp.gnu.org/gnu/hello/hello-%{version}.tar.gz

BuildRequires:  gcc
BuildRequires:  make
BuildRequires:  gettext >= 0.19
BuildRequires:  autoconf, automake

Requires:       glibc >= 2.17
Requires:       info
Requires(post): info
Requires(preun): info

%description
The "Hello World" program from GNU.

%prep
%autosetup

%build
%configure
%make_build

%install
%make_install
%find_lang %{name}

%files -f %{name}.lang
%license COPYING
%{_bindir}/hello
%{_infodir}/hello.info.*
%{_mandir}/man1/hello.1.*

%changelog
* Mon Jan 01 2024 Example User <user@example.com> - 2.10-1
- Initial package
