//
//  ReviewTableViewCell.swift
//  CustomKeyboard
//
//  Created by Mac on 2022/07/12.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    private let profileImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 30
        image.clipsToBounds = true
        image.tintColor = .lightGray
        
        return image
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        
        return label
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.text = "🚨 신고"
        
        return label
    }()
    
    private let starLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        
        return label
    }()
    
    private let reviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    func setup(_ review: Review) {
        layout()
        
        urlToImage(review.user.profileImage, { image in
            self.profileImage.image = image
        })
        nameLabel.text = review.user.userName
        timeLabel.text = dateToTime(review.date)
        starLabel.text = separateStarAndReview(review.content).0.replacingOccurrences(of: "Rating", with: "별점")
        reviewLabel.text = separateStarAndReview(review.content).1.replacingOccurrences(of: "Review", with: "리뷰")
    }
}

extension ReviewTableViewCell {
    func layout() {
        [
            profileImage,
            nameLabel,
            warningLabel,
            starLabel,
            reviewLabel,
            timeLabel
        ].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let inset: CGFloat = 12
        
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: self.topAnchor, constant: inset),
            profileImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset),
            profileImage.widthAnchor.constraint(equalToConstant: 60),
            profileImage.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: inset),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -60),
            
            warningLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            warningLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset),
            
            starLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: inset),
            starLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: inset),
            starLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset),
            
            reviewLabel.topAnchor.constraint(equalTo: starLabel.bottomAnchor, constant: 8),
            reviewLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: inset),
            reviewLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset),
            
            timeLabel.topAnchor.constraint(equalTo: reviewLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: inset),
            timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset),
            timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset),
        ])
    }
    
    private func dateToTime(_ createdAt: Date?) -> String {
        guard let time = createdAt else { return "" }
        let currentTime = Date()
        
        return compareDate(time, currentTime)
    }
    
    private func compareDate(_ time: Date, _ currentTime: Date) -> String {
        let interval = Int(currentTime.timeIntervalSince(time))
        if interval >= 86400 {
            return "\(time.year)년 \(time.month)월 \(time.day)일"
        } else if interval < 3600 {
            return "\(interval / 60)분"
        } else {
            return "\(interval / 3600)시간"
        }
    }
    
    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
    
    private func separateStarAndReview(_ content: String) -> (String, String) {
        let temp = content.components(separatedBy: "\n")
        switch temp.count {
        case 1:
            if temp[0].components(separatedBy: ":").count == 1 {
                return ("별점: ", "리뷰: " + temp[0])
            } else {
                return ("별점: ⭐️⭐️⭐️⭐️⭐️", "리뷰: ")
            }
        case 2:
            return (temp[0], temp[1])
        default:
            return ("별점: ", "리뷰: ")
        }
    }
    
    private func urlToImage(_ url: String, _ completion: @escaping (UIImage) -> Void) {
        guard let imageURL = URL(string: url) else { return }
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: imageURL) { data, response, error in
            guard error == nil,
                  let data = data else { return }
            
            guard let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                completion(image)
            }
        }
        dataTask.resume()
    }
}