Name:           editor
Version:        0.4
Release:        %(date +%Y%m%d%H)%{?dist}
Summary:        Editor of LAA Competition tracks

Group:          Applications/Internet
License:        BUT LICENCE (GPLv2 compatibile)
URL:            https://github.com/DCGM/LAA-maps-editor
Source0:        https://github.com/DCGM/LAA-maps-editor/archive/master.tar.gz#/%{name}-%{version}.tar.gz

BuildRequires:  git
BuildRequires:  desktop-file-utils
BuildRequires:  cmake

%if 0%{?fedora} && 0%{?fedora}  <= 32
BuildRequires:  qt5-devel >= 5.10.0
%else
BuildRequires: qt5-qtbase-devel
BuildRequires: qt5-qtquickcontrols
BuildRequires: qt5-linguist
BuildRequires: qt5-qtdeclarative-devel
%endif


%description
editor is tool for editing of LAA Competion tracks

%prep
%setup -q -n %{name}-%{version}


%build
%cmake
make %{?_smp_mflags}


%install
make DESTDIR=%{buildroot} install

desktop-file-validate %{buildroot}%{_datadir}/applications/%{name}.desktop

#desktop-file-install --dir $RPM_BUILD_ROOT/opt/%{name}/share/applications\
#      $RPM_BUILD_ROOT%{_datadir}/applications/%{name}.desktop

%files
%dir /usr/share/editor
/usr/share/editor/i18n
/usr/share/editor/i18n/editor_cs_CZ.qm
/usr/share/editor/i18n/editor_en_US.qm
/usr/share/editor/editor_defaults.json
/usr/share/applications/editor.desktop
/usr/share/icons/hicolor/applications/64x64/editor64.ico
/usr/share/icons/hicolor/applications/64x64/editor64.png
/usr/bin/editor


%changelog
* Fri Jun 15 2018 Jozef Mlich <imlich@fit.vutbr.cz> - 0.2.0-1
- initial packaging

