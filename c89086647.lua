--お菊さんの皿算用
-- 效果：
-- ①：对方把卡的效果发动时才能发动（同一连锁上最多1次）。这个效果的发动时积累的连锁数量的盘子指示物给这张卡放置。
-- ②：这张卡的盘子指示物数量的以下效果适用。
-- ●9以下：这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ●10以上：这张卡送去墓地。
-- ③：这张卡被自身的效果送去墓地的场合才能发动。从自己卡组上面把10张卡送去墓地。
local s,id,o=GetID()
-- 初始化函数，注册卡片的所有效果
function s.initial_effect(c)
	c:EnableCounterPermit(0x70)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：对方把卡的效果发动时才能发动（同一连锁上最多1次）。这个效果的发动时积累的连锁数量的盘子指示物给这张卡放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(s.coucon)
	e1:SetTarget(s.coutg)
	e1:SetOperation(s.couop)
	c:RegisterEffect(e1)
	-- ●9以下：这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(s.cicon)
	-- 设置不能成为对方卡的效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方卡的效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ●10以上：这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.adjustcon)
	e4:SetOperation(s.adjustop)
	c:RegisterEffect(e4)
	-- ③：这张卡被自身的效果送去墓地的场合才能发动。从自己卡组上面把10张卡送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e5:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(s.tgcon)
	e5:SetTarget(s.tgtg)
	e5:SetOperation(s.tgop)
	c:RegisterEffect(e5)
end
-- 判断是否为对方发动卡的效果
function s.coucon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 放置指示物效果的发动准备，检查是否能放置指示物并设置操作信息
function s.coutg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己能否向这张卡放置当前连锁数数量的盘子指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x70,Duel.GetCurrentChain(),e:GetHandler()) end
	-- 设置操作信息为放置当前连锁数数量的盘子指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,Duel.GetCurrentChain(),0,0x70)
end
-- 放置指示物效果的实际处理，给这张卡放置当前连锁数数量的盘子指示物
function s.couop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 给这张卡放置当前连锁数数量的盘子指示物
		c:AddCounter(0x70,Duel.GetCurrentChain())
	end
end
-- 判断这张卡的盘子指示物数量是否在9个以下
function s.cicon(e)
	return e:GetHandler():GetCounter(0x70)<10
end
-- 判断这张卡的盘子指示物数量是否在10个以上
function s.adjustcon(e)
	return e:GetHandler():GetCounter(0x70)>9
end
-- 将这张卡送去墓地的效果处理
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上展示该卡片以提示效果发动
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	-- 因效果将这张卡送去墓地
	Duel.SendtoGrave(c,REASON_EFFECT)
end
-- 判断是否是被自身的效果送去墓地
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler()==e:GetHandler()
end
-- 送墓效果的发动准备，检查是否能从卡组送卡去墓地并设置目标与操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能将卡组顶端的10张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,10) end
	-- 设置效果处理的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的目标参数为10
	Duel.SetTargetParam(10)
	-- 设置操作信息为从卡组送10张卡去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,10)
end
-- 送墓效果的实际处理，从自己卡组上面把10张卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取设定的目标玩家和送去墓地的卡片数量
	local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 将目标玩家卡组顶端指定数量的卡送去墓地
	Duel.DiscardDeck(p,val,REASON_EFFECT)
end
