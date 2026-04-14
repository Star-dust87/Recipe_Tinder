//
//  CurrentUserProfileView.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 2/6/26.
//  Updated by Stella K 2/24/26
//  Updated by Stella K 3/14/26
//

import SwiftUI

struct CurrentUserProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showSignOutConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    @State private var isDeleting = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    profileHeader
                    
                    Divider()
                    
                    recipeStats
                    
                    Divider()
                    
                    preferencesSection
                    
                    Divider()
                    
                    settingsSection
                    
                    Divider()
                    
                    accountActions
                    
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog("Sign Out", isPresented: $showSignOutConfirmation) {
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .confirmationDialog("Delete Account", isPresented: $showDeleteAccountConfirmation) {
                Button("Delete Account", role: .destructive) {
                    deleteAccount()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
            }
        }
    }
    
    
    private var profileHeader: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color.pink.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.pink)
                )
            
            Text(authManager.userProfile?.displayName ?? "User")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(authManager.userProfile?.email ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
    
    
    private var recipeStats: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Recipe Stats")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                StatRow(
                    icon: "heart.fill",
                    iconColor: .pink,
                    title: "Saved Recipes",
                    value: "\(authManager.userProfile?.savedRecipeIds.count ?? 0)"
                )
                
                StatRow(
                    icon: "hand.thumbsdown.fill",
                    iconColor: .gray,
                    title: "Passed Recipes",
                    value: "\(authManager.userProfile?.dislikedRecipeIds.count ?? 0)"
                )
            }
        }
    }
    
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 0) {
                NavigationLink {
                    DietaryPreferencesView()
                        .environmentObject(authManager)
                } label: {
                    PreferenceRow(
                        icon: "leaf.fill",
                        iconColor: .green,
                        title: "Dietary Preferences",
                        count: authManager.userProfile?.dietaryRestrictions.count ?? 0
                    )
                }
                
                Divider()
                    .padding(.leading, 52)
                
                NavigationLink {
                    CuisinePreferencesView()
                        .environmentObject(authManager)
                } label: {
                    PreferenceRow(
                        icon: "globe",
                        iconColor: .blue,
                        title: "Cuisine Preferences",
                        count: authManager.userProfile?.preferredCuisines.count ?? 0
                    )
                }
                
                Divider()
                    .padding(.leading, 52)
                
                NavigationLink {
                    HealthPreferencesView()
                        .environmentObject(authManager)
                } label: {
                    PreferenceRow(
                        icon: "heart.fill",
                        iconColor: .red,
                        title: "Health Preferences",
                        count: authManager.userProfile?.healthPreferences.count ?? 0
                    )
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 0) {
                NavigationLink {
                    NotificationsSettingsView()
                        .environmentObject(authManager)
                } label: {
                    SettingsRow(
                        icon: "bell.fill",
                        iconColor: .orange,
                        title: "Notifications"
                    )
                }
                
                Divider()
                    .padding(.leading, 52)
                
                NavigationLink {
                    AboutView()
                } label: {
                    SettingsRow(
                        icon: "info.circle.fill",
                        iconColor: .blue,
                        title: "About"
                    )
                }
                
                Divider()
                    .padding(.leading, 52)
                
                NavigationLink {
                    TermsOfServiceView()
                } label: {
                    SettingsRow(
                        icon: "doc.text.fill",
                        iconColor: .purple,
                        title: "Terms of Service"
                    )
                }
                
                Divider()
                    .padding(.leading, 52)
                
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    SettingsRow(
                        icon: "lock.fill",
                        iconColor: .green,
                        title: "Privacy Policy"
                    )
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    
    private var accountActions: some View {
        VStack(spacing: 12) {
            Button {
                showSignOutConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.red)
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            
            Button {
                showDeleteAccountConfirmation = true
            } label: {
                HStack {
                    if isDeleting {
                        ProgressView()
                            .tint(.red)
                    } else {
                        Image(systemName: "trash.fill")
                        Text("Delete Account")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.red)
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .disabled(isDeleting)
        }
    }
    
    
    private func signOut() {
        do {
            try authManager.signOut()
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    private func deleteAccount() {
        isDeleting = true
        
        Task {
            do {
                try await authManager.deleteAccount()
            } catch {
                print("Error deleting account: \(error)")
                await MainActor.run {
                    isDeleting = false
                }
            }
        }
    }
}


struct StatRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct PreferenceRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 28)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            if count > 0 {
                Text("\(count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 28)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}


struct NotificationsSettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var notificationsEnabled = true
    
    var body: some View {
        List {
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { _, newValue in
                    saveNotificationSetting(newValue)
                }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            notificationsEnabled = authManager.userProfile?.notificationsEnabled ?? true
        }
    }
    
    private func saveNotificationSetting(_ enabled: Bool) {
        guard var profile = authManager.userProfile else {
            return
        }
        
        profile.notificationsEnabled = enabled
        
        Task {
            try? await authManager.updateUserProfile(profile)
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section("App Information") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("1")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Team") {
                Text("Recipe Tinder")
                    .font(.headline)
                Text("CPSC 491 Capstone Project")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("California State University, Fullerton")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("""
                Welcome to Recipe Tinder!
                
                By using our app, you agree to these terms of service.
                
                1. Use of Service
                Recipe Tinder provides a platform for discovering recipes through a swipe-based interface.
                
                2. User Accounts
                You are responsible for maintaining the confidentiality of your account credentials.
                
                3. Content
                All recipe content is sourced from third-party APIs and their respective owners.
                
                4. Privacy
                We take your privacy seriously. Please review our Privacy Policy for details on how we handle your data.
                
                5. Modifications
                We reserve the right to modify these terms at any time.
                """)
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("""
                Recipe Tinder Privacy Policy
                
                1. Information We Collect
                - Account information (email, display name)
                - Recipe preferences and dietary restrictions
                - Recipe interaction data (likes, dislikes)
                
                2. How We Use Your Information
                - To provide personalized recipe recommendations
                - To improve our service
                - To communicate with you about updates
                
                3. Data Storage
                Your data is securely stored using Firebase services.
                
                4. Data Sharing
                We do not sell or share your personal information with third parties.
                
                5. Your Rights
                You have the right to:
                - Access your data
                - Delete your account
                - Export your data
                
                6. Contact Us
                For privacy-related questions, please contact us at support@recipetinder.com
                """)
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CurrentUserProfileView()
            .environmentObject(AuthenticationManager.shared)
    }
}
