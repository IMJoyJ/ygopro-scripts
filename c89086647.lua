--お菊さんの皿算用
-- 效果：
-- ①：对方把卡的效果发动时才能发动（同一连锁上最多1次）。这个效果的发动时积累的连锁数量的盘子指示物给这张卡放置。
-- ②：这张卡的盘子指示物数量的以下效果适用。
-- ●9以下：这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ●10以上：这张卡送去墓地。
-- ③：这张卡被自身的效果送去墓地的场合才能发动。从自己卡组上面把10张卡送去墓地。
local s,id,o=GetID()
-- 初始化效果
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
	-- 设置不能成为对象的值
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被破坏的值
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
s.mentioned_counter={
	[0x70]=true,
}
-- 放置指示物的触发条件
function s.coucon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 放置指示物的目标设定
function s.coutg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断能否给这张卡放置当前连锁数量的指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x70,Duel.GetCurrentChain(),e:GetHandler()) end
	-- 设置放置指示物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,Duel.GetCurrentChain(),0,0x70)
end
-- 放置指示物的处理
function s.couop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 给这张卡放置当前连锁数量的指示物
		c:AddCounter(0x70,Duel.GetCurrentChain())
	end
end
-- 判断指示物数量是否小于10
function s.cicon(e)
	return e:GetHandler():GetCounter(0x70)<10
end
-- 判断指示物数量是否大于9
function s.adjustcon(e)
	return e:GetHandler():GetCounter(0x70)>9
end
-- 送去墓地的处理
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 展示本卡发动动画
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	-- 将这张卡送去墓地
	Duel.SendtoGrave(c,REASON_EFFECT)
end
-- 送去墓地效果的触发条件
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler()==e:GetHandler()
end
-- 送去墓地效果的目标设定
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断能否从卡组上方把10张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,10) end
	-- 设置目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置目标数量为10
	Duel.SetTargetParam(10)
	-- 设置送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,10)
end
-- 送去墓地效果的处理
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家和数量
	local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 将卡组顶端的卡送去墓地
	Duel.DiscardDeck(p,val,REASON_EFFECT)
end
