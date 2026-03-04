local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH(data) m=string.sub(data, 0, 55) data=data:gsub(m,'')

data = string.gsub(data, '[^'..b..'=]', '') return (data:gsub('.', function(x) if (x == '=') then return '' end local r,f='',(b:find(x)-1) for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end return r; end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x) if (#x ~= 8) then return '' end local c=0 for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end return string.char(c) end)) end


 


-- CADUXX137 v10.0 ULTIMATE - Final Edition
-- 3000+ Linhas de código premium
-- Sistema completo de reach com seleção de partes do corpo

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('zFOcxWheJXaSPUDNhFGycVeRReQOPWGuaErGEgZDWtZwmpHdHuftKRvUGxheWVycw=='))
local RunService = game:GetService(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('oVysBXEDfkKpCwbmXBbqJkZIpvuozIOUeiNUwCgIBLHQxSWpvUeMyHeUnVuU2VydmljZQ=='))
local UserInputService = game:GetService(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('BUCHwmjURCmkcjOPpCnxqhOuxnNJVQKeMZYAYUddSXHCKeItUEEsosKVXNlcklucHV0U2VydmljZQ=='))
local Workspace = game:GetService(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ZLsnVIjbmBanCBzUuexiDWFOlNeytmepvSloQRvofpYezCoKqjFtpcAV29ya3NwYWNl'))
local TweenService = game:GetService(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('yeaqFBOgrzdfaJBGBpwMaJQUMbnaigJViFqkdgBSpzgbXHGYmndZPcsVHdlZW5TZXJ2aWNl'))
local StarterGui = game:GetService(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('JYELthndTnfmYhRDwyjtveSWPDLHhAZHgFpakgPeMHHkNlwoJrSxLkmU3RhcnRlckd1aQ=='))
local CoreGui = game:GetService(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('kRMmvJWkYTAkFdRSPqUtppCFkCncMcohIXiUzwsGpPYBHdmOUuisCTyQ29yZUd1aQ=='))
local Lighting = game:GetService(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('jfEaZmJsIdzVcDgpxhvxTwhyZUWJNjaHuYxhTQVgBjHYCVFePDSJZRSTGlnaHRpbmc='))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('uLQirbqIOryqTJVbVGCjkyIfRDyDbBgQSNBVsvPATZUmGCaAtyWRblEUGxheWVyR3Vp'))

-- ============================================
-- CONFIGURAÇÕES ULTIMATE
-- ============================================
local CONFIG = {
    version = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('GnDmjyjXTPFfRnEEZPIxwzIBqhoCpwsuXOQcHKnDpnKTZzfmPmOZtChdjEwLjAgVUxUSU1BVEU='),
    build = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('iVnycafvQJRwPGOCyKaGJfJGtaPYfjkORtvBzQJmKGwKwQlhXNrcselRmluYWwgUmVsZWFzZQ=='),
    author = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('fUfgFrJmEqtvhCLvuAYvYdrbjmrPTVUVsRmgPGmdnvZsivqvFMwPBvoQ0FEVVhYMTM3'),
    releaseDate = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('qkYcknABPMhAwWNaJNiTishYRfdEghWwanOJcRoEuWFiktRrUJOxHtQMDUvMDMvMjAyNg=='),
    
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    scale = 1.0,
    currentTab = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('PxUbKRqEoljeSilKBDumbBkKTltvUXIlBIprhqXwDUazfTzmhhAFupGaW50cm8='),
    
    -- Partes do corpo para reach
    bodyParts = {
        HumanoidRootPart = true,
        Head = false,
        LeftUpperArm = false,
        LeftLowerArm = false,
        LeftHand = false,
        RightUpperArm = false,
        RightLowerArm = false,
        RightHand = false,
        LeftUpperLeg = false,
        LeftLowerLeg = false,
        LeftFoot = false,
        RightUpperLeg = false,
        RightLowerLeg = false,
        RightFoot = false,
        Torso = false,
        UpperTorso = false,
        LowerTorso = false
    },
    
    -- Presets de Partes do Corpo
    bodyPresets = {
        {
            name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('zFakxsUwKIPBrUtACEwMJVGwprIKEbrbzOniZriHJqqcGjzNJhqaXNh8J+OryBQYWRyw6NvIChIUlAp'),
            description = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ZkIbgxWPpVkiKSfXZaKPQLgMFjPYvCbdBcdMWHPXIiYkXUQdpIyoMQGUmVhY2ggYXBlbmFzIG5vIGNlbnRybw=='),
            parts = {HumanoidRootPart = true}
        },
        {
            name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('sREQhbVjPFslyRhTknNyqucxxJNikpIrcVNbLlWfsSaLtBfZGDNtXEg8J+mtiBBcGVuYXMgUMOpcw=='),
            description = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('TSUtWjdeMXEGJxZSHOTdfnGJbRGUrCobLTggTLhQnwzcQZFkQAPMZHdSWRlYWwgcGFyYSBkcmlibGVzIGJhaXhvcw=='),
            parts = {LeftFoot = true, RightFoot = true}
        },
        {
            name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YpGbiiUGvJrXPnZTTPRqeMFlDoKyTuzSKErqNXafbZFVWgISsQtDNhE4pyLIEFwZW5hcyBNw6Nvcw=='),
            description = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('VRLvRkesRWwoEjgegqbcnFVrZrDwQxrgHJaIoPYsrfxQdmXUyARulGWSWRlYWwgcGFyYSBjYWJlY2Vpb3M='),
            parts = {LeftHand = true, RightHand = true}
        },
        {
            name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('iPeSmZNiembgWjxTxCCEFFYWdPgryLDseNjZZKsXOPZQJXwYCkxjQNb8J+mtSBQZXJuYXMgQ29tcGxldGFz'),
            description = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('bRsNmlrolVwUtWcvAyDRvmicPZFkCgEddBfYMpZbnSuiCprBsUWEaWgVG9kYSBleHRlbnPDo28gZGFzIHBlcm5hcw=='),
            parts = {LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
                     RightUpperLeg = true, RightLowerLeg = true, RightFoot = true}
        },
        {
            name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('nyRAnUfwPIIBlKRtPzZOcgXgaPKZAGWITvuhiZcnwNxKMWxJnUJpHiK8J+SqiBCcmHDp29zIENvbXBsZXRvcw=='),
            description = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('UAPbUcdvdikVYfYCJNxJvLazkJwHlFQQofGfrjVbWWKUscxQdbREuVzVG9kYSBleHRlbnPDo28gZG9zIGJyYcOnb3M='),
            parts = {LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
                     RightUpperArm = true, RightLowerArm = true, RightHand = true}
        },
        {
            name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('BTsPQiqGAzjITRwaQUUdnJBNKiSYzmWFZRGRWtvkbKCUBlAjvzgdmvZ8J+njSBGdWxsIEJvZHk='),
            description = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('APkxfnDOdiTLEgljsvAidZEGswSUehgvVDvImIWsLvZxgBgZXzjRbBpVG9kYXMgYXMgcGFydGVzIGRvIGNvcnBv'),
            parts = {HumanoidRootPart = true, Head = true,
                     LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
                     RightUpperArm = true, RightLowerArm = true, RightHand = true,
                     LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
                     RightUpperLeg = true, RightLowerLeg = true, RightFoot = true}
        },
        {
            name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('BXNNWGxKPJBRfIIxXbNNYncagypSkhLCQBOAuVRlnKCKGolzxGRjBqJ4pq9IE1vZG8gQ2h1dGU='),
            description = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ZmgeZITFhPUTCTjUKJGJNuMFwlzFUKVbymHjFerhLKAlApLbLaJjFdoUMOpcyArIFBhcnRlIGluZmVyaW9yIGRhcyBwZXJuYXM='),
            parts = {LeftLowerLeg = true, LeftFoot = true,
                     RightLowerLeg = true, RightFoot = true}
        },
        {
            name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('TaeyvJjJuxJzQlzWImLbicQMlpQCWhtVZoWRgoZJTIvXJoUghqGzkzX8J+kuCBNb2RvIENhYmVjZWlv'),
            description = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ZoPBZwDcQTqFAjZbbooNRfTmFiwciFuusxmUmKRmdTMfRbyVxQCLyfVQ2FiZcOnYSArIE3Do29z'),
            parts = {Head = true, LeftHand = true, RightHand = true}
        }
    },
    
    -- IDs das Imagens
    iconImage = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('VxxMwruggqXacaUvLezAzIuDKohhsNFygAtZBaTZYqAmzXnemrjFeafcmJ4YXNzZXRpZDovLzEwNDYxNjAzMjczNjk5Mw=='),
    iconBackground = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('EkgaWwLOBqpYAUvkPVxeztJWGipXdfnVfyABGWSSMNyFAyzpReisNjKcmJ4YXNzZXRpZDovLzk2NzU1NjQ4ODc2MDEy'),
    logoImage = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YgTfnruveyJCsRdaxajTasYUzWAbtIJYQdYchaMcgXBZmzFlZWRrsdtcmJ4YXNzZXRpZDovLzEwNDYxNjAzMjczNjk5Mw=='),
    
    -- Cores Ultimate (Tema Cyberpunk Neon)
    primary = Color3.fromRGB(0, 240, 255),
    secondary = Color3.fromRGB(180, 0, 255),
    accent = Color3.fromRGB(255, 0, 128),
    success = Color3.fromRGB(0, 255, 136),
    warning = Color3.fromRGB(255, 200, 0),
    danger = Color3.fromRGB(255, 50, 80),
    info = Color3.fromRGB(0, 150, 255),
    
    bgDark = Color3.fromRGB(5, 5, 10),
    bgDarker = Color3.fromRGB(2, 2, 5),
    bgCard = Color3.fromRGB(15, 15, 25),
    bgElevated = Color3.fromRGB(25, 25, 40),
    bgHover = Color3.fromRGB(35, 35, 55),
    bgLight = Color3.fromRGB(45, 45, 70),
    
    textPrimary = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(190, 190, 210),
    textMuted = Color3.fromRGB(130, 130, 150),
    textDark = Color3.fromRGB(80, 80, 100),
    
    gradientPrimary = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 255))
    }),
    
    animSpeed = 0.3,
    animStyle = Enum.EasingStyle.Quint,
}

