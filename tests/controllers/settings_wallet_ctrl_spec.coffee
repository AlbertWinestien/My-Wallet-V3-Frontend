describe "SettingsWalletCtrl", ->
  scope = undefined
  Wallet = undefined
  
  beforeEach angular.mock.module("walletApp")
  
  beforeEach ->
    angular.mock.inject ($injector, $rootScope, $controller) ->
      Wallet = $injector.get("Wallet")
      MyWallet = $injector.get("MyWallet")
      
      spyOn(Wallet, "setLanguage").and.callThrough()
      spyOn(Wallet, "changeLanguage").and.callThrough()
      spyOn(Wallet, "changeCurrency").and.callThrough()
            
      scope = $rootScope.$new()
            
      $controller "SettingsWalletCtrl",
        $scope: scope,
        $stateParams: {},
        
      scope.$digest()
      
      return

    return
    
  describe "language", ->   
    beforeEach ->
      Wallet.login("test", "test")   
      scope.$digest()  
    
    it "should be set on load", inject(() ->
      expect(Wallet.status.isLoggedIn).toBe(true)
      expect(scope.settings.language).toEqual({code: "en", name: "English"})
      return
    )
    
    it "should not spontaniously save", inject((Wallet) ->
      scope.$digest()
      
      expect(Wallet.changeLanguage).not.toHaveBeenCalled()
      
      return
    )
  
    it "should switch to another language", inject((Wallet) ->
        
      expect(scope.languages.length).toBeGreaterThan(1)
      expect(scope.settings.language).not.toBeNull()
      expect(scope.settings.language).not.toEqual(scope.languages[0]) # English is not the first one in the list
    
      # Switch language:
      scope.settings.language = scope.languages[0]
      
      scope.$digest()
    
      expect(Wallet.changeLanguage).toHaveBeenCalledWith(scope.languages[0])
      
      return
    )
    
    return
  
    
  describe "currency", ->   
    beforeEach ->
      Wallet.login("test", "test")  
      scope.$digest()
            
    it "should be set on load", inject((Wallet) ->
      expect(scope.settings.currency.code).toEqual("USD")
    )
    
    it "should not spontaniously save", inject((Wallet) ->
      scope.$digest()
      expect(Wallet.changeCurrency).not.toHaveBeenCalled()
      
      return
    )
  
    it "can be changed", inject((Wallet) ->        
      expect(scope.currencies.length).toBeGreaterThan(1)
      expect(scope.settings.currency).not.toBeNull()
    
      # Switch language:
      scope.settings.currency = scope.currencies[1]
      
      scope.$digest()
    
      expect(Wallet.changeCurrency).toHaveBeenCalledWith(scope.currencies[1])
      
      return
    )
    
    return
    
  describe "2FA", ->
    it "can be disabled", inject((Wallet) ->
      Wallet.login("test-2FA", "test", "123456")
      scope.$digest()
      expect(Wallet.status.isLoggedIn).toBe(true)
      
      spyOn(window, 'confirm').and.callFake(() ->
           return true
      )
        
      spyOn(Wallet, "disableSecondFactor") #.and.callThrough()
      scope.disableSecondFactor()
      expect(Wallet.disableSecondFactor).toHaveBeenCalled()
    )
    
    it "can't be disabled if not enabled", inject((Wallet) ->
      Wallet.login("test", "test")
      scope.$digest()
      expect(Wallet.status.isLoggedIn).toBe(true)
      
      spyOn(Wallet, "disableSecondFactor")
      scope.disableSecondFactor()
      expect(Wallet.disableSecondFactor).not.toHaveBeenCalled()
    )
    
    describe "configure", ->
      beforeEach ->
        Wallet.login("test", "test")
        scope.$digest()
        scope.user.isEmailVerified = true
        scope.user.isMobileVerified = true
    
      it "with sms", inject((Wallet) ->
        spyOn(Wallet, "setTwoFactorSMS")
        scope.setTwoFactorSMS()
        expect(Wallet.setTwoFactorSMS).toHaveBeenCalled()
      )
      
      it "sms can't be enabled if mobile is not verified", inject((Wallet) ->
        scope.user.isMobileVerified = false
        spyOn(Wallet, "setTwoFactorSMS")
        scope.setTwoFactorSMS()
        expect(Wallet.setTwoFactorSMS).not.toHaveBeenCalled()
      )
      
      it "with email", inject((Wallet) ->
        spyOn(Wallet, "setTwoFactorEmail")
        scope.setTwoFactorEmail()
        expect(Wallet.setTwoFactorEmail).toHaveBeenCalled()
      )
      
      it "email can't be enabled if email is not verified", inject((Wallet) ->
        scope.user.isEmailVerified = false
        spyOn(Wallet, "setTwoFactorEmail")
        scope.setTwoFactorEmail()
        expect(Wallet.setTwoFactorEmail).not.toHaveBeenCalled()
      )
      
      it "with Google Authenticator", inject((Wallet) ->
        pending()
      )
      
      return
    
    return
      