Name:           editor
Version:        0.2.0
Release:        1%{?dist}
Summary:        A cross platform web browser

Group:          Applications/Internet
License:        custom
URL:            https://github.com/DCGM/LAA-maps-editor
Source0:        https://github.com/DCGM/LAA-maps-editor/archive/master.tar.gz#/%{name}-%{version}.tar.gz

BuildRequires:  desktop-file-utils
BuildRequires:  qt5-devel >= 5.10.0
BuildRequires:  qt5-linguist

%description
editor is 

%prep
%setup -q -c


%build
%{qmake_qt5} PREFIX=%{_prefix}
make %{?_smp_mflags}

%install
make INSTALL_ROOT=$RPM_BUILD_ROOT install

#desktop-file-install --dir $RPM_BUILD_ROOT/opt/%{name}/share/applications\
#      $RPM_BUILD_ROOT%{_datadir}/applications/%{name}.desktop

%files
/opt/editor/*


%changelog
* Fri Jun 15 2018 Jozef Mlich <imlich@fit.vutbr.cz> - 0.2.0-1
- initial packaging