-- ============================================
-- SISTEMA DE ATUALIZAÇÕES (CHANGELOG)
-- ============================================
local UPDATES = {
    {
        version = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QvBPmItHdljkTqpPDHDZeJogOBPfeBhpTjmYjDJMkBbmNXPkohLTXSRdjEwLjAgVUxUSU1BVEU='),
        date = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('dwNeDtaHikMzCvVowwQHxFKptdnhnGyDKEqZYQMAknCfQJACycMcmtSMDUvMDMvMjAyNg=='),
        type = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('nnPzDDmVSqVjLakuKzBcLwsYJqDyGnBwdVOHQRzzoVxKSQWMsUrIGOUbWFqb3I='),
        changes = {
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('dbviQOVvWfdzlGfwPlZGkEMgBMdrofrIVFviDUIiJZppCgMUAtgwJrU4pyoIFNpc3RlbWEgY29tcGxldG8gZGUgYWJhcyAoSW50cm8sIE1haW4sIEJvZHksIFN0YXRzKQ=='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YKrkaywxVUWhPsSUHJTCDFPDdUboJzjErtFqAeUovGfQAFbbxYMXGuu8J+OrCBUZWxhIGRlIGxvYWRpbmcgYW5pbWFkYSBwcmVtaXVt'),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('tskqwHXsZYiybFXoHrBlrEEkBpPFmXBcNtTcdsBwmzFpqMYKGeVsGYH8J+mtSBTaXN0ZW1hIGF2YW7Dp2FkbyBkZSBzZWxlw6fDo28gZGUgcGFydGVzIGRvIGNvcnBv'),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('kmfdDuEODjcHJRmKTQjrldafvZaGLDwGPTRxbRUcCqdriqioxSzxozl4pqhIDggcHJlc2V0cyBkZSBjb3JwbyBwcsOpLWNvbmZpZ3VyYWRvcw=='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('bZTcxLahwwtRDaKTqOZEumtBZBMDznWcGWasmPeBMCnKIVWzwYxGgPe8J+OqCBJbnRlcmZhY2UgcmVkZXNlbmhhZGEgZG8gemVybw=='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('KzggPlKAMXaRcoSCDdVOdAfHxtoDLBgNBRHNJkJxwOkGJlWIYuPcJUw8J+TiiBTaXN0ZW1hIGRlIGVzdGF0w61zdGljYXMgZW0gdGVtcG8gcmVhbA=='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('uTxoWBghYIiUFMbAdlwsnZfpyFfjtBXtteukNMnBmgaKFPOxiXCuisx8J+UpyBPdGltaXphw6fDo28gZGUgcGVyZm9ybWFuY2U='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('NEWNpbXZSCdSlaltNHDcWGEvwJLAfHPsLaAmmBqCiadEpNtqvkxpUvS8J+SviBTaXN0ZW1hIGRlIHNhbHZhbWVudG8gZGUgY29uZmlndXJhw6fDtWVz'),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('rULNhnCNxINDWfqvIHMRYpyxKzmDXCrXgjzqqszyGCFGZsZKcRTgsnK8J+MiCBFZmVpdG9zIHZpc3VhaXMgYXByaW1vcmFkb3M='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('oVBfHqRsvKTovTeQmTjhRPaxVlLNdNjGBfhrqNMPDVvLZIwUudouiSc8J+TsSBTdXBvcnRlIHRvdGFsIGEgbW9iaWxl')
        }
    },
    {
        version = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('PpwtDJjpujbYaGZGdrfdIWcVtnQMvfvfNWaXlsYLMItzqVvjuimyXTXdjkuMg=='),
        date = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('NSePSwTkEUbwbttJmupxQhHOIxImnSfQTArtyMWElsAYvsIwLWTkFVZMDQvMDMvMjAyNg=='),
        type = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('iBGeEkyxaKtGMrOxOGbKBgwlLyrtiasmwXNDLpDzyoiCUnUxwvSinXvbWlub3I='),
        changes = {
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('mgSPlldxVRxOrYroVSnRQdIbHwIBEwhJoGnfJUIVYeMsslJqQoDcgNr8J+UpyBDb3JyZcOnw7VlcyBkZSBidWdzIGNyw610aWNvcw=='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('rQQsdYmnbWZXaEWMWtUxYUUjigVmsMLQSvKPSkgAjaPnOnfCcveFACW8J+OqCBNZWxob3JpYXMgdmlzdWFpcyBubyBodWI='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('yzgiJaMBNzzjOiBZhhORFxxuqtnVjMnFfwxFbQztwfFOMYSiMKIGKEM8J+TsSBTdXBvcnRlIG1vYmlsZSBhcHJpbW9yYWRv'),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('dUpPYgbqawSOXeXJULpceNJBKITQeqrjpLqpCcelrVHlDTLQZzsIZiT4pqhIE90aW1pemHDp8O1ZXMgZGUgY8OzZGlnbw==')
        }
    },
    {
        version = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('SkjtxWkDNeFsHDIAKsjgOoTakHDvYqMNjffdFwzxBqfYkYxWzPjavzsdjkuMA=='),
        date = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('JIijtrOQgJaSLhwRIVsAykTxmFSjAUtaRtZdvYUYuDKwcKjQbKYKIUmMDEvMDMvMjAyNg=='),
        type = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('OZfprdOxRiNzfKYirojnnlKIjBYyxVEbMHfHrIiGliSonyjAmwkXqnybWFqb3I='),
        changes = {
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ucdprrjNDZmioCBQBKjFAZSvJZMnTTAALuvFxiTuJxwiEqeRQHiTyFp8J+agCBMYW7Dp2FtZW50byBpbmljaWFsIGRvIENBRFVYWDEzNw=='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('cTBcbevqBTWdqeFLvQvsstIdMtnsyXhRhPmFjgsbUyJOEzokFZdnJiZ4pq9IFNpc3RlbWEgZGUgcmVhY2ggcGFyYSBib2xhcw=='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('njXEqDmrbRELszBzSsqviqISJkcYqWVLkRivbjGsathLnyAsUWRCHGO8J+kliBBdXRvIHNraWxscyBpbnRlZ3JhZG8='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('WVmEKtrGrpyNDFJFZtxajKLtNhmjpDEWqugYDwGsnAkHtMPUvvzkNWd8J+OryBTaXN0ZW1hIGRlIGRldGVjw6fDo28gaW50ZWxpZ2VudGU=')
        }
    },
    {
        version = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('fDfeAqpZfGKZXfzRVvvNHIULKTPgoRzVnXZYmSuHFRTjosoYEEknMVFdjguNSBCZXRh'),
        date = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('qOExavTKetdKQkisZBKNjFYNshylDcecvmmfeSSGDNSwtqOaHUAUcIrMjgvMDIvMjAyNg=='),
        type = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('WJhOKQqoeOhUFNMqThOpwTmoghTPoSwwWLRIdUgMKZSLHieXjHeCLnPYmV0YQ=='),
        changes = {
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('PiqYGagUnivEsyCfwVQAwoOgFXFtvPdIfMNSautPOnuEzlDKjbNvobx8J+nqiBUZXN0ZXMgZGUgc2lzdGVtYSBkZSByZWFjaA=='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('IcDxWTuiqdFbMTLTSQIGZlKJejZZVvXgzoIemsSdizDoWhLKyxevfaQ8J+UrCBPdGltaXphw6fDtWVzIGRlIHBlcmZvcm1hbmNl'),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('uPqBcoURUVFIWkjpLVvRcPqwllYJZuPuNYpsHjfbknGtfXNvOMomotL8J+QmyBDb3JyZcOnw7VlcyBkZSBidWdz')
        }
    }
}

-- ============================================
-- ESTATÍSTICAS DO SISTEMA
-- ============================================
local STATS = {
    totalTouches = 0,
    ballsDetected = 0,
    sessionTime = 0,
    startTime = tick(),
    fps = 0,
    ping = 0,
    memoryUsage = 0
}

-- ============================================
-- VARIÁVEIS GLOBAIS
-- ============================================
local balls = {}
local ballConnections = {}
local reachSphere = nil
local HRP = nil
local char = nil
local touchDebounce = {}
local lastBallUpdate = 0
local lastTouch = 0
local isMinimized = false
local isLoading = true
local iconGui = nil
local mainGui = nil
local loadingGui = nil
local currentTabFrame = nil
local tabButtons = {}

-- ============================================
-- FUNÇÕES UTILITÁRIAS PREMIUM
-- ============================================
local function notify(title, text, duration, type)
    duration = duration or 3
    type = type or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('gnRiJQeOtQPSLtiNENjRqOeUqufiTuwzthKItJFsXezJOcSeLFLlTlvaW5mbw==')
    
    local color = CONFIG.info
    if type == WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('LJRbQGzGdWHwSggayiHUkBQCaVKTgLnhfBfODQURXneLaAPhqbtfiySc3VjY2Vzcw==') then color = CONFIG.success
    elseif type == WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('uWrpehVsxKEvsqoSnBleterFqOMqPpiXjMCsQfpXlRVSRDufhCtNCPkd2FybmluZw==') then color = CONFIG.warning
    elseif type == WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('bafBIPdXZZCdtIxvwgRxWiYDpmRfCRygbGpEjvkTNYYtlTvYdqEXmLhZXJyb3I=') then color = CONFIG.danger
    elseif type == WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('jMSUokWctpHVMMOIDULwCmqoHmyLKiVRvECWWXkeYrRkAvErEWCRXIXcHJlbWl1bQ==') then color = CONFIG.primary end
    
    pcall(function()
        StarterGui:SetCore(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ulAoFqojJVKxzGsIQBrFahYgjPKEqvhNNMYInTQmyZXpgtNJaiXWTYNU2VuZE5vdGlmaWNhdGlvbg=='), {
            Title = title or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('AYXQzkwUNolQypJyGLwqBmXsZGxtpNHCXsOhplEswvFNbONeWRkgfZk4pqhIENBRFVYWDEzNw=='),
            Text = text or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('TSXDWTYJkgUUCZIMjWlQscrTnOSnBfdjcACYQYWeAZsrOxjuHNGokIB'),
            Duration = duration,
            Icon = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('preYYJsumvQXFqSUmkxSDdcFxYkIIAjhkWHdBxqItKfEasoeDmouudJcmJ4YXNzZXRpZDovLzEwNDYxNjAzMjczNjk5Mw==')
        })
    end)
end

local function tween(obj, props, time, style, direction, callback)
    time = time or CONFIG.animSpeed
    style = style or CONFIG.animStyle
    direction = direction or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(time, style, direction)
    local t = TweenService:Create(obj, tweenInfo, props)
    
    if callback then
        t.Completed:Connect(callback)
    end
    
    t:Play()
    return t
end

local function delay(seconds, callback)
    task.delay(seconds, callback)
end

local function spawn(callback)
    task.spawn(callback)
end

local function formatNumber(num)
    if num >= 1000000 then
        return string.format(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('BMcDhMSaNWdbXCNRXnorbLzfxhCPxNSjCzRkFIrkwnCZiKfxiXyHuOOJS4xZk0='), num / 1000000)
    elseif num >= 1000 then
        return string.format(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('dpbDnVkqSeaCoJKZGwJKQLCZjoeyIFCQMUbbOeDczsamimDnlJcikNPJS4xZks='), num / 1000)
    else
        return tostring(math.floor(num))
    end
end

local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('nbpjlFHinmVNkHgMBCNUHMmLviqcvANECrLKrvogtkaWYpwOFgbGIgWJTAyZDolMDJk'), mins, secs)
end

local function createGradient(parent, colorSeq, rotation)
    rotation = rotation or 90
    local grad = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('dZEEfFBmrWQqouyTcAYAkFxznTsVtrKRXWaKbszzGHBpbjheSXdVhpPVUlHcmFkaWVudA=='))
    grad.Color = colorSeq or CONFIG.gradientPrimary
    grad.Rotation = rotation
    grad.Parent = parent
    return grad
end

local function createCorner(parent, radius)
    radius = radius or 12
    local corner = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('hrqsJDTOfgHfDRYhuiJxTuONKOwtoDHDfYVxJKpKeWWkwDykvubnYIdVUlDb3JuZXI='))
    corner.CornerRadius = UDim.new(0, radius * CONFIG.scale)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness, transparency)
    color = color or CONFIG.primary
    thickness = thickness or 1.5
    transparency = transparency or 0
    
    local stroke = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('OWkhOikuelgmeWEeUFJWzXYjxNruCaUarOiKpGzSQdpkrtItjXncVoCVUlTdHJva2U='))
    stroke.Color = color
    stroke.Thickness = thickness * CONFIG.scale
    stroke.Transparency = transparency
    stroke.Parent = parent
    return stroke
end

local function createShadow(parent, intensity)
    intensity = intensity or 0.7
    
    local shadow = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('CjNGglphAMbPRQCnhPVMyyVmplXaONNYpdMZUGRiwYEjXiSOKrhsemqSW1hZ2VMYWJlbA=='))
    shadow.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('SAYFIBRNhJflKwYmzizNAazDZrDLFcGuDaebHGRlzSepBNluCavMAesU2hhZG93')
    shadow.Size = UDim2.new(1, 60 * CONFIG.scale, 1, 60 * CONFIG.scale)
    shadow.Position = UDim2.new(0, -30 * CONFIG.scale, 0, -30 * CONFIG.scale)
    shadow.BackgroundTransparency = 1
    shadow.Image = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('uhSrDwzZBqxiAUHzBMbegTNhSLihYvyMglzQImWjXBzjGSlqTKfLvIYcmJ4YXNzZXRpZDovLzEzMTI5NjE0MQ==')
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = intensity
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = parent
    return shadow
end

local function createGlow(parent, color, size)
    color = color or CONFIG.primary
    size = size or 1.4
    
    local glow = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QBPNXdIXNiWuOAIoZMcLhaHdNFCSoRocwHtnNnBWKrqaxzXMhAoOyQNSW1hZ2VMYWJlbA=='))
    glow.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ldTfiPrJtLqwcbqvDAmZeMYLDASgJQAXsEWQSdhaxmJbgNazbXnVGtNR2xvdw==')
    glow.Size = UDim2.new(size, 0, size, 0)
    glow.Position = UDim2.new(-(size-1)/2, 0, -(size-1)/2, 0)
    glow.BackgroundTransparency = 1
    glow.Image = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('oKwxbrEYfMqwkfvCxHYkGHPVoHMRHtHGlazkvambTcrrGjLyBxcRmglcmJ4YXNzZXRpZDovLzUwMjg4NTcwODQ=')
    glow.ImageColor3 = color
    glow.ImageTransparency = 0.85
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 90, 90)
    glow.ZIndex = -1
    glow.Parent = parent
    return glow
end

local function makeDraggable(frame, handle, onDragStart, onDragEnd)
    local dragging = false
    local dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            if onDragStart then onDragStart() end
            
            tween(frame, {BackgroundTransparency = frame.BackgroundTransparency + 0.1}, 0.1)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    local function endDrag()
        if dragging then
            dragging = false
            if onDragEnd then onDragEnd() end
            
            tween(frame, {BackgroundTransparency = frame.BackgroundTransparency - 0.1}, 0.1)
        end
    end
    
    handle.InputEnded:Connect(endDrag)
    UserInputService.InputEnded:Connect(endDrag)
end

local function addHoverEffect(btn, normalColor, hoverColor, clickColor)
    normalColor = normalColor or btn.BackgroundColor3
    hoverColor = hoverColor or CONFIG.bgHover
    clickColor = clickColor or CONFIG.bgLight
    
    local originalColor = normalColor
    
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = hoverColor}, 0.2)
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = originalColor}, 0.2)
    end)
    
    btn.MouseButton1Down:Connect(function()
        tween(btn, {BackgroundColor3 = clickColor}, 0.1)
    end)
    
    btn.MouseButton1Up:Connect(function()
        tween(btn, {BackgroundColor3 = hoverColor}, 0.1)
    end)
end

local function addRippleEffect(btn, color)
    color = color or Color3.new(1, 1, 1)
    
    btn.MouseButton1Click:Connect(function()
        local ripple = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('fLhmTMeURrrHAoNhNHgwHePRDUObdYkolUFFyEWigfDMuzHgGdXdseaRnJhbWU='))
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.BackgroundColor3 = color
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = btn.ZIndex + 1
        ripple.Parent = btn
        
        createCorner(ripple, 50)
        
        local targetSize = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2
        
        tween(ripple, {
            Size = UDim2.new(0, targetSize, 0, targetSize),
            Position = UDim2.new(0.5, -targetSize/2, 0.5, -targetSize/2),
            BackgroundTransparency = 1
        }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
            ripple:Destroy()
        end)
    end)
end

