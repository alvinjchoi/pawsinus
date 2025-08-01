//
//  DogDetailView.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI

struct DogDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.injected) private var diContainer
    let dog: Dog
    @State private var currentImageIndex = 0
    @State private var isLiked = false
    @State private var showingPlaydateScheduler = false
    @State private var showingAdoptionApplication = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Image carousel
                        imageCarousel
                        
                        // Dog info
                        VStack(alignment: .leading, spacing: 20) {
                        // Name and basic info
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dog.name)
                                    .font(.system(size: 32, weight: .bold))
                                
                                HStack(spacing: 16) {
                                    Label("\(dog.age)세", systemImage: "calendar")
                                    Label(dog.gender == .male ? "남아" : "여아", systemImage: dog.gender == .male ? "mustache" : "heart")
                                    Label(dog.size.displayName, systemImage: "scalemass")
                                }
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Like button
                            Button(action: toggleLike) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 28))
                                    .foregroundColor(isLiked ? .red : .gray)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Bio
                        VStack(alignment: .leading, spacing: 8) {
                            Text("소개")
                                .font(.system(size: 20, weight: .semibold))
                            Text(dog.bio)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal)
                        
                        // Breed info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("품종")
                                .font(.system(size: 20, weight: .semibold))
                            Text(dog.breed)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        // Shelter info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("보호소")
                                .font(.system(size: 20, weight: .semibold))
                            Text(dog.shelterName)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        // Additional info
                        if let personality = dog.personality {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("성격")
                                    .font(.system(size: 20, weight: .semibold))
                                Text(personality)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Health status
                        if let healthStatus = dog.healthStatus {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("건강 상태")
                                    .font(.system(size: 20, weight: .semibold))
                                Text(healthStatus)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Adoption fee
                        VStack(alignment: .leading, spacing: 8) {
                            Text("입양 비용")
                                .font(.system(size: 20, weight: .semibold))
                            Text("무료")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        // Add bottom padding to make room for floating buttons
                        Color.clear
                            .frame(height: 100)
                    }
                }
                }
                
                // Fixed bottom buttons
                VStack {
                    HStack(spacing: 12) {
                        // Playdate button (70%)
                        Button(action: {
                            showingPlaydateScheduler = true
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                Text("놀이 시간 예약")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Adoption button (30%)
                        Button(action: {
                            showingAdoptionApplication = true
                        }) {
                            Text("입양")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                        .frame(width: 100)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                }
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: shareDog) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationBarHidden(false)
        }
        .onAppear {
            checkIfLiked()
        }
        .sheet(isPresented: $showingPlaydateScheduler) {
            PlaydateSchedulingView(dog: dog)
        }
        .sheet(isPresented: $showingAdoptionApplication) {
            AdoptionApplicationView(dog: dog)
        }
    }
    
    private var imageCarousel: some View {
        TabView(selection: $currentImageIndex) {
            ForEach(0..<dog.imageURLs.count, id: \.self) { index in
                AsyncImage(url: URL(string: dog.imageURLs[index])) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 400)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 400)
                        .overlay(
                            ProgressView()
                        )
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 400)
    }
    
    private func checkIfLiked() {
        let likedDogIDs = diContainer.appState[\.userData.likedDogIDs]
        isLiked = likedDogIDs.contains(dog.id)
    }
    
    private func toggleLike() {
        if isLiked {
            // Unlike
            diContainer.appState[\.userData.likedDogIDs].remove(dog.id)
        } else {
            // Like
            diContainer.interactors.dogsInteractor.likeDog(dog)
        }
        isLiked.toggle()
    }
    
    
    private func shareDog() {
        // TODO: Implement share functionality
        // TODO: Implement share functionality
    }
}

#Preview {
    DogDetailsView(dog: Dog.preview)
        .inject(DIContainer(
            appState: AppState(),
            interactors: .stub,
            supabaseClient: SupabaseConfig.client
        ))
}