//
//  addPhotoHandler.swift
//  FinalKnife
//
//  Created by Trivedi on 12/11/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit
import Firebase
//extention for add Recipe to select photo
extension AddRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func handleAddPhotoImageView(){
        //Setting up picker
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Select user edited image
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] {
            selecteImageFromPicker = editedImage as? UIImage
            recipePhotoUIImageView.image = selecteImageFromPicker
        }// incase if we dosn't able to get edited image
        else if let originalImage = info[UIImagePickerController.InfoKey.originalImage]{
            selecteImageFromPicker = originalImage as? UIImage
                recipePhotoUIImageView.image = selecteImageFromPicker
        }
        dismiss(animated: true, completion: nil)
    }
}