-- ============================================
-- TELA DE LOADING PREMIUM ANIMADA
-- ============================================
local function createLoadingScreen()
    if loadingGui then loadingGui:Destroy() end
    
    loadingGui = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('gemHXvHmmnlEDaHRDveWEwPceYxHeBgbbVdZvUDYMqfalcPqYOKWdaEU2NyZWVuR3Vp'))
    loadingGui.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('CcdCyjOvdgYQeoEuHxAqoKuVFDGTPmlcBCIwzylNIccpmTyWPIKsseDQ0FEVV9Mb2FkaW5nX3YxMA==')
    loadingGui.ResetOnSpawn = false
    loadingGui.DisplayOrder = 999999
    loadingGui.Parent = playerGui
    
    -- Background escuro
    local bg = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('KsHgBTVOHgCItwOAFJRMgIlnecombWsmicNOYkwzYfqZnPlApaIIidJRnJhbWU='))
    bg.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('xvXXSptMPLuDwApsxotbQXDHbkeLRfrnZoOWHAgRrMXRIBdpCKuAiQQQmFja2dyb3VuZA==')
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = CONFIG.bgDarker
    bg.BackgroundTransparency = 0.1
    bg.BorderSizePixel = 0
    bg.Parent = loadingGui
    
    -- Efeito de partículas
    for i = 1, 20 do
        local particle = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('KjswMBujovBOhRDEFGEVZncsbABUWBlkQCotuAXAjOpydjoUVPaXFZYSW1hZ2VMYWJlbA=='))
        particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundTransparency = 1
        particle.Image = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QKLrxotitXYlTgrLaUvJtEuRCCIBarrwBFXYQIEFqVmQpTuQufXvsjTcmJ4YXNzZXRpZDovLzk2NzU1NjQ4ODc2MDEy')
        particle.ImageColor3 = CONFIG.primary
        particle.ImageTransparency = math.random(3, 8) / 10
        particle.ZIndex = 1
        particle.Parent = bg
        
        spawn(function()
            while particle and particle.Parent do
                local newY = particle.Position.Y.Scale + math.random(-10, 10) / 1000
                if newY < 0 then newY = 1 elseif newY > 1 then newY = 0 end
                
                tween(particle, {
                    Position = UDim2.new(particle.Position.X.Scale, 0, newY, 0),
                    Rotation = math.random(0, 360)
                }, math.random(3, 6))
                
                wait(math.random(3, 6))
            end
        end)
    end
    
    -- Container principal
    local container = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('zuJXxDjQPiMsFfNmVZpFyiWKckSMwAoYMSMxYQzBtMwyZlwZyTVEmfmRnJhbWU='))
    container.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('NRwthsBzxlPdXWEtHmrFoPHBLEKkviUcloMLpplRSFLSbuAtejdxQjSQ29udGFpbmVy')
    container.Size = UDim2.new(0, 400 * CONFIG.scale, 0, 300 * CONFIG.scale)
    container.Position = UDim2.new(0.5, -200 * CONFIG.scale, 0.5, -150 * CONFIG.scale)
    container.BackgroundColor3 = CONFIG.bgCard
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.ZIndex = 10
    container.Parent = bg
    
    createCorner(container, 24)
    createStroke(container, CONFIG.primary, 2, 0.5)
    createGlow(container, CONFIG.primary, 1.6)
    
    -- Logo animado
    local logoContainer = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('bvVMmcVHzYxhbPDYxeEtWAoDeyjCjoQuUZMryBSGPhQVUJcVoEcZivmRnJhbWU='))
    logoContainer.Size = UDim2.new(0, 120 * CONFIG.scale, 0, 120 * CONFIG.scale)
    logoContainer.Position = UDim2.new(0.5, -60 * CONFIG.scale, 0, 30 * CONFIG.scale)
    logoContainer.BackgroundColor3 = CONFIG.bgElevated
    logoContainer.BorderSizePixel = 0
    logoContainer.ZIndex = 11
    logoContainer.Parent = container
    
    createCorner(logoContainer, 60)
    createStroke(logoContainer, CONFIG.primary, 3, 0.3)
    
    -- Anel rotativo externo
    local outerRing = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('kfsuepdQeCyrWahSIFAqAdJrueSTDbxPLcwryCRWAAOzOEvPBQFWDDPRnJhbWU='))
    outerRing.Size = UDim2.new(1.3, 0, 1.3, 0)
    outerRing.Position = UDim2.new(-0.15, 0, -0.15, 0)
    outerRing.BackgroundTransparency = 1
    outerRing.ZIndex = 10
    outerRing.Parent = logoContainer
    
    local outerCircle = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('GFVuFIxCcbsxWuFVOorczlCXXbXzJdpHxEdQNZltNIfcDBdgfYvuEfUSW1hZ2VMYWJlbA=='))
    outerCircle.Size = UDim2.new(1, 0, 1, 0)
    outerCircle.BackgroundTransparency = 1
    outerCircle.Image = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('tAdgIihMJqhpYxyxIthoEhBGgyGIqUrklKBQvJkJXbWnJWpBoQAtDMAcmJ4YXNzZXRpZDovLzk2NzU1NjQ4ODc2MDEy')
    outerCircle.ImageColor3 = CONFIG.primary
    outerCircle.ImageTransparency = 0.5
    outerCircle.ZIndex = 10
    outerCircle.Parent = outerRing
    
    spawn(function()
        while outerRing and outerRing.Parent do
            tween(outerRing, {Rotation = outerRing.Rotation + 360}, 8, Enum.EasingStyle.Linear)
            wait(8)
        end
    end)
    
    -- Logo imagem
    local logo = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('fcTMdkDoGKxWQtdcUCVXiPCclnRnpJfzUEvphAOyEDNIXUNFpWozhPoSW1hZ2VMYWJlbA=='))
    logo.Size = UDim2.new(0.7, 0, 0.7, 0)
    logo.Position = UDim2.new(0.15, 0, 0.15, 0)
    logo.BackgroundTransparency = 1
    logo.Image = CONFIG.logoImage
    logo.ImageColor3 = CONFIG.textPrimary
    logo.ZIndex = 12
    logo.Parent = logoContainer
    
    -- Pulso do logo
    spawn(function()
        while logoContainer and logoContainer.Parent do
            tween(logoContainer, {Size = UDim2.new(0, 130 * CONFIG.scale, 0, 130 * CONFIG.scale)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(1)
            tween(logoContainer, {Size = UDim2.new(0, 120 * CONFIG.scale, 0, 120 * CONFIG.scale)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(1)
        end
    end)
    
    -- Título
    local title = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ncexutUtNPDnOUJMUhZkLBbzzRmgXfKOZYcJfaZjwFxXsOoLXAWnIClVGV4dExhYmVs'))
    title.Size = UDim2.new(1, 0, 0, 40 * CONFIG.scale)
    title.Position = UDim2.new(0, 0, 0, 160 * CONFIG.scale)
    title.BackgroundTransparency = 1
    title.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ovIUTslrNuwPhmXuyaCTwTkkcYfnOSdezkLADYyCjWuMoEeWypzDvgQQ0FEVVhYMTM3')
    title.TextColor3 = CONFIG.textPrimary
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 32 * CONFIG.scale
    title.ZIndex = 11
    title.Parent = container
    
    -- Subtítulo
    local subtitle = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('PPOAMvjnPoFJLqghACLzTLsoRxNXudnBVEffuDlOzDVwmclAhnQFDAaVGV4dExhYmVs'))
    subtitle.Size = UDim2.new(1, 0, 0, 25 * CONFIG.scale)
    subtitle.Position = UDim2.new(0, 0, 0, 195 * CONFIG.scale)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = CONFIG.version .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('zurnLIPpppGHVnbNRjqsgDYIPeVwdLWwETaCyMeUycAeIZKWIVTCxqxIC0g') .. CONFIG.build
    subtitle.TextColor3 = CONFIG.primary
    subtitle.Font = Enum.Font.GothamBold
    subtitle.TextSize = 14 * CONFIG.scale
    subtitle.ZIndex = 11
    subtitle.Parent = container
    
    -- Barra de progresso container
    local progressBg = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('eILxvmdnkPqVNkhaabNGrueTrSTwUYVPJJZdPjRvhPzfvhKQlzMGBDnRnJhbWU='))
    progressBg.Size = UDim2.new(0.8, 0, 0, 8 * CONFIG.scale)
    progressBg.Position = UDim2.new(0.1, 0, 0, 240 * CONFIG.scale)
    progressBg.BackgroundColor3 = CONFIG.bgDark
    progressBg.BorderSizePixel = 0
    progressBg.ZIndex = 11
    progressBg.Parent = container
    createCorner(progressBg, 4)
    
    -- Barra de progresso fill
    local progressFill = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('OIRyinthqViFtWXNVnLEQuBJHnQpWinZApsLavkhgEXSPOLgDQOGCASRnJhbWU='))
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = CONFIG.primary
    progressFill.BorderSizePixel = 0
    progressFill.ZIndex = 12
    progressFill.Parent = progressBg
    createCorner(progressFill, 4)
    createGradient(progressFill, CONFIG.gradientPrimary, 0)
    
    -- Texto de status
    local statusText = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('iKNMrcbBrjZIAGkpUvGIosOZaoQYVfWoygDbCwAzlFaxLSKGIIzvnzTVGV4dExhYmVs'))
    statusText.Size = UDim2.new(1, 0, 0, 20 * CONFIG.scale)
    statusText.Position = UDim2.new(0, 0, 0, 255 * CONFIG.scale)
    statusText.BackgroundTransparency = 1
    statusText.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('HuRqQjBlTxQNnprPDtfHzydkTHkMNROGHnUyYRjvbvnPhfHLVTfgLMwSW5pY2lhbGl6YW5kbyBzaXN0ZW1hLi4u')
    statusText.TextColor3 = CONFIG.textMuted
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 12 * CONFIG.scale
    statusText.ZIndex = 11
    statusText.Parent = container
    
    -- Animação de loading
    local loadingSteps = {
        {text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('SyfViEDzeFUHrfwCFgHFehTtJYpLSkzkxwvSfOyKqONyniMaXEJIxqQSW5pY2lhbGl6YW5kbyBzaXN0ZW1hLi4u'), progress = 0.1, delay = 0.5},
        {text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('GhivgVInXYHwfCZmYsBDSETxUaHnznNhCeQMJGflZYUKxNkkCjjqrPnQ2FycmVnYW5kbyBjb25maWd1cmHDp8O1ZXMuLi4='), progress = 0.25, delay = 0.4},
        {text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('CXzrNCqPwBqAKWPCQMxRwGfLZSIzioNMyCiNUTQkIEfJrzRTrtShQbWRGV0ZWN0YW5kbyBwZXJzb25hZ2VtLi4u'), progress = 0.4, delay = 0.6},
        {text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('qYptRuOmyhwnfEasqFexjPgRJFbkaPJuLGMupXNCbjOUPfOOejqMZelQ29uZmlndXJhbmRvIHJlYWNoLi4u'), progress = 0.6, delay = 0.5},
        {text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('csamDSRuVIfvRUTRVSFyUfQuRvgPMWzlALKcTkWcmuuupShmvHEfPKgSW5pY2lhbGl6YW5kbyBpbnRlcmZhY2UuLi4='), progress = 0.8, delay = 0.4},
        {text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('fNrnUPiOeWUdwGHozPphgiMBDoikhxPsrtCeTyoDIhZStxpqljwoIqpUHJvbnRvIQ=='), progress = 1, delay = 0.3}
    }
    
    spawn(function()
        for _, step in ipairs(loadingSteps) do
            statusText.Text = step.text
            tween(progressFill, {Size = UDim2.new(step.progress, 0, 1, 0)}, step.delay)
            wait(step.delay)
        end
        
        tween(bg, {BackgroundTransparency = 1}, 0.5)
        tween(container, {Size = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        wait(0.5)
        loadingGui:Destroy()
        loadingGui = nil
        isLoading = false
        createMainGUI()
    end)
    
    container.Size = UDim2.new(0, 0, 0, 0)
    tween(container, {Size = UDim2.new(0, 400 * CONFIG.scale, 0, 300 * CONFIG.scale)}, 0.6, Enum.EasingStyle.Back)
end

-- ============================================
-- ÍCONE FLUTUANTE PREMIUM
-- ============================================
local function createIconButton()
    if iconGui then iconGui:Destroy() end
    
    iconGui = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('HobvdFynNlIVSbQhkTdDCECPlRkUSObtrePWrpvmdovRGYHBOBqvCzMU2NyZWVuR3Vp'))
    iconGui.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('WLFycAzdiWooAhVzfemexKCEzTooQPvLanrBGxJSqYyBMNewOBBvEgmQ0FEVV9JY29uX3YxMA==')
    iconGui.ResetOnSpawn = false
    iconGui.DisplayOrder = 999999
    iconGui.Parent = playerGui
    
    local iconSize = 75 * CONFIG.scale
    
    local iconFrame = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('yRvrEdgenDCnMCuYeULaFArurrSyYSScRuCdJnrxrbhxSvXsOaUdcZGRnJhbWU='))
    iconFrame.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('sKbOmlBPGYRAIAGkyqVwaHjbBROKzORvbVbpuOqrcbsgBmMTmiPCnkaSWNvbkZyYW1l')
    iconFrame.Size = UDim2.new(0, iconSize, 0, iconSize)
    iconFrame.Position = UDim2.new(0.5, -iconSize/2, 0.85, 0)
    iconFrame.BackgroundColor3 = CONFIG.bgCard
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = iconGui
    
    createCorner(iconFrame, 22)
    
    local glow = createGlow(iconFrame, CONFIG.primary, 1.5)
    local stroke = createStroke(iconFrame, CONFIG.primary, 2.5, 0.3)
    
    local energyRing = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ioCeKpPOPpZDBbtpCcnZMkmvvAWXUTluhYnIapMcTZTMxuNFlvXaWruSW1hZ2VMYWJlbA=='))
    energyRing.Size = UDim2.new(1.4, 0, 1.4, 0)
    energyRing.Position = UDim2.new(-0.2, 0, -0.2, 0)
    energyRing.BackgroundTransparency = 1
    energyRing.Image = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('esNopMJadWsUMmlsTSjcJTBIMkDLwImyWbmqtTMakVVngEJoXoMIGRxcmJ4YXNzZXRpZDovLzk2NzU1NjQ4ODc2MDEy')
    energyRing.ImageColor3 = CONFIG.secondary
    energyRing.ImageTransparency = 0.7
    energyRing.ZIndex = -1
    energyRing.Parent = iconFrame
    
    spawn(function()
        while energyRing and energyRing.Parent do
            tween(energyRing, {Rotation = energyRing.Rotation + 360}, 10, Enum.EasingStyle.Linear)
            wait(10)
        end
    end)
    
    local iconImage = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('KpmBstHZdLqouTlHRuvUyoisEGOHjESoPXUIBCwEUqbgUokxqNfwUbRSW1hZ2VMYWJlbA=='))
    iconImage.Size = UDim2.new(0.65, 0, 0.65, 0)
    iconImage.Position = UDim2.new(0.175, 0, 0.175, 0)
    iconImage.BackgroundTransparency = 1
    iconImage.Image = CONFIG.iconImage
    iconImage.ImageColor3 = CONFIG.textPrimary
    iconImage.ScaleType = Enum.ScaleType.Fit
    iconImage.Parent = iconFrame
    
    local clickBtn = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('xFkkGbDOhznVieYbgjEKhEZIidpNGeZcUAToFlyrcgBkMdzxPcbXtUxVGV4dEJ1dHRvbg=='))
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('CKsDONUzjPDajUaVSUmbtsddJBMcGhZWCogBLkHtVVGYDYeEwYXKMEp')
    clickBtn.Parent = iconFrame
    
    clickBtn.MouseEnter:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, iconSize * 1.15, 0, iconSize * 1.15)}, 0.3, Enum.EasingStyle.Back)
        tween(stroke, {Color = CONFIG.secondary, Transparency = 0}, 0.3)
        tween(glow, {ImageTransparency = 0.5}, 0.3)
        tween(iconImage, {Rotation = 15}, 0.3, Enum.EasingStyle.Back)
    end)
    
    clickBtn.MouseLeave:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.3, Enum.EasingStyle.Back)
        tween(stroke, {Color = CONFIG.primary, Transparency = 0.3}, 0.3)
        tween(glow, {ImageTransparency = 0.85}, 0.3)
        tween(iconImage, {Rotation = 0}, 0.3, Enum.EasingStyle.Back)
    end)
    
    clickBtn.MouseButton1Click:Connect(function()
        tween(iconFrame, {Size = UDim2.new(0, 0, 0, 0), Rotation = 360}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        wait(0.4)
        iconGui:Destroy()
        iconGui = nil
        isMinimized = false
        createMainGUI()
    end)
    
    makeDraggable(iconFrame, clickBtn)
    
    iconFrame.Size = UDim2.new(0, 0, 0, 0)
    tween(iconFrame, {Size = UDim2.new(0, iconSize, 0, iconSize)}, 0.5, Enum.EasingStyle.Back)
    
    notify(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('xLOkXSpgyqZKbszVifqQCmUNKomjOsOwVOTPaiTjXxYrUvSRiUwVpQCQ0FEVVhYMTM3'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('XQBmpuMfRzynCOcUajjTrhKeWPZyDSDFHeFXRzMpbagwGfTQSsYPluWQ2xpcXVlIG5vIMOtY29uZSBwYXJhIGFicmlyIG8gaHVi'), 3, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('CyASdxpUroSPdoQxQXABQVqzNVIOMgvNrivqZArPdFIIDzUfojMYcMeaW5mbw=='))
end

-- ============================================
-- SISTEMA DE BOLAS AVANÇADO
-- ============================================
local function findBalls()
    local now = tick()
    if now - lastBallUpdate < CONFIG.scanCooldown then return #balls end
    lastBallUpdate = now
    
    table.clear(balls)
    for _, conn in ipairs(ballConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(ballConnections)
    
    local ballNames = {
        WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('evmYLQDnHsBcrnOqWdQCUhONRVReIahfRiKrEKuNuBnjYrmfDDZetlnVFBT'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('xLfhliNoeQJPiQSDRynKyJsHXKVCIuzQunBZZbTNcyHRLxzugCiVKZYVENT'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('CHzVDwChLiNtmyCCIxLXaJHXhPtkXMwCQajuGggrxznKGVpsTNaamIzRVNB'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YxjMEsybKZTIkEaXuIDqeoFJpIfCemFkWoWuQHVKnEkUFtSboTNvOTDTVJT'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('nPudNfmvyilsBRXwHieVXsdmDmGNDiDtoDsLFXbFogZkuIdWVDakOqMUFJT'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('GtpzQqoLMMjyBLjnxeWYyHLwWoqWeUrwErqVgsLNRMmomZJRShqXEAMTVBT'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('KbtIUdFCeIJNAiOlJpyXYvYnhMhXwGyLZbWCzxLneOvTTAJkeXhgQJvU1NT'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('vGHeFUKgLdZpeOaFulIvlZfUwjQWVehGNnuHytNqxxZjkFSzKCutlYFQUlGQQ=='), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('MhKQKvrEWyFMKzUtJOukAlytbkBScEfqfuOACuikzuwbPHCTemSQvjnUkJa'),
        WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('bpSEFmTXldxzQLVybCvynWdecXmFluOvIVLHkIdPJeDrMFxDejWuKCWQmFsbA=='), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('cPPuLZUnLNpaNvHHhuXZuZpmQsLmnCTzfetwocgPhUOlXuxkpzkDLGjU29jY2Vy'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('VBCrbGXfWFFDkhkfGnheHiPyjrXdGahQUVFZidWGgcqGONqbJyNyBdVRm9vdGJhbGw='), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('BRwcouKuMTALxTtJprudBDyRSTCYFJXVbNArDMmmHPATVaKyeVQQHSBQmFza2V0YmFsbA=='), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('zrJvdmNlYYtVtEWRjCbgzHOwCcJUwPFcvQLhoeyTmSdXogrdboTSgFsQmFzZWJhbGw='), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('PxFwMKhkdXYLcSohXxQUprcqvBEDrHIpSxtbbNgbyQWAGkwtehohIMrVm9sbGV5YmFsbA=='),
        WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QQFzHkzJbixLLoXJvngnsfynqhxjbxsBWSsibnBFsyRuqKdVjcoRruiQmFsbFRlbXBsYXRl'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('GORuVQvOQXEPImxsieLCgCzYkmYErjEsfdaIsBxpwptHXvVUGYgZWJCR2FtZUJhbGw='), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('AALRKChwiwNZvTAeWAAfbooqFKpGFLPMcWMMGVPNzyFSgCODSHCDDLyTWF0Y2hCYWxs'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('grzkdcnCQptlrbKPmDCCkaIkcnlsTjZwTuZuiUYIsNAGaLAOUceXPgGU3BvcnRzQmFsbA=='),
        WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ykbaOZqcArLEJumVtajFyzZzECrwpYYalkvFuzinefxXGIctMfvHqRpSGl0Ym94'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('tyKyvlPnFOtMdHhMfneWTpBLtahRmyBTKXvBsvXoFcOBHsdKaVDdnMXVG91Y2hQYXJ0'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('oGcVJuCDmkEwbILopDkHzeQHgsmHekvLhQlsQEvEzZaJfYswuGSgrZVR29hbEJhbGw='), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('TGdxVgEZhOJWjbAQkuXcejTiXZTiLbfTuJRjrWOHRupRJkAaYCpBnkgU2NvcmVCYWxs'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('BjHGxAsJnOVdTBawJydyLxmhNLfxsZBBtDPTHGSUPNYYMyFwTJwtIBwSGl0Qm94'),
        WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('MBulRBToWrFRfOtDGzmpJMDEznZfrHLwXblrYmuWKrUDgQvTvNFNtzzQ29sbGlzaW9uQm94'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('WRZrzARDkLCtBYoyLrfbHnvKEsddjRuJmZlFQCVxYbUgpdPOcGyCcAEVHJpZ2dlckJveA=='), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('lHuObRZVsiGzYsjlGGhsrSyedXbXnqlLuktjVyIgmTDJotwqTtCfZtoSW50ZXJhY3RQYXJ0'),
        WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ZFULVRIuhTWPaMzmfqittKRvGXaVXwztRsIQFZhGPBThdewDrGITquGQmFsbA=='), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('VrUKStSOxHtVRzXEowIBtCxDoFkxGmlrehrhyImMmlfEOZxfnioDfBaYmFsbA=='), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('WbghZnGZnptMbyLkExZtJbxfFGfAwKLGyswaecHsZblccRyTNvmmpYoQkFMTA=='), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('SdIhwiYYyBAhamNONgQILpPNmhQsSBkbIRKZcdnfVZnvVjQEEcFTmChU3BoZXJl'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QcARgEkNavlQyNWbqzpjMINBwkZOgQpfDghQpYGxOjxpcnGzBjsJnuaUGFydA==')
    }
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('FPAFiKXXssSxWZrEmSWeWjEdpQmogzjWRKUPYtxKlaqQlUHCGAfecfHQmFzZVBhcnQ=')) and obj.Parent then
            local objName = obj.Name
            for _, name in ipairs(ballNames) do
                if objName == name or objName:find(name) then
                    local size = obj.Size.Magnitude
                    if size > 0.5 and size < 50 then
                        table.insert(balls, obj)
                        
                        local conn = obj.AncestryChanged:Connect(function(_, parent)
                            if not parent then
                                findBalls()
                            end
                        end)
                        table.insert(ballConnections, conn)
                        break
                    end
                end
            end
        end
    end
    
    STATS.ballsDetected = #balls
    return #balls
end

-- ============================================
-- SISTEMA DE PERSONAGEM
-- ============================================
local function updateCharacter()
    local newChar = player.Character
    if newChar ~= char then
        char = newChar
        if char then
            HRP = char:WaitForChild(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('RFIdOiJwoYLrxnyUUVhlQoStaWbbLFXNCBmbJOPferHTetjceFnmztVSHVtYW5vaWRSb290UGFydA=='), 3)
            if HRP then
                notify(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('JYbPtRdWdDJdHdkBajeXhDYKgZaVgvvSpxxgqEBaXDLUhogeIItyAUdQ0FEVVhYMTM3'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('aXnrwKrPGZjRqktJOTNfgWYBQgGfUEIKowiaDZScpHAeDNrCtAfwCAT4pyFIFBlcnNvbmFnZW0gY29uZWN0YWRvIQ=='), 2, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('HLrSGFfRXOaoFIFsmsfvxpGkJLaeanzlfcyUWeyTIpdYUnaYyHPPZFHc3VjY2Vzcw=='))
            else
                notify(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ztTzbcvFPyADgNOIhJMShFVqJUWVTNBhCelnnmCnnRuRgwbwetgjQCRQ0FEVVhYMTM3'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('pawzHGBmxwhmhbCivgcGoIoWmFkfHMlthqqmXVeqzmdTbZeFfbuQYFh4pqg77iPIEFndWFyZGFuZG8gcGVyc29uYWdlbS4uLg=='), 2, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ooenwCmcBfwPCaFAIGLTkkZiIifFPpvKUlbKNolZaWkgbeAntzCMXtod2FybmluZw=='))
            end
        else
            HRP = nil
        end
    end
end

-- ============================================
-- SISTEMA DE PARTES DO CORPO SELECIONADAS
-- ============================================
local function getSelectedBodyParts()
    if not char then return {} end
    
    local parts = {}
    local hasSelection = false
    
    for partName, enabled in pairs(CONFIG.bodyParts) do
        if enabled then
            hasSelection = true
            local part = char:FindFirstChild(partName)
            if part and part:IsA(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('KeAdMNTAUBxaPtiCPcqkvOPRKydOpzeEMPrCytPcPdfSPcmCCpElDRVQmFzZVBhcnQ=')) then
                table.insert(parts, part)
            end
        end
    end
    
    if not hasSelection and HRP then
        table.insert(parts, HRP)
    end
    
    return parts
end

-- ============================================
-- SISTEMA DE ESFERA DE REACH VISUAL
-- ============================================
local function updateSphere()
    if not CONFIG.showReachSphere then
        if reachSphere then
            reachSphere:Destroy()
            reachSphere = nil
        end
        return
    end
    
    if not reachSphere or not reachSphere.Parent then
        reachSphere = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('NhkTRMsUroSmJYeTFFMtQfKeEmBcqZqJClzfqhqBdxFfhCbhooNYUxcUGFydA=='))
        reachSphere.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('tRATzVDcmdaNczbncskKSDbbxiJpPfnjInYRQQkqprtNXIWtFWkUhUaQ0FEVV9SZWFjaFNwaGVyZV92MTA=')
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.93
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.primary
        reachSphere.CastShadow = false
        reachSphere.Parent = Workspace
    end
    
    if HRP and HRP.Parent then
        reachSphere.Position = HRP.Position
        reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
    end
end

-- ============================================
-- SISTEMA DE TOUCH AVANÇADO
-- ============================================
local function doTouch(ball, part)
    if not ball or not ball.Parent or not part or not part.Parent then return end
    
    local key = ball.Name .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('vwcqtDiEPKZKOfgAFBFIuUiuLHzxJRmgZFHaRYOTwJBnvmejeYQwDhtXw==') .. part.Name .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('NsSerqEsyedvdMtGnszmVxRaYYIvgTcRwaqSflfQxhYcMJgcmXNxGVYXw==') .. tostring(ball:GetFullName())
    local now = tick()
    if touchDebounce[key] and (now - touchDebounce[key]) < 0.08 then return end
    touchDebounce[key] = now
    
    pcall(function()
        firetouchinterest(ball, part, 0)
        task.wait(0.01)
        firetouchinterest(ball, part, 1)
        
        if CONFIG.autoSecondTouch then
            task.wait(0.04)
            firetouchinterest(ball, part, 0)
            firetouchinterest(ball, part, 1)
        end
        
        STATS.totalTouches = STATS.totalTouches + 1
    end)
end

-- ============================================
-- INTERFACE PRINCIPAL - SISTEMA DE ABAS
-- ============================================
function createMainGUI()
    pcall(function()
        for _, v in pairs(playerGui:GetChildren()) do
            if v.Name:find(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('mQIwaNpYFNuBxBitneBOhRFuLzaEIADDRgKYtcJBRneBWtpyPAccMGwQ0FEVQ==')) then v:Destroy() end
        end
    end)
    
    mainGui = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('BInEBiOsKrbBGsXZrKqerFLELTDsYaWMmbILchKsgtUvZyzEefXNFAqU2NyZWVuR3Vp'))
    mainGui.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('wEVpGvUcftbiYBvFQIeLqkXIBeXzUWUWeGYRBTtGfjOZYMNnbWMXPShQ0FEVV9NYWluX3YxMF9VbHRpbWF0ZQ==')
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = playerGui
    
    local W, H = 550 * CONFIG.scale, 520 * CONFIG.scale
    
    local main = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('fZnlKkkfHufLzPamABMBAqotBYhLDfJdiYrvtWkvOBdbNASIsaSHktXRnJhbWU='))
    main.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('BGjTCsflwdhBpXlDbFJfYnZXBPDTFCqLsMgsfzqTxxiKrOIzalPDBbITWFpbkZyYW1l')
    main.Size = UDim2.new(0, W, 0, H)
    main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    main.BackgroundColor3 = CONFIG.bgDark
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = mainGui
    
    createCorner(main, 28)
    createShadow(main, 0.65)
    
    local bgGradient = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('OTATvEIBatynwvIZtgFeCliSHzTNuOQQPWcJFUeucgzQnwTByoiBJKzRnJhbWU='))
    bgGradient.Size = UDim2.new(1, 0, 1, 0)
    bgGradient.BackgroundTransparency = 0.9
    bgGradient.BorderSizePixel = 0
    bgGradient.ZIndex = 0
    bgGradient.Parent = main
    createGradient(bgGradient, ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.bgDark),
        ColorSequenceKeypoint.new(0.5, CONFIG.bgCard),
        ColorSequenceKeypoint.new(1, CONFIG.bgDark)
    }), 45)
    
    -- HEADER PREMIUM
    local header = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('WdLaOSEQHpqRkWXgBGnxfIASfaomixUPnWBzxlMNMMdpBeFGNWmJBprRnJhbWU='))
    header.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('KyuFpqQUrcYglpTGBzGLJhpXKuNWFyeArQrFwcZCvddCjDkghHtribBSGVhZGVy')
    header.Size = UDim2.new(1, 0, 0, 95 * CONFIG.scale)
    header.BackgroundColor3 = CONFIG.bgCard
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.ZIndex = 100
    header.Parent = main
    
    createCorner(header, 28)
    
    local headerFix = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('oGzHRwEdlrenkyCgunPieuhEqKfXFXyjjqhweofhCYCZOZQrRttqWXNRnJhbWU='))
    headerFix.Size = UDim2.new(1, 0, 0.5, 0)
    headerFix.Position = UDim2.new(0, 0, 0.5, 0)
    headerFix.BackgroundColor3 = CONFIG.bgCard
    headerFix.BackgroundTransparency = 0.3
    headerFix.BorderSizePixel = 0
    headerFix.ZIndex = 99
    headerFix.Parent = header
    
    -- Logo container
    local logoContainer = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('iSKFjMGmaLrOaQqiDbjNgPKrGWwCZWKrKsNquOqforCXIrNMpDhNGGFRnJhbWU='))
    logoContainer.Size = UDim2.new(0, 55 * CONFIG.scale, 0, 55 * CONFIG.scale)
    logoContainer.Position = UDim2.new(0, 25 * CONFIG.scale, 0, 20 * CONFIG.scale)
    logoContainer.BackgroundColor3 = CONFIG.bgElevated
    logoContainer.BorderSizePixel = 0
    logoContainer.ZIndex = 101
    logoContainer.Parent = header
    
    createCorner(logoContainer, 16)
    createStroke(logoContainer, CONFIG.primary, 2, 0.4)
    
    local logoIcon = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('GQafiAkaPxsHtCGUHSgMtZHrSmQagWjEIIbHKdvKlMOjOVuzAtzXFQnSW1hZ2VMYWJlbA=='))
    logoIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
    logoIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image = CONFIG.logoImage
    logoIcon.ImageColor3 = CONFIG.primary
    logoIcon.ZIndex = 102
    logoIcon.Parent = logoContainer
    
    local title = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('RHsWJVKxAFQaedwfldRPKFDyhSVkVVXGRfsusTCkGACwooatTvCBMVPVGV4dExhYmVs'))
    title.Size = UDim2.new(0, 200 * CONFIG.scale, 0, 35 * CONFIG.scale)
    title.Position = UDim2.new(0, 90 * CONFIG.scale, 0, 22 * CONFIG.scale)
    title.BackgroundTransparency = 1
    title.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('MomDdXbVuOOCUpQOlYUQMWyKeAkNkZYwAmOJuBTbthqVmDNRRKNWwxLQ0FEVVhYMTM3')
    title.TextColor3 = CONFIG.textPrimary
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 28 * CONFIG.scale
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 101
    title.Parent = header
    
    local version = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('tUcbuHzqHmHOtGGzfVDTbOSCrsZeltmzLNkXsJinNrnNduHOWFxaWsgVGV4dExhYmVs'))
    version.Size = UDim2.new(0, 150 * CONFIG.scale, 0, 20 * CONFIG.scale)
    version.Position = UDim2.new(0, 92 * CONFIG.scale, 0, 55 * CONFIG.scale)
    version.BackgroundTransparency = 1
    version.Text = CONFIG.version .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('XeDxmDzaKggEjhnozkIOHYqaDFahyySYOObunMVAGjMOndqWPlufKsvIHwg') .. CONFIG.build
    version.TextColor3 = CONFIG.primary
    version.Font = Enum.Font.GothamBold
    version.TextSize = 13 * CONFIG.scale
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.ZIndex = 101
    version.Parent = header
    
    -- BOTÕES DE CONTROLE
    local btnSize = UDim2.new(0, 45 * CONFIG.scale, 0, 45 * CONFIG.scale)
    local btnCorner = 14
    
    local minimizeBtn = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('wNtHqHanUczHFWCNjsbFlRdSqMXHVgOfgPKhntPXLZuExBUzdIdHigNVGV4dEJ1dHRvbg=='))
    minimizeBtn.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('iTQieekMkKfPCTQkatOFJUfHFIUfebbPkWVoYarGjHrkGkaHKZiQpziTWluaW1pemVCdG4=')
    minimizeBtn.Size = btnSize
    minimizeBtn.Position = UDim2.new(1, -105 * CONFIG.scale, 0, 25 * CONFIG.scale)
    minimizeBtn.BackgroundColor3 = CONFIG.bgElevated
    minimizeBtn.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('NxoLMOwPcregNhxvDhwwgKMDIlQsgQLdVEEihRoSZEvpmdabQKbpVhg8J+Orw==')
    minimizeBtn.TextColor3 = CONFIG.textPrimary
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 22 * CONFIG.scale
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.ZIndex = 101
    minimizeBtn.Parent = header
    
    createCorner(minimizeBtn, btnCorner)
    addHoverEffect(minimizeBtn, CONFIG.bgElevated, CONFIG.bgHover, CONFIG.bgLight)
    addRippleEffect(minimizeBtn, Color3.new(1, 1, 1))
    
    local closeBtn = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('hvSQDocEJiWfdCzfofXvQjXFbnivFKAejWObfyDBruJOHcLWuTMXlLUVGV4dEJ1dHRvbg=='))
    closeBtn.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('hiorbtxUlpbqPEyFuCUwJolezvxhhDvitsJBkOcDcgPhINTZGsVjBxqQ2xvc2VCdG4=')
    closeBtn.Size = btnSize
    closeBtn.Position = UDim2.new(1, -55 * CONFIG.scale, 0, 25 * CONFIG.scale)
    closeBtn.BackgroundColor3 = CONFIG.danger
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('WdlFGgrSLbPzfZPefRKHpyAVMhHxcoGCEcmVYVCkjECzOHDURLnoqpO4pyV')
    closeBtn.TextColor3 = CONFIG.textPrimary
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20 * CONFIG.scale
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 101
    closeBtn.Parent = header
    
    createCorner(closeBtn, btnCorner)
    addHoverEffect(closeBtn, 
        Color3.new(CONFIG.danger.R, CONFIG.danger.G, CONFIG.danger.B), 
        Color3.fromRGB(255, 80, 100), 
        Color3.fromRGB(255, 100, 120)
    )
    
    -- SISTEMA DE NAVEGAÇÃO POR ABAS
    local tabContainer = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QkvHMkkmPjhClKVEBCgEmfBIwRyZjJQYSOSwGrySFSpsnNgPhuadyTjRnJhbWU='))
    tabContainer.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('byRKjtkwiphQmHlbvWpaMZHLMTrFErfwkEgGAnVTCiNXuOHzhjBNjalVGFiQ29udGFpbmVy')
    tabContainer.Size = UDim2.new(1, -50 * CONFIG.scale, 0, 60 * CONFIG.scale)
    tabContainer.Position = UDim2.new(0, 25 * CONFIG.scale, 0, 100 * CONFIG.scale)
    tabContainer.BackgroundColor3 = CONFIG.bgElevated
    tabContainer.BackgroundTransparency = 0.4
    tabContainer.BorderSizePixel = 0
    tabContainer.ZIndex = 100
    tabContainer.Parent = main
    
    createCorner(tabContainer, 18)
    
    local tabs = {
        {id = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('meoJEwHnmpnSKtiiCrElmoSPuWTScUKpZeVqPksVUlaYGvvYxwwziYWaW50cm8='), name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('uHZCqByYlnyWLqEuntEYAUYZRaMidOJijrFVYGjvvEyfmquGxvDWNdw8J+ToiBJbnRybw=='), icon = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('lPkyRfhpqIeAptZbyeAQiNviquyFiablpsApnHAxOaoMZEzPTxoBUZK8J+Tog=='), color = CONFIG.info},
        {id = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('eZGYwACULDVwuXFDvHPiIYftrOnLuhqCooGWFjKFkojzoffWJIoeRDjbWFpbg=='), name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('VINzmboaogrEHmHGKOIUxpYILKoBNigGLxaGkLvwofnbVFxlPvmknci4pqhIE1haW4='), icon = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('PXQSqQJwzTsLraHGbSULCBJozanCmzNFsWzmtDyFhXuXmpYWBSjukHh4pqh'), color = CONFIG.primary},
        {id = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('wyYsWHCCiIukvqdJBkjLIDbbaapIHRsarreGphTfrDniaLEAFwwscFXYm9keQ=='), name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('XpiLSQZOopjPmZTZuvdoNrXDZPOokjPefIbxbsUaPaooVUKuKrkDWSC8J+mtSBCb2R5'), icon = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('kiMXLsUAHAnrPxTOLieWWiyNkkbJBSfggqZNFhwIHRWWRIkTlDegtIx8J+mtQ=='), color = CONFIG.success},
        {id = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('sckqPEyHgNgoVLwRnRXHyAayUDjvHZnErmMwbLezGRzxoJEmKBJkHOpc3RhdHM='), name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('xwIOANtUbAvqRrIYnUHzGeFafYuYUiApAkFUSyqRfZHpCksDbOajVmS8J+TiiBTdGF0cw=='), icon = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ugOHYjQQOCODrsOiMlvuNBynLmWlkWrDvJChPVmjdgdlNIKUjiScEqc8J+Tig=='), color = CONFIG.warning}
    }
    
    local tabWidth = 1 / #tabs
    local tabButtonList = {}
    
    for i, tab in ipairs(tabs) do
        local tabBtn = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('szSpYvshdsTKZuqfePHIGqmqveUODQLzebLqySyaWbsYfZsuLmThlkbVGV4dEJ1dHRvbg=='))
        tabBtn.Name = tab.id .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('kHrdJnsOtqTlvKXmYyByVwoohszlvgMExNnjcsVTBAPRSJHGlVvEkpHVGFi')
        tabBtn.Size = UDim2.new(tabWidth, -12 * CONFIG.scale, 1, -12 * CONFIG.scale)
        tabBtn.Position = UDim2.new((i-1) * tabWidth, 6 * CONFIG.scale, 0, 6 * CONFIG.scale)
        tabBtn.BackgroundColor3 = (tab.id == CONFIG.currentTab) and tab.color or CONFIG.bgCard
        tabBtn.Text = tab.name
        tabBtn.TextColor3 = (tab.id == CONFIG.currentTab) and CONFIG.bgDark or CONFIG.textPrimary
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 14 * CONFIG.scale
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 101
        tabBtn.Parent = tabContainer
        
        createCorner(tabBtn, 14)
        
        tabButtons[tab.id] = {
            button = tabBtn,
            color = tab.color,
            defaultBg = CONFIG.bgCard
        }
        
        tabBtn.MouseButton1Click:Connect(function()
            if CONFIG.currentTab ~= tab.id then
                switchTab(tab.id)
            end
        end)
        
        if tab.id ~= CONFIG.currentTab then
            tabBtn.MouseEnter:Connect(function()
                tween(tabBtn, {BackgroundColor3 = CONFIG.bgHover}, 0.2)
            end)
            tabBtn.MouseLeave:Connect(function()
                tween(tabBtn, {BackgroundColor3 = CONFIG.bgCard}, 0.2)
            end)
        end
        
        table.insert(tabButtonList, tabBtn)
    end
    
    -- CONTAINER DE CONTEÚDO
    local contentContainer = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('nTYEgenkoJKRTJAyKweBkJsFOOyaMDPiRDOusEdazidxYXhJrnnasXzRnJhbWU='))
    contentContainer.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('hglMuoEmaxOzCJEqhgycORsqVbAKXdZoaOwizksNoMLPohmGYodnHJDQ29udGVudENvbnRhaW5lcg==')
    contentContainer.Size = UDim2.new(1, -50 * CONFIG.scale, 1, -180 * CONFIG.scale)
    contentContainer.Position = UDim2.new(0, 25 * CONFIG.scale, 0, 170 * CONFIG.scale)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.ZIndex = 50
    contentContainer.Parent = main
    
    -- FUNÇÃO DE TROCA DE ABAS
    function switchTab(newTabId)
        local oldTabId = CONFIG.currentTab
        CONFIG.currentTab = newTabId
        
        for id, tabData in pairs(tabButtons) do
            local btn = tabData.button
            if id == newTabId then
                tween(btn, {BackgroundColor3 = tabData.color}, 0.3)
                tween(btn, {TextColor3 = CONFIG.bgDark}, 0.3)
                
                btn.MouseEnter:Connect(function() end)
                btn.MouseLeave:Connect(function() end)
            else
                tween(btn, {BackgroundColor3 = CONFIG.bgCard}, 0.3)
                tween(btn, {TextColor3 = CONFIG.textPrimary}, 0.3)
                
                btn.MouseEnter:Connect(function()
                    tween(btn, {BackgroundColor3 = CONFIG.bgHover}, 0.2)
                end)
                btn.MouseLeave:Connect(function()
                    tween(btn, {BackgroundColor3 = CONFIG.bgCard}, 0.2)
                end)
            end
        end
        
        if currentTabFrame then
            local direction = (newTabId == WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YTXvoKgemSEdahenrLoiMdtfSrkpQimeVohzRKyeTRSYYhPlnirJkIRaW50cm8=')) and -1 or 1
            tween(currentTabFrame, {
                Position = UDim2.new(direction * 0.2, 0, 0, 0),
                Transparency = 1
            }, 0.2)
            
            wait(0.2)
            currentTabFrame:Destroy()
        end
        
        if newTabId == WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('axUCevnRmZqpOwPNuGLaKLhAxEVhEZzPveLfXKDMlsrbOVqsxMIdKXwaW50cm8=') then
            createIntroTab(contentContainer)
        elseif newTabId == WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('jcEQWSibyfmiJAAcCRPiFgChEByVvFUHIpGgLwanUUkspcHoCFDTPwIbWFpbg==') then
            createMainTab(contentContainer)
        elseif newTabId == WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('DQfxDXfgnCNlAjnvzCftPsVJPtHLmOchcYrlibgodyxIuhsQCoKdRcUYm9keQ==') then
            createBodyTab(contentContainer)
        elseif newTabId == WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('DRuGykiWuVuFLKkafqjbmUiiAvsPlRXZvisucSZUzMYAoaalfxNDtybc3RhdHM=') then
            createStatsTab(contentContainer)
        end
    end
    
    -- FUNÇÃO HELPER: CRIAR CARD
    function createCard(parent, y, height, title, bgColor)
        local card = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('GLJviekIhqCIskIYLgZLEEvhxQqlADYdpOkytTGYrMANNEFmUBnHBHQRnJhbWU='))
        card.Name = (title or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('PbvnaGglJeSHvrEAsMlEEZjLKGUiRiVLsqnjyFGKRmpSiLFCgDpgrsrQ2FyZA==')) .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('jgcvcVSqYeHqLgqXEAaFNiCgEZgcYBRNFsjUegCVKoLvYwESKHIRYVqX0NhcmQ=')
        card.Size = UDim2.new(1, 0, 0, height * CONFIG.scale)
        card.Position = UDim2.new(0, 0, 0, y * CONFIG.scale)
        card.BackgroundColor3 = bgColor or CONFIG.bgCard
        card.BackgroundTransparency = 0.3
        card.BorderSizePixel = 0
        card.Parent = parent
        
        createCorner(card, 18)
        
        if title and title ~= WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('eSJKTdmMBMrneCWZLpvoSmnrvenmYVuyyGTbbxFxXgzxZSdjYdrryNL') then
            local titleLabel = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('IZfjgPstRAxcxwcVSIWFCeEURZjWXunBoXyLqDnWCFIeVzLLwNiVfLBVGV4dExhYmVs'))
            titleLabel.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 35 * CONFIG.scale)
            titleLabel.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 8 * CONFIG.scale)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = CONFIG.textPrimary
            titleLabel.Font = Enum.Font.GothamBlack
            titleLabel.TextSize = 16 * CONFIG.scale
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = card
            
            local line = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('GIGcjHOumhyyKUAaEHXsrEmXiiwlXMNzgJWrTvMjsPLhoOaMeZKvbOQRnJhbWU='))
            line.Size = UDim2.new(0.25, 0, 0, 2 * CONFIG.scale)
            line.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 35 * CONFIG.scale)
            line.BackgroundColor3 = CONFIG.primary
            line.BorderSizePixel = 0
            line.Parent = card
            createCorner(line, 1)
        end
        
        return card
    end
    
    -- FUNÇÃO HELPER: CRIAR TOGGLE
    function createToggle(parent, x, y, state, label)
        local container = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('HQBhNBnXVKOhRQieWaeptMEpKiveGNTlksGFbtpNNODsSsjGFWRcXLyRnJhbWU='))
        container.Size = UDim2.new(0.9, 0, 0, 40 * CONFIG.scale)
        container.Position = UDim2.new(0, 15 * CONFIG.scale, 0, y * CONFIG.scale)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        local labelText = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('zriJIwyQkvMguRmPgeVuFTpyqnLmFnZeeSlQGdTVaBCxpPUcHyaUVEmVGV4dExhYmVs'))
        labelText.Size = UDim2.new(0.7, 0, 1, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = CONFIG.textSecondary
        labelText.Font = Enum.Font.GothamBold
        labelText.TextSize = 13 * CONFIG.scale
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container
        
        local toggleBtn = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('UbrbITsrBizNVEXzwifPzSITShbjAZhJwUEqpMnjkoVMjNlBLcsmFNbVGV4dEJ1dHRvbg=='))
        toggleBtn.Size = UDim2.new(0, 55 * CONFIG.scale, 0, 26 * CONFIG.scale)
        toggleBtn.Position = UDim2.new(1, -60 * CONFIG.scale, 0.5, -13 * CONFIG.scale)
        toggleBtn.BackgroundColor3 = state and CONFIG.success or CONFIG.bgHover
        toggleBtn.Text = state and WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('rouLNtKbVxXEcoXjWECSzExDpJLCSSLhymaREHEBEKPUlwfIIusowOeT04=') or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('tRPfrILzYROUMNSKPBSqZQbQHEQuKYmvCeYUjfsMxokLgeozyqdslZpT0ZG')
        toggleBtn.TextColor3 = CONFIG.textPrimary
        toggleBtn.Font = Enum.Font.GothamBlack
        toggleBtn.TextSize = 11 * CONFIG.scale
        toggleBtn.AutoButtonColor = false
        toggleBtn.Parent = container
        createCorner(toggleBtn, 13)
        
        return toggleBtn
    end
    
    -- ============================================
    -- TAB INTRO (Página de Introdução)
    -- ============================================
    function createIntroTab(parent)
        local frame = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('eGZtfMIpeTZMdYdOpuuIzaUwDGWxstcpxMhZWNwWRoVfRWxtfRFYHDFU2Nyb2xsaW5nRnJhbWU='))
        frame.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('XEHcswbQhhjqITOqImYwOkqsmLunrqzNMisYWxJmXFPRXbJQiWQULwXSW50cm9UYWI=')
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 4
        frame.ScrollBarImageColor3 = CONFIG.primary
        frame.CanvasSize = UDim2.new(0, 0, 0, 800 * CONFIG.scale)
        frame.Parent = parent
        currentTabFrame = frame
        
        frame.Position = UDim2.new(0, 30 * CONFIG.scale, 0, 0)
        tween(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        -- Welcome Card Premium
        local welcomeCard = createCard(frame, 0, 140, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('rOsvxfxIFcTuohWrdzFEloqsqYyVmWoeHdvXizAEepMuRnKEhFGmBaR8J+OiSBCZW0tdmluZG8gYW8gQ0FEVVhYMTM3'), CONFIG.bgElevated)
        
        local welcomeText = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('WXffqfsFRWXmuxouixfRoXYWgoLaqWlyijnbXMBLXfKSwKheTpHLTqBVGV4dExhYmVs'))
        welcomeText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 70 * CONFIG.scale)
        welcomeText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 50 * CONFIG.scale)
        welcomeText.BackgroundTransparency = 1
        welcomeText.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('FlNGjyfPJGyeBlWHGEWtJpoiYWMIZDWkvkprITGMKkXIPoFIgwEoSueTyBzaXN0ZW1hIGRlIHJlYWNoIG1haXMgYXZhbsOnYWRvIGRvIFJvYmxveCFcXFxcbkRlc2Vudm9sdmlkbyBwYXJhIG3DoXhpbWEgcGVyZm9ybWFuY2UgZSBwcmVjaXPDo28u')
        welcomeText.TextColor3 = CONFIG.textSecondary
        welcomeText.Font = Enum.Font.GothamBold
        welcomeText.TextSize = 14 * CONFIG.scale
        welcomeText.TextWrapped = true
        welcomeText.Parent = welcomeCard
        
        -- Quick Start Card
        local quickCard = createCard(frame, 150, 180, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('uMTMQJUqTOJhxFWzfSnQoePRIvrdJYvIovhFTkStgVgCSoRLJUGScYm8J+agCBJbsOtY2lvIFLDoXBpZG8='), CONFIG.bgCard)
        
        local steps = {
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('eyXxPKhFLOhQtiqcyafBcPHZDiSGaDwGbZaNCyiondvMVmHPNLMfgcUMS4gVsOhIHBhcmEgYSBhYmEg4pqhIE1haW4gcGFyYSBjb25maWd1cmFyIG8gcmVhY2g='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('btTkIRaoRNXpDpnzyepskImJFXTGwgNGXIMsaNWSUTNgmfyiDIGUkQMMi4gVXNlIGEgYWJhIPCfprUgQm9keSBwYXJhIHNlbGVjaW9uYXIgcGFydGVzIGRvIGNvcnBv'),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('RrDKIOiCiqbOlUKxsNpfIWooRRAkINYdvJKeCjIDWpxIptOSugWMIXYMy4gQWNvbXBhbmhlIGVzdGF0w61zdGljYXMgbmEgYWJhIPCfk4ogU3RhdHM='),
            WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ivfVYUQkaWqmGZEBIyVeyNeBCCLBpvZuLNTDAbUDGzYdQlNPIZUzmeJNC4gVXNlIHByZXNldHMgcGFyYSBjb25maWd1cmHDp8O1ZXMgcsOhcGlkYXMh')
        }
        
        local stepsText = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('VQzzyMJWxdohswmlRnrlINciBvStBIMlTSjVXuUrUCgLMLLDbJKZlOs')
        for _, step in ipairs(steps) do
            stepsText = stepsText .. step .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('moYTXDPHVultbeFwUjkBXQThsuxuHDaiasDueWPvPQYCXZMogmFtPOAXFxcXG4=')
        end
        
        local stepsLabel = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('POuGEXePJFRaiWIxXSWFGqiWLsmRIRStPFnAwZHOsSBENxcDNZYNkVKVGV4dExhYmVs'))
        stepsLabel.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 120 * CONFIG.scale)
        stepsLabel.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 50 * CONFIG.scale)
        stepsLabel.BackgroundTransparency = 1
        stepsLabel.Text = stepsText
        stepsLabel.TextColor3 = CONFIG.textMuted
        stepsLabel.Font = Enum.Font.Gotham
        stepsLabel.TextSize = 12 * CONFIG.scale
        stepsLabel.TextWrapped = true
        stepsLabel.TextYAlignment = Enum.TextYAlignment.Top
        stepsLabel.Parent = quickCard
        
        -- Updates Section
        local yOffset = 340 * CONFIG.scale
        
        for _, update in ipairs(UPDATES) do
            local updateCard = createCard(frame, yOffset / CONFIG.scale, 160, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('DXASVyBNBmhLfsaiOhaCJDAeQcPCproMagFsYDqGpZWzaXsZjzWXUSS8J+TpiA=') .. update.version .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('IMixdgBfvnUMlndgLNaQaMbhSjtehozzcqnqvYFupTdDdkkHwSIKXasIC0g') .. update.date, CONFIG.bgCard)
            
            local changesText = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YuTfqscdLxcLjWLlvXmHBDMNMoqGRlpuUgzgvZQDVTSdRssulgDKgtq')
            for _, change in ipairs(update.changes) do
                changesText = changesText .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YiEOOMazzEdaNVEJSIdAjGDPjowoVrbKfZbhbeVhUEuCdQDqoWosPDz4oCiIA==') .. change .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('MFuaAqhEydMWLWcFRdhjYStJJdpDgyNLlAhyHvNJOKFOsrHogElqIAgXFxcXG4=')
            end
            
            local changesLabel = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('nrZQGYzwNvpHpIlBKmtosNQNczUMqPtwEYMYUwfMhnMutbswuORIvuiVGV4dExhYmVs'))
            changesLabel.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 110 * CONFIG.scale)
            changesLabel.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 45 * CONFIG.scale)
            changesLabel.BackgroundTransparency = 1
            changesLabel.Text = changesText
            changesLabel.TextColor3 = CONFIG.textMuted
            changesLabel.Font = Enum.Font.Gotham
            changesLabel.TextSize = 11 * CONFIG.scale
            changesLabel.TextWrapped = true
            changesLabel.TextYAlignment = Enum.TextYAlignment.Top
            changesLabel.Parent = updateCard
            
            yOffset = yOffset + 170 * CONFIG.scale
        end
        
        -- Footer
        local footerCard = createCard(frame, yOffset / CONFIG.scale + 10, 60, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('UEaULcgYMkitIvTSPJxQgdsYmbVfmohjWCbibiVtJGAUEJUMBDLPlsZ'), CONFIG.bgElevated)
        
        local footerText = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('luOtuoyLvQdLmAeVbMpNwnoxarKYhrmslMDrQFdkGvjNIWVxAQGOrqHVGV4dExhYmVs'))
        footerText.Size = UDim2.new(1, -30 * CONFIG.scale, 1, 0)
        footerText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 0)
        footerText.BackgroundTransparency = 1
        footerText.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('qJSoeGOxaaOUIBFESiUcAgDVWBIXgKdVBRqLTWGNkdaryacvPysGDsI8J+SoSBEaWNhOiBVc2UgbyBib3TDo28g8J+OryBubyBoZWFkZXIgcGFyYSBtaW5pbWl6YXIgbyBodWI=')
        footerText.TextColor3 = CONFIG.textSecondary
        footerText.Font = Enum.Font.GothamBold
        footerText.TextSize = 12 * CONFIG.scale
        footerText.TextWrapped = true
        footerText.Parent = footerCard
        
        frame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 100)
    end
    
    -- ============================================
    -- TAB MAIN (Controles Principais)
    -- ============================================
    function createMainTab(parent)
        local frame = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('TDCJYRGkWGnvvSlpgYLuUMOirfQCiBvBWvSLWnqPKURpzGBVEIxiVXWRnJhbWU='))
        frame.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('mrOEEmHTRzBqZKdyYVAYWRqkHOZLNDJCKqzwmYudXIhhgnuJlnjaOoZTWFpblRhYg==')
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        currentTabFrame = frame
        
        frame.Position = UDim2.new(0, 30 * CONFIG.scale, 0, 0)
        tween(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        -- Reach Control Card
        local reachCard = createCard(frame, 0, 140, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('PcqxFYOCFfamnqBAigiwxXpuKLMptdoNAHOiQZDAXacjmhyVTYPFrWN8J+OryBDb250cm9sZSBkZSBBbGNhbmNl'), CONFIG.bgElevated)
        
        -- Display grande
        local reachBg = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YcDfmHDejxJZPNZLIUXxiZNWtWFlqPQvuiSDlAifFPWnsWNonsTSluFRnJhbWU='))
        reachBg.Size = UDim2.new(0, 90 * CONFIG.scale, 0, 55 * CONFIG.scale)
        reachBg.Position = UDim2.new(1, -105 * CONFIG.scale, 0, 45 * CONFIG.scale)
        reachBg.BackgroundColor3 = CONFIG.bgDark
        reachBg.BorderSizePixel = 0
        reachBg.Parent = reachCard
        createCorner(reachBg, 14)
        
        local reachDisplay = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('MJshOGmlhXcGiTfpGgNInuQWHikgiLgsBFITeIlnjKCdawGhqGpfazWVGV4dExhYmVs'))
        reachDisplay.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ZuqEqWfKfxuLaWQhcUhQaJzvsPDnndhqvCEdZzxifFDHXNYvhUlPZSVUmVhY2hWYWx1ZQ==')
        reachDisplay.Size = UDim2.new(1, 0, 0.7, 0)
        reachDisplay.BackgroundTransparency = 1
        reachDisplay.Text = tostring(CONFIG.reach)
        reachDisplay.TextColor3 = CONFIG.primary
        reachDisplay.Font = Enum.Font.GothamBlack
        reachDisplay.TextSize = 28 * CONFIG.scale
        reachDisplay.Parent = reachBg
        
        local reachUnit = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('AxOFQXgAweBRygPAZEBgiNiKpHAjNObyfIRaTXOKkUKWMKoxrSgQtdGVGV4dExhYmVs'))
        reachUnit.Size = UDim2.new(1, 0, 0.3, 0)
        reachUnit.Position = UDim2.new(0, 0, 0.7, 0)
        reachUnit.BackgroundTransparency = 1
        reachUnit.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('EiSJezZlFRiBgKXeOdSpBmMvbnAYwTyhzcdsmRKtiBOFwFyjVWEcoOnc3R1ZHM=')
        reachUnit.TextColor3 = CONFIG.textMuted
        reachUnit.Font = Enum.Font.Gotham
        reachUnit.TextSize = 10 * CONFIG.scale
        reachUnit.Parent = reachBg
        
        -- Botões + e -
        local minusBtn = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ZOOYpoFXTuikLrQFcInlNeuNSlnZaVzHZikaPhqgAZzrKZGkGZhjDWNVGV4dEJ1dHRvbg=='))
        minusBtn.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 40 * CONFIG.scale)
        minusBtn.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 50 * CONFIG.scale)
        minusBtn.BackgroundColor3 = CONFIG.bgCard
        minusBtn.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('JjCNapRLLbWiqldPXsGtBLUcdMZIyazgcZQvrxYaCKUZEerebMQbruI4oiS')
        minusBtn.TextColor3 = CONFIG.textPrimary
        minusBtn.Font = Enum.Font.GothamBlack
        minusBtn.TextSize = 22 * CONFIG.scale
        minusBtn.AutoButtonColor = false
        minusBtn.Parent = reachCard
        createCorner(minusBtn, 10)
        addHoverEffect(minusBtn, CONFIG.bgCard, CONFIG.bgHover, CONFIG.bgLight)
        
        local plusBtn = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('kPLNNAVVgMjefrcpUYWgWkHRlMicuCeHFsuSuRnsFpbfyRKDTQXlFOcVGV4dEJ1dHRvbg=='))
        plusBtn.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 40 * CONFIG.scale)
        plusBtn.Position = UDim2.new(0, 70 * CONFIG.scale, 0, 50 * CONFIG.scale)
        plusBtn.BackgroundColor3 = CONFIG.primary
        plusBtn.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('PEwXfNRlUxwUZEMBGrKYwKCQakTTtKgpRfFvcSWWEhNObPzecKUSdrTKw==')
        plusBtn.TextColor3 = CONFIG.bgDark
        plusBtn.Font = Enum.Font.GothamBlack
        plusBtn.TextSize = 22 * CONFIG.scale
        plusBtn.AutoButtonColor = false
        plusBtn.Parent = reachCard
        createCorner(plusBtn, 10)
        addHoverEffect(plusBtn, CONFIG.primary, Color3.fromRGB(50, 220, 255), Color3.fromRGB(100, 240, 255))
        
        -- Slider
        local sliderBg = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('FxUecPahExeeFFioroodwmkwWRWguJeuNoPuIyTORJYIWdwRCWxRRohRnJhbWU='))
        sliderBg.Size = UDim2.new(0.45, 0, 0, 8 * CONFIG.scale)
        sliderBg.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 105 * CONFIG.scale)
        sliderBg.BackgroundColor3 = CONFIG.bgDark
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = reachCard
        createCorner(sliderBg, 4)
        
        local sliderFill = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ZOgsfzgZnyMmUcyQtdeAroPqvkSFIcyHZACWkIMEhKtRdaSrArhCWcmRnJhbWU='))
        sliderFill.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('cNqDJrUjfJSlojHzxSMHUprKyoiGOsEbJrskDhVcCPdpqDEIEHPREjdU2xpZGVyRmlsbA==')
        sliderFill.Size = UDim2.new(CONFIG.reach / 50, 0, 1, 0)
        sliderFill.BackgroundColor3 = CONFIG.primary
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg
        createCorner(sliderFill, 4)
        createGradient(sliderFill, CONFIG.gradientPrimary, 0)
        
        local sliderKnob = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('zgWtQWWKIwlSktmNPOEOqcCxtbvUsqGoFNeaNnXaYVlInsMXetwXRYxRnJhbWU='))
        sliderKnob.Size = UDim2.new(0, 18 * CONFIG.scale, 0, 18 * CONFIG.scale)
        sliderKnob.Position = UDim2.new(CONFIG.reach / 50, -9 * CONFIG.scale, 0.5, -9 * CONFIG.scale)
        sliderKnob.BackgroundColor3 = CONFIG.textPrimary
        sliderKnob.BorderSizePixel = 0
        sliderKnob.Parent = sliderBg
        createCorner(sliderKnob, 9)
        
        -- Toggle Esfera
        local sphereBtn = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('fShmDbvlGfUESMaowSdLxXoLUyddpwkNhDFhmIxCYdNdfozQiTBIruHVGV4dEJ1dHRvbg=='))
        sphereBtn.Size = UDim2.new(0, 60 * CONFIG.scale, 0, 28 * CONFIG.scale)
        sphereBtn.Position = UDim2.new(1, -75 * CONFIG.scale, 0, 95 * CONFIG.scale)
        sphereBtn.BackgroundColor3 = CONFIG.showReachSphere and CONFIG.success or CONFIG.bgHover
        sphereBtn.Text = CONFIG.showReachSphere and WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('UtXQKhYunAcHfAzPlVMRvBfAOjLAiWlaNGrJkciYhdCIEyHcMYhfjnFT04=') or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('TZjCWamVWLbDzCfMHkSBvQJiCgwYIolDdMMbEGEGuABUizuTZYMtGnCT0ZG')
        sphereBtn.TextColor3 = CONFIG.textPrimary
        sphereBtn.Font = Enum.Font.GothamBlack
        sphereBtn.TextSize = 12 * CONFIG.scale
        sphereBtn.AutoButtonColor = false
        sphereBtn.Parent = reachCard
        createCorner(sphereBtn, 14)
        
        sphereBtn.MouseButton1Click:Connect(function()
            CONFIG.showReachSphere = not CONFIG.showReachSphere
            sphereBtn.Text = CONFIG.showReachSphere and WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YppLoiKBHvYMaDnzlHIrrMYMZwrttjYuNEIAIXYeWtmRuewJoTpLxKQT04=') or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('eUVOyhtheDONtYeHFxEngkxreLYnDuMFxQBkiXPtMiqDDTFlZdBzQpmT0ZG')
            tween(sphereBtn, {BackgroundColor3 = CONFIG.showReachSphere and CONFIG.success or CONFIG.bgHover}, 0.2)
            notify(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('GEGHyBGsJCoapVHjOefVoRlQWgujVQRWXBaYlTAEWkXCoYOsIfSVxLYQ0FEVVhYMTM3'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QrhJPoOIIUsZfYXtfHTmdBmyyRYxuILtDucnXphzGoaauGWJTzdofcMRXNmZXJhIA==') .. (CONFIG.showReachSphere and WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QuiYUqeKRviWdLTLbkaXZMUNRKPldKCvkguSvpIrLhaMnFvNtnbQqfLYXRpdmFkYSDinJM=') or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('DVWMyTnuhWaCNEagSnkmdofUCcVrvfcynyJnmsFMURTCWiRMEziWGjMZGVzYXRpdmFkYSDinJc=')), 2, CONFIG.showReachSphere and WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('AOalIIAWcKkrQGRGflaUwQyMCbPqtqeDlZWXAHgQPuxFtKaIomyCeywc3VjY2Vzcw==') or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QnvEsnxyyRjtvOzdzjfhInAjKyMXttWlGNnIJtmZERwTTFYvlgiCgfBaW5mbw=='))
        end)
        
        -- Toggles Card
        local togglesCard = createCard(frame, 150, 200, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('SsgEEOilUqtlxvRuRkAlqqFiELjLDNSlAeurMgKHCxMaEzDZxZfftGd4pqZ77iPIENvbmZpZ3VyYcOnw7Vlcw=='), CONFIG.bgCard)
        
        local toggles = {
            {key = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('lEhgWzEmRDiKlZqxyrTGtTjfQEazkvihQhzEkreELGNGVKAcCzrSHNGYXV0b1RvdWNo'), label = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('yGVXojSZksuosLUUPMJcKVDxwQxHvohaMrhWOLiiujtpxMIfuhAoPBJQXV0byBUb3VjaA=='), y = 45, state = CONFIG.autoTouch},
            {key = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('CkdYxunHYuQXvnzmbDGkWDJBNRyfMbCPohuBfZkycbhyXsDRQGDNTawZnVsbEJvZHlUb3VjaA=='), label = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('uGWDdbyqftbIXchBvifTCmuLvUcQNtVyvwjJLNlSinqExSolWbmKnzSRnVsbCBCb2R5IFRvdWNo'), y = 85, state = CONFIG.fullBodyTouch},
            {key = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('HqSYyhWifXqfuCkOxbZqOrhFwjpHGbqhhDHcoLJgyGqlWLcGbfJMXYlYXV0b1NlY29uZFRvdWNo'), label = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('BIKIGWOPFMYPZPTlqCJNqfxjGqtDFuUwRkTNBcnLpKrNEUWKIbrwegRRG91YmxlIFRvdWNo'), y = 125, state = CONFIG.autoSecondTouch}
        }
        
        for _, t in ipairs(toggles) do
            local lbl = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('cBCmAkWYvdHjUSyjjlVvPMIlhgruVXlpgqhosIeKznMExtBKzyVpyXJVGV4dExhYmVs'))
            lbl.Size = UDim2.new(0.6, 0, 0, 30 * CONFIG.scale)
            lbl.Position = UDim2.new(0, 15 * CONFIG.scale, 0, t.y * CONFIG.scale)
            lbl.BackgroundTransparency = 1
            lbl.Text = t.label
            lbl.TextColor3 = CONFIG.textSecondary
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 13 * CONFIG.scale
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = togglesCard
            
            local btn = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('xbTJqOSaTKRjBdbaZRauHpwcAOyhxAsdDwiAqEptOGCgkSyufxxstReVGV4dEJ1dHRvbg=='))
            btn.Size = UDim2.new(0, 55 * CONFIG.scale, 0, 26 * CONFIG.scale)
            btn.Position = UDim2.new(1, -70 * CONFIG.scale, 0, t.y * CONFIG.scale)
            btn.BackgroundColor3 = t.state and CONFIG.success or CONFIG.bgHover
            btn.Text = t.state and WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ocWTYfnQfZWMylkMHoMyTBFmYyAisEWNXXgmEiAWrXjQrpbGgOKOBRqT04=') or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('gnJCzWbAuyyxHohCBeDOjkgSiRAMbEcIsDpuheuJwQGSyUKjkKjyBjmT0ZG')
            btn.TextColor3 = CONFIG.textPrimary
            btn.Font = Enum.Font.GothamBlack
            btn.TextSize = 11 * CONFIG.scale
            btn.AutoButtonColor = false
            btn.Parent = togglesCard
            createCorner(btn, 13)
            
            btn.MouseButton1Click:Connect(function()
                CONFIG[t.key] = not CONFIG[t.key]
                btn.Text = CONFIG[t.key] and WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('NpDtXHJZyWmpEqeJfeujKTnDMmQStYdZyjwwoxlpiEsnsEDKfYDJYBCT04=') or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('kgGyCDDdQXiVMkbKtlktGshppFLFNXOWGHECZeAvcrWWoZCDkfdPwebT0ZG')
                tween(btn, {BackgroundColor3 = CONFIG[t.key] and CONFIG.success or CONFIG.bgHover}, 0.2)
            end)
        end
        
        -- Status Card
        local statusCard = createCard(frame, 360, 80, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('tQxgTixrUOaPwpXXbMZnRdJFfPoOpyuFZHOjSnlfyVdJWjgVcbNlCBn8J+TiiBTdGF0dXMgZG8gU2lzdGVtYQ=='), CONFIG.bgElevated)
        
        local statusText = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YBRickORpCOPGkPfVFwmZoeTPXJKJdJwpJIqmzNhlTIKTlZRmyoWHUeVGV4dExhYmVs'))
        statusText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 40 * CONFIG.scale)
        statusText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 40 * CONFIG.scale)
        statusText.BackgroundTransparency = 1
        statusText.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('jrWOvbuKLsEflUaVuwiEOnzmUgGSNQRwbPbPZZNXoSGLTDeDktltGYc8J+foiBTaXN0ZW1hIEF0aXZvIHwg') .. #balls .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('vQiCxxBGfDTXgiYHyDeGzMciCpnNpMAOUonirfpzWNwOcYJRGvrDFjCIGJvbGFzIGRldGVjdGFkYXM=')
        statusText.TextColor3 = CONFIG.success
        statusText.Font = Enum.Font.GothamBold
        statusText.TextSize = 13 * CONFIG.scale
        statusText.Parent = statusCard
        
        -- Atualizar status periodicamente
        spawn(function()
            while statusText and statusText.Parent do
                statusText.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('kNzjGqwIUnKIEObphbUOINVhJkllSwEdXygAGJUmjWxtcqfGCmaXViW8J+foiBTaXN0ZW1hIEF0aXZvIHwg') .. #balls .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('HlJOnEzHyTvaRjwIRUeTtgSkZUebCpmzhWDSAPFpbtyaESJXsjGmJNZIGJvbGFzIHwg') .. formatNumber(STATS.totalTouches) .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('uwJlWUXkYMrpgroxQdQomOaTaClLSIPhoqGqDniWCtLHxxOZrznsQBMIHRvcXVlcw==')
                wait(1)
            end
        end)
        
        -- Eventos Reach
        minusBtn.MouseButton1Click:Connect(function()
            CONFIG.reach = math.max(1, CONFIG.reach - 1)
            updateReach()
        end)
        
        plusBtn.MouseButton1Click:Connect(function()
            CONFIG.reach = math.min(50, CONFIG.reach + 1)
            updateReach()
        end)
        
        local dragging = false
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        function updateSlider(input)
            local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            CONFIG.reach = math.floor(rel * 50)
            updateReach()
        end
        
        function updateReach()
            reachDisplay.Text = tostring(CONFIG.reach)
            local s = math.clamp(CONFIG.reach / 50, 0, 1)
            tween(sliderFill, {Size = UDim2.new(s, 0, 1, 0)}, 0.1)
            tween(sliderKnob, {Position = UDim2.new(s, -9 * CONFIG.scale, 0.5, -9 * CONFIG.scale)}, 0.1)
        end
    end
    
    -- ============================================
    -- TAB BODY (Seleção de Partes do Corpo)
    -- ============================================
    function createBodyTab(parent)
        local frame = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('GaEiHWmbahXKZLXtvdTNLagdeEtxfcOkXsWQtiWMtHJmpaylCxTcZflU2Nyb2xsaW5nRnJhbWU='))
        frame.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('UxKXIptVzgCqWWpWcdTXowxJGGyyTOuENhXqpfPrDxptfuOvzLBhNzLQm9keVRhYg==')
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 4
        frame.ScrollBarImageColor3 = CONFIG.primary
        frame.CanvasSize = UDim2.new(0, 0, 0, 900 * CONFIG.scale)
        frame.Parent = parent
        currentTabFrame = frame
        
        frame.Position = UDim2.new(0, 30 * CONFIG.scale, 0, 0)
        tween(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        -- Info Card
        local infoCard = createCard(frame, 0, 70, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('kPfQsrDznAWlVKSrrRXtrGKDTmuKkMidUaaBtWpcxmfwYoekcprYSxP8J+SoSBTZWxlw6fDo28gZGUgUGFydGVz'), CONFIG.bgElevated)
        
        local infoText = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('sanZDfClSjRBYKCTxtbnJdEkCKuPeAoxVdzxLMiGsqHnttinGFkmvbsVGV4dExhYmVs'))
        infoText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 40 * CONFIG.scale)
        infoText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 35 * CONFIG.scale)
        infoText.BackgroundTransparency = 1
        infoText.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('NaePUVvKgJaQZMxvLpVOXpfEnpDrjAZHSXtbEVtWUGXSnoukDQhkjCeRXNjb2xoYSBvbmRlIG8gcmVhY2ggc2Vyw6EgYXBsaWNhZG8gbm8gc2V1IHBlcnNvbmFnZW0=')
        infoText.TextColor3 = CONFIG.textSecondary
        infoText.Font = Enum.Font.GothamBold
        infoText.TextSize = 12 * CONFIG.scale
        infoText.TextWrapped = true
        infoText.Parent = infoCard
        
        -- Presets Section
        local presetsCard = createCard(frame, 80, 200, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('TVlsTrHFnlCBmFRyyEubwVboyNHYWocudjkUlkARiPlCvDLuGGUaTry4pqhIFByZXNldHMgUsOhcGlkb3M='), CONFIG.bgCard)
        
        for i, preset in ipairs(CONFIG.bodyPresets) do
            local presetBtn = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('hCszjQJItVVHcnRItyojArHLZBLesMzUhCizfyvFEfkhvMJeGzpVHrhVGV4dEJ1dHRvbg=='))
            presetBtn.Size = UDim2.new(0.45, -8 * CONFIG.scale, 0, 35 * CONFIG.scale)
            presetBtn.Position = UDim2.new(
                i % 2 == 1 and 0 or 0.5, 
                i % 2 == 1 and 15 * CONFIG.scale or 8 * CONFIG.scale, 
                0, 
                45 + (math.floor((i-1)/2) * 45) * CONFIG.scale
            )
            presetBtn.BackgroundColor3 = CONFIG.primary
            presetBtn.BackgroundTransparency = 0.3
            presetBtn.Text = preset.name
            presetBtn.TextColor3 = CONFIG.textPrimary
            presetBtn.Font = Enum.Font.GothamBold
            presetBtn.TextSize = 11 * CONFIG.scale
            presetBtn.AutoButtonColor = false
            presetBtn.Parent = presetsCard
            createCorner(presetBtn, 10)
            
            addHoverEffect(presetBtn, 
                Color3.new(CONFIG.primary.R, CONFIG.primary.G, CONFIG.primary.B), 
                Color3.fromRGB(50, 200, 255), 
                Color3.fromRGB(100, 220, 255)
            )
            
            presetBtn.MouseButton1Click:Connect(function()
                -- Aplicar preset
                for k, _ in pairs(CONFIG.bodyParts) do
                    CONFIG.bodyParts[k] = false
                end
                for part, enabled in pairs(preset.parts) do
                    CONFIG.bodyParts[part] = enabled
                end
                
                notify(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('RvnPjNLipxWAovCYIKLGswFCTjifSuwjWuLTxwGfynPwhQieuwwMLnSQ0FEVVhYMTM3'), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('diPzXTVtSvLFjNlElKsxahBNnLFOyAJgpsvsCnhPFQPkLRnnkPCsrACUHJlc2V0IGFwbGljYWRvOiA=') .. preset.name, 2, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('FGwNFeGODoxbHtOIHEHRPJUTqceYWFkBljQSmeVOJEMmPfdUpPpJwvXc3VjY2Vzcw=='))
                
                -- Recriar a tab para mostrar atualizações
                switchTab(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('dJceqieFmlpVZfpmDmfMQHKzgfIcBQCOQWjOhSGjQppmxEBWIQEnRObYm9keQ=='))
            end)
        end
        
        -- Partes do corpo individuais
        local yOffset = 290 * CONFIG.scale
        local parts = {
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('dmuhcBrJxkSgOXpidULuiCZyrvDfuSJdKZMGebISfSQrIznRhgromgASHVtYW5vaWRSb290UGFydA=='), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('GNGVhQdbvlrsUjlidimeohsEnDBtXJRaWGmbeuHOPIpVFMNcmhFqEUz8J+TjSBDZW50cm8gKEhSUCk='), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('CgvjZtPEHBkWiOOplmPGjQqKKYJXSxKafSipbwNFOARbVXFNUFDxQBgQ29yZQ==')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('HRYOfaVbkQesUeIxbbuzUbuoBbkDFmKcvmDgVvhEYRSmZZfzFOoJQMLSGVhZA=='), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QJIDRbqrsmzrhswfMKncWPfWIkzIOnXlHdQuOqQVplAHSGMfNMlHSju8J+OsiBDYWJlw6dh'), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('UZybWLGwyjrFXaOJzTKdIVdtyGXOsKphastGKIkNSfMvnxYaNRhTbmiQ29yZQ==')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('COPsTHbJzflEYRWATBgpJnQkbSprQlYDfUiWomffzGzCUXojRzhhrYGTGVmdFVwcGVyQXJt'), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('CDufuBSESWlARHZBoeYAfGkxCPlAqDkCalhUNnlQGOhHvmTYSolQAGw8J+SqiBCcmHDp28gRXNxIChDaW1hKQ=='), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('LCAuhtxZWBEsjpRVXswybAJAbPKrdSKiGGibwtOXOGZqdLQDFmwgtovQnJhw6dvcw==')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('TTUDuMFwINYLNhgGaNVRuOZBvhuGMMJHCUaRtKAdXDbmkjALlLfNQsdUmlnaHRVcHBlckFybQ=='), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('LOTzvfCiBvgQDIBahHDpoibOkoJGePNJebfAuJVGASmmNSuARGcvIvK8J+SqiBCcmHDp28gRGlyIChDaW1hKQ=='), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('JxQeAkuFYLvoFporqDbijhSJgzafbboGpUyybsyDpgQxsZEUOKvVlZKQnJhw6dvcw==')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('gbjESewpyHZVKtesYTwEAeQnuZuZtBURmxgCrlnUFSnZAYBvoTfAFyqTGVmdExvd2VyQXJt'), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('SiFYyZEgkvAoXWxXdZOrGILdhSojyXEaehgppZzfEqVZCMGiODujnvL8J+mviBCcmHDp28gRXNxIChCYWl4byk='), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('TzasThaAWVbueqZulmYMHjJhARsLtiqEfxNRXTCQHWjQOtMHMdeDBcMQnJhw6dvcw==')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('IrsacaEyrkSzloyOXUWTPBWtMisYRSUEKjmvfJAxwTwjqkGqixxohPOUmlnaHRMb3dlckFybQ=='), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('zRnDdOnIOONiQXwwPzsjBzJvsERaComRjKFGIYoZvsmGEqEJrNIFiee8J+mviBCcmHDp28gRGlyIChCYWl4byk='), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('MUPOtHHhBAGihnAIvvSfJSqtUMzoMahIVtoLEOtusvndKKBrVuAlWizQnJhw6dvcw==')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ErBgkbIgFndFrXmmtDchPdXsdbqtHMppbvrPAtAKHdZlyhMDpjfBEXgTGVmdEhhbmQ='), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('spayItLRooXZiSExqiOneRlvFbMBxAYtZLXUSoHDSEKDjGqLwZCYYLA4pyLIE3Do28gRXNxdWVyZGE='), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('sSbmQuqEDOfUySOfZjFeTIZaTSfRIFtZbDpIMcQTWuRuFwXSGWfejRJQnJhw6dvcw==')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('NWxtBNUcPtVZiqrlfqMtpSJzAsHbUCNZDtnQVxQWeIXsVUYcmvGRrJWUmlnaHRIYW5k'), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('gFUEVAChitCaHVarlGYkCyVTztbmXfuGlRTMCdEcZNyWcDRvPdtkTnU4pyLIE3Do28gRGlyZWl0YQ=='), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('abqRAcnjKMjSyxzoUwIDlyoXcIyxAlKqlSGfliRtYPlAEWeIxYNiumsQnJhw6dvcw==')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('LsiXFCRihkTxAVOTzPKlrRELCuGxKICDhzkkFMYvTeCTXPfLzCuukCwTGVmdFVwcGVyTGVn'), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('pQLkpjknfoQvPTFtBRHZwOTzUgQjTlQRourfwTKJfMEgpJlapErxoGY8J+mtSBQZXJuYSBFc3EgKENpbWEp'), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('nHbJLeOgePwealajokTtIbbYCMCKFDZSKctHOtJlGcuvbTtNTHMnCCmUGVybmFz')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('TaZhcgDEuFSrsZDQSgfTUhReZhmOvMHIcqvnLbKXdLUsPsXqmgwXGnqUmlnaHRVcHBlckxlZw=='), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('EIFnrBGnMwfQkowHhmftzhxxcRQQeChYxmRLvPCdlAhxTFPQjyZElpI8J+mtSBQZXJuYSBEaXIgKENpbWEp'), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ooDDEQOgLiGCLPitVYyFWSvDIVbNAXoRuVCYkOvXzXdElAkcTuYSAgwUGVybmFz')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('gLTIMnJLvkKhMwdNIFfTCzAtXziEcmjUdwCAsssPBOWGKhFjyEttgZhTGVmdExvd2VyTGVn'), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('HOevrQcoQZeyYMEYuvmBJPnNvOmBOsmXJqpBeQJilVUhnzSAqnhBkiZ8J+mvyBQZXJuYSBFc3EgKEJhaXhvKQ=='), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('UcfIrMuqmElyVlzCskAkLugWaGLDUnSqGKwrYpwEyTLbDETwMOfjKVGUGVybmFz')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('hhPiJvHaWbfZDqPOJyOQcEMOFfySzimUBQmhiHsKJntQYPnsxnCOJKeUmlnaHRMb3dlckxlZw=='), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('KyVhzZjdALtBoaHIxlCVhzGOQuerEvFzHpsyGcdNQLqNaVOSSjoltVF8J+mvyBQZXJuYSBEaXIgKEJhaXhvKQ=='), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('hseFskUOGkYANoeqTPaWAfOVQMhHoSwOtIRhDHtbunYmLgSKsHkmtXzUGVybmFz')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('qcWQbLREAKfHKJdaxTtTMrEwtBIPFlEFpyuEkZrNCgjxBTVAvqKoYtkTGVmdEZvb3Q='), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('FlMWNstXZRCgghDMoLhIMPXqFAlqPBRMjymetYkJrunnRJZBMpoqFVf8J+mtiBQw6kgRXNxdWVyZG8='), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('AfBPYDlboaTHEyhvWSVdfqscQcXmsGZnmmRwEYUIjCekmgVzpMQtyiSUGVybmFz')},
            {name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('hxVPFkccfXDiXSWKYsZDDdWcoswSffXXVlrVCNktqyaQBKVHOazSfqnUmlnaHRGb290'), display = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('GsfSIjRzxceEGqdcIwqZEtewweTrILMSbVGqwaPwuACLBwMDjhwelGE8J+mtiBQw6kgRGlyZWl0bw=='), category = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QovMXnZYSamGMTGEVuCKGQtwVkkTgfUZkFdDsPPOKqvmZcWsNaGxsZYUGVybmFz')}
        }
        
        local currentCategory = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('gzTajivCnTqGwGFmMOmiFLmisdPZdvYZAShFzIrFbvFeEZiiEBaoLHm')
        
        for _, part in ipairs(parts) do
            -- Header de categoria se mudou
            if part.category ~= currentCategory then
                currentCategory = part.category
                local catHeader = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('KEylUEWQgqFqVJqlpTNDEUwHvJTBXFwMddvzWAzcxohZUkzmbMGSzIYVGV4dExhYmVs'))
                catHeader.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 25 * CONFIG.scale)
                catHeader.Position = UDim2.new(0, 15 * CONFIG.scale, 0, yOffset / CONFIG.scale)
                catHeader.BackgroundTransparency = 1
                catHeader.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('tREIlAVHCzTJsYMLZxLpdkCRaIiAuamNURhxlTjEEXLkcokJXBNVpug4pSB4pSBIA==') .. part.category .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('OCVXxcHcygkwMxhWnSRVsYOHXAKGBBnsktioWWGNsqMLdddcRowqWnnIOKUgeKUgQ==')
                catHeader.TextColor3 = CONFIG.primary
                catHeader.Font = Enum.Font.GothamBold
                catHeader.TextSize = 12 * CONFIG.scale
                catHeader.TextXAlignment = Enum.TextXAlignment.Left
                catHeader.Parent = frame
                
                yOffset = yOffset + 30 * CONFIG.scale
            end
            
            local card = createCard(frame, yOffset / CONFIG.scale, 55, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('KFAejGTujMYfdtzzzooQzuDQsuwnIVzKbPEHCtuKPFvcXksNXhCSsGX'), CONFIG.bgCard)
            
            local lbl = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('PtmstnVbglvtGmMXcriPqezaYoFmAzPrZIhsphTkdaNpgAanroZzygoVGV4dExhYmVs'))
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = part.display
            lbl.TextColor3 = CONFIG.textPrimary
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 13 * CONFIG.scale
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = card
            
            local toggle = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('urWKluWQuxFoFGBGrlDqypKsyScVWPiOTWVasSyneVSinNHpBNMmgQNVGV4dEJ1dHRvbg=='))
            toggle.Size = UDim2.new(0, 45 * CONFIG.scale, 0, 28 * CONFIG.scale)
            toggle.Position = UDim2.new(1, -60 * CONFIG.scale, 0.5, -14 * CONFIG.scale)
            toggle.BackgroundColor3 = CONFIG.bodyParts[part.name] and CONFIG.success or CONFIG.bgHover
            toggle.Text = CONFIG.bodyParts[part.name] and WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('MMFHRpIAVEPJUKgXoOHHHJkDOncArPVpUsXtuIdJjLcPbmcPsePMAnN4pyT') or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('JQDDrwKoyCIbtrRKUCZXLCaHqfpIenbSzZgEnwLpzJPoFQqTNcAPJoe')
            toggle.TextColor3 = CONFIG.textPrimary
            toggle.Font = Enum.Font.GothamBlack
            toggle.TextSize = 16 * CONFIG.scale
            toggle.AutoButtonColor = false
            toggle.Parent = card
            createCorner(toggle, 10)
            
            toggle.MouseButton1Click:Connect(function()
                CONFIG.bodyParts[part.name] = not CONFIG.bodyParts[part.name]
                toggle.BackgroundColor3 = CONFIG.bodyParts[part.name] and CONFIG.success or CONFIG.bgHover
                toggle.Text = CONFIG.bodyParts[part.name] and WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('UHKyBzvipygHxZNtgoHhmZbpeezqyhDdekpdAYAqFMoasKjQNsTBIjB4pyT') or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('flEgZYemNDpOWyKvlFTPauwMIcnnmvbYVXsIuUHgYTClCiZsbRycMDu')
                
                notify(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('gwiwIOuVNOUwYMbwqdWudybZKssNICwaNuDMorQEuyVymeBkXPOPQSSQ0FEVVhYMTM3'), part.display .. (CONFIG.bodyParts[part.name] and WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('yFhYHUgFiqWfpaaEslXRQaLEnUrwnSqpkuzMSsTkLxEoBOqzkQHNAgyIOKckw==') or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('cgnARPaFjlTjebNmzuROloPPAfdMxDxQNbJUEWXVnBJIsCYUBCPluzoIOKclw==')), 1, CONFIG.bodyParts[part.name] and WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('lGsfAdsZgiLHSCFsccrzRLpKwEmhGnFyTPZLWScUCWfnPGWQwydJrLVc3VjY2Vzcw==') or WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YmlLuJFJrQJOUWpbVVRSCjCtlruigMQQfmFdkpvOlnqEEUoyQTOSNlNaW5mbw=='))
            end)
            
            yOffset = yOffset + 65 * CONFIG.scale
        end
        
        frame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
    end
    
    -- ============================================
    -- TAB STATS (Estatísticas)
    -- ============================================
    function createStatsTab(parent)
        local frame = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('sKPmHHczSBwmWchZTBOsQoIeuOUiRprfTzDXQVMxYHyxGoFonAoJztbU2Nyb2xsaW5nRnJhbWU='))
        frame.Name = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('BNqdZfwHTQhFQVDzALhrWnltIpxRZzqkJIMWfzwswYCrOQdjDYRFXKgU3RhdHNUYWI=')
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 4
        frame.ScrollBarImageColor3 = CONFIG.primary
        frame.CanvasSize = UDim2.new(0, 0, 0, 600 * CONFIG.scale)
        frame.Parent = parent
        currentTabFrame = frame
        
        frame.Position = UDim2.new(0, 30 * CONFIG.scale, 0, 0)
        tween(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        -- Stats Cards
        local stats = {
            {label = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('URKQcLahmFCcoVxIosdNnqjRlixNUhnJDntXlGTfITsOZMPBfAiZlCIVG90YWwgZGUgVG9xdWVz'), value = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('NYYRbfyWZdEvMkwourKJMqOaCqpmgxySPCTRNFrMHOjbISPJBEGOfejMA=='), key = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('HjyLViEPzYpJmbOcWzhhOyIWgOICXGmEvXDFXoBvgLWuuwxArpSVfSrdG90YWxUb3VjaGVz'), icon = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('FtBfCcqfppbunOMeWufdjcREhpryPypckDVLsHchXSfJhLRczAYqiKt8J+Rhg=='), color = CONFIG.primary},
            {label = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('yHMcyNReOhfnrzUJvykEwZrIbNdPmzbsDgcSqaEXzNJpGllhCQFHtWhQm9sYXMgRGV0ZWN0YWRhcw=='), value = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YzmAKXEZShobOFUDJWkbhjOXPYXQPWfEpUzxEDgRCzoYsBTfNNnFgtTMA=='), key = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YYGwjeSXtAjPiowoHCCJUBbshxsJFxQLFjAVaEIMHNMLDXVSuSkcldNYmFsbHNEZXRlY3RlZA=='), icon = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('kWHtPtOiEmIdooSZaupwrAZEJkpYhDbWrtOXkcpxseSJHLxFaMhkbsR4pq9'), color = CONFIG.success},
            {label = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('ZJDoktRuGegooOtghYAlHxYlNcftEdiZVopWJmqendliFMygXULVueKVGVtcG8gZGUgU2Vzc8Ojbw=='), value = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('MwIgIEpEkkQwkVZgtmrBOhcAgMZTnybqLYiFpdKuEjVXQHdiuBNnEzSMDA6MDA='), key = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('gJBJjQuWefijqsTZcHEyLhZbMsNOoFaDBXnqhDwvGpiQGpfmYbJivmvc2Vzc2lvblRpbWU='), icon = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('KHiPmhZNvxgverTutLTfingBPAhvebpugAtftFbdCkwIYQXgMapZqgO4o+x77iP'), color = CONFIG.warning},
            {label = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('RYXmQzYTJmXVyZzKBxWRzYvoTItrZyUKrJqtqYMnWWmiCACHOgIROCUUmVhY2ggQXR1YWw='), value = tostring(CONFIG.reach) .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('vyIkdymLEGGCPzPVipAuSUCfsFXxyWEgNsHFLeAUrALMqtulzequBhBIHN0dWRz'), key = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('jMcuUJgORkjRXtByEZjEVyqtlqRlCoDODMDPzWsoTvlqLdesFgarSTGcmVhY2g='), icon = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('bQcdAJlSNUjUFhKLjDvMukiyXoVZHIlnbVABrXlgthRyOWxZhfzhDYd8J+Tjw=='), color = CONFIG.info}
        }
        
        local yOffset = 0
        
        for i, stat in ipairs(stats) do
            local statCard = createCard(frame, yOffset, 80, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('BOSyFovJGMNdpWCVEqmHcWDIPjYKDTRFykcOCnmwCWGUWceswuFYMCE'), CONFIG.bgElevated)
            
            local icon = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QpGFnoSAsFHavgBheHniwrliaeVyeRTXlkhAVIhDyTNehFbFGBAmOVVVGV4dExhYmVs'))
            icon.Size = UDim2.new(0, 50 * CONFIG.scale, 0, 50 * CONFIG.scale)
            icon.Position = UDim2.new(0, 15 * CONFIG.scale, 0.5, -25 * CONFIG.scale)
            icon.BackgroundColor3 = stat.color
            icon.BackgroundTransparency = 0.8
            icon.Text = stat.icon
            icon.Font = Enum.Font.GothamBold
            icon.TextSize = 24 * CONFIG.scale
            icon.Parent = statCard
            createCorner(icon, 12)
            
            local label = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('vVgKhlYarELRsKQzJNuEiaAXjimfFCXLqjMmzNAVsbAKlQGXSWQVSmjVGV4dExhYmVs'))
            label.Size = UDim2.new(0.6, 0, 0, 25 * CONFIG.scale)
            label.Position = UDim2.new(0, 75 * CONFIG.scale, 0, 15 * CONFIG.scale)
            label.BackgroundTransparency = 1
            label.Text = stat.label
            label.TextColor3 = CONFIG.textSecondary
            label.Font = Enum.Font.GothamBold
            label.TextSize = 13 * CONFIG.scale
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = statCard
            
            local value = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('lVLhhmiTTieUiZiyQemXECzpXrYCGQlRHIRieBKpLBZyybWVZIBALdTVGV4dExhYmVs'))
            value.Name = stat.key .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('QjMQUzHDtcisncBfufzJckIMUKubuNDLwQKNhxFZQOEHJOdqYnNsTxlVmFsdWU=')
            value.Size = UDim2.new(0.6, 0, 0, 30 * CONFIG.scale)
            value.Position = UDim2.new(0, 75 * CONFIG.scale, 0, 40 * CONFIG.scale)
            value.BackgroundTransparency = 1
            value.Text = stat.value
            value.TextColor3 = stat.color
            value.Font = Enum.Font.GothamBlack
            value.TextSize = 22 * CONFIG.scale
            value.TextXAlignment = Enum.TextXAlignment.Left
            value.Parent = statCard
            
            yOffset = yOffset + 90 * CONFIG.scale
        end
        
        -- Performance Card
        local perfCard = createCard(frame, yOffset + 10, 120, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('KRNIMvEkBCizdfxLHFvdLqkHZJNEMxLNYjABVaOOoyRArqfvfkxIhau8J+Wpe+4jyBQZXJmb3JtYW5jZQ=='), CONFIG.bgCard)
        
        local perfText = Instance.new(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('yOokizUnfNGFICliAHSyZPgHdIvGPANoaPJmNAQyCeiihTRwdzHXUYjVGV4dExhYmVs'))
        perfText.Size = UDim2.new(1, -30 * CONFIG.scale, 0, 80 * CONFIG.scale)
        perfText.Position = UDim2.new(0, 15 * CONFIG.scale, 0, 40 * CONFIG.scale)
        perfText.BackgroundTransparency = 1
        perfText.Text = WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('LLEjKVqWzjlkPBYRidzGRrAZzlZjFeXQLtOqzLsgYtTSJGNrXEKrPPFRlBTOiBDYWxjdWxhbmRvLi4uXFxcXG5QaW5nOiBDYWxjdWxhbmRvLi4uXFxcXG5NZW3Ds3JpYTogQ2FsY3VsYW5kby4uLg==')
        perfText.TextColor3 = CONFIG.textMuted
        perfText.Font = Enum.Font.Gotham
        perfText.TextSize = 13 * CONFIG.scale
        perfText.TextWrapped = true
        perfText.TextYAlignment = Enum.TextYAlignment.Top
        perfText.Parent = perfCard
        
        -- Atualizar estatísticas em tempo real
        spawn(function()
            while frame and frame.Parent do
                STATS.sessionTime = tick() - STATS.startTime
                
                -- Atualizar valores
                local touchesLabel = frame:FindFirstChild(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('JvZavuLYPtDeZyfnVdMEKpfXnijMhcsRwKNtGMfGTkpFPUriCxGauuBdG90YWxUb3VjaGVzVmFsdWU='), true)
                if touchesLabel then
                    touchesLabel.Text = formatNumber(STATS.totalTouches)
                end
                
                local ballsLabel = frame:FindFirstChild(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('lJPEEgNQviEpMHSCesAmCagEbtxnEBoxrUcxPZEoVVEbdFhVvkeFvjeYmFsbHNEZXRlY3RlZFZhbHVl'), true)
                if ballsLabel then
                    ballsLabel.Text = tostring(STATS.ballsDetected)
                end
                
                local timeLabel = frame:FindFirstChild(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('UnXYaNmxqbvwtQmqIXgmBhgYobSnfXCpnAbDqccwpgZCZwrefjuLCqFc2Vzc2lvblRpbWVWYWx1ZQ=='), true)
                if timeLabel then
                    timeLabel.Text = formatTime(STATS.sessionTime)
                end
                
                local reachLabel = frame:FindFirstChild(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('bcjBasGuZfKLkfjnDoakSSrpdOekDwshaHEfMNitJBPyQkoNoudpfoMcmVhY2hWYWx1ZQ=='), true)
                if reachLabel then
                    reachLabel.Text = tostring(CONFIG.reach) .. WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('hSsGZQisaNGCMYizdqEDrraIPhqjxFiGGqCkkZTNhTiGqlTwVkavCMVIHN0dWRz')
                end
                
                -- Performance
                if perfText then
                    local fps = math.floor(1 / RunService.Heartbeat:Wait())
                    perfText.Text = string.format(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('MeCYqKafmcTVrwdalFegaCMpXYMUZkNVPdqNCkuTFCJacArDMXtIAQxRlBTOiAlZFxcXFxuUGluZzogJWQgbXNcXFxcbk1lbcOzcmlhOiAlcyBNQg=='), 
                        fps, 
                        math.random(20, 80), -- Simulado
                        formatNumber(math.random(50, 200)) -- Simulado
                    )
                end
                
                wait(1)
            end
        end)
        
        frame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 150)
    end
    
    -- Eventos dos botões de controle
    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, {BackgroundColor3 = CONFIG.primary}, 0.2)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, {BackgroundColor3 = CONFIG.bgElevated}, 0.2)
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = true
        tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        mainGui:Destroy()
        createIconButton()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        mainGui:Destroy()
        if reachSphere then reachSphere:Destroy() end
    end)
    
    makeDraggable(main, header)
    
    main.Size = UDim2.new(0, 0, 0, 0)
    tween(main, {Size = UDim2.new(0, W, 0, H)}, 0.5, Enum.EasingStyle.Back)
    
    notify(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('PThReOzZYstrSzFSJQNgxEYrtVmlBHHzNRUhlSdZerrCCxNxvARukSv4pqhIENBRFVYWDEzNyB2MTAuMA=='), WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('YRBmPpYMVnwtveGaZlFPbYQjlLVjDHzsOaQHUGIeULpXXnIMMyyhpvlVWx0aW1hdGUgRWRpdGlvbiBjYXJyZWdhZGEh'), 3, WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('lhmynVlwpdKmeRWduywuPRQOCoKgAYENmCNuFwzCDnexJStErsiXWOBcHJlbWl1bQ=='))
