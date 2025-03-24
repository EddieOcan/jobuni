import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab CV Builder
            NavigationView {
                CVBuilderView()
            }
            .tabItem {
                Label("Crea CV", systemImage: "doc.text.fill")
            }
            .tag(0)
            
            // Tab Preview
            NavigationView {
                CVPreviewView()
            }
            .tabItem {
                Label("Anteprima", systemImage: "eye.fill")
            }
            .tag(1)
            
            // Tab Profilo
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profilo", systemImage: "person.fill")
            }
            .tag(2)
        }
        .accentColor(Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)))
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
    }
} 