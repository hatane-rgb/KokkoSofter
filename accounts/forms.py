from django import forms
from django.contrib.auth.models import User
from .models import UserProfile

class UserProfileForm(forms.ModelForm):
    """ユーザープロフィール編集フォーム"""
    
    class Meta:
        model = UserProfile
        fields = ['avatar', 'bio']
        widgets = {
            'avatar': forms.ClearableFileInput(attrs={
                'class': 'file-input file-input-bordered w-full',
                'accept': 'image/*'
            }),
            'bio': forms.Textarea(attrs={
                'class': 'textarea textarea-bordered w-full',
                'rows': 4,
                'placeholder': '自己紹介を入力してください...'
            }),
        }
        labels = {
            'avatar': 'アバター画像',
            'bio': '自己紹介',
        }

class UserUpdateForm(forms.ModelForm):
    """ユーザー基本情報編集フォーム"""
    
    class Meta:
        model = User
        fields = ['first_name', 'last_name', 'email']
        widgets = {
            'first_name': forms.TextInput(attrs={
                'class': 'input input-bordered w-full',
                'placeholder': '名前'
            }),
            'last_name': forms.TextInput(attrs={
                'class': 'input input-bordered w-full',
                'placeholder': '苗字'
            }),
            'email': forms.EmailInput(attrs={
                'class': 'input input-bordered w-full',
                'placeholder': 'メールアドレス'
            }),
        }
        labels = {
            'first_name': '名前',
            'last_name': '苗字', 
            'email': 'メールアドレス',
        }