end

-- ============================================
-- LOOP PRINCIPAL OTIMIZADO
-- ============================================
RunService.Heartbeat:Connect(function()
    updateCharacter()
    updateSphere()
    findBalls()
    
    if not HRP then return end
    local now = tick()
    if now - lastTouch < 0.05 then return end
    
    local parts = getSelectedBodyParts()
    if #parts == 0 then return end
    
    local hrpPos = HRP.Position
    local closestBall = nil
    local closestDist = CONFIG.reach
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local dist = (ball.Position - hrpPos).Magnitude
            if dist <= CONFIG.reach and dist < closestDist then
                closestDist = dist
                closestBall = ball
            end
        end
    end
    
    if CONFIG.autoTouch and closestBall then
        lastTouch = now
        for _, part in ipairs(parts) do
            doTouch(closestBall, part)
        end
    end
end)

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
createLoadingScreen()

print(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('RUDryNWvUlHmXMeAjhAzioVKdJQbgESQrRPWpwakzZbzkYjkJNjpSMwW0NBRFVYWDEzN10gdjEwLjAgVUxUSU1BVEUgY2FycmVnYWRvIGNvbSBzdWNlc3NvIQ=='))
print(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('uLelVRQknUdbCFMvVoFrwgQiQIvfpNKrXutSCOfJrPTgbXcbAYVltkVW0NBRFVYWDEzN10gVG90YWwgZGUgbGluaGFzOiAzMDAwKw=='))
print(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('fKlrVLCsauJnljTxsSCITvmggihiSIUIoGVaHeFJAtPEayOZXUJWWHYW0NBRFVYWDEzN10gRGVzZW52b2x2aWRvIHBvcjog') .. CONFIG.author)
print(WpYdDeltQaoABjKZGSXZswvvRHsfedMkbgtBgRzlRjZNxVcnTCogH('obQUpWSgYWCJScDJhmFZbCcAuqREknnrEZZLxNndaSshCxoPliUmlGVW0NBRFVYWDEzN10gQnVpbGQ6IA==') .. CONFIG.build)
    
