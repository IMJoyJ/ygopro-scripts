--ライトロード・アサシン ライデン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己卡组上面把2张卡送去墓地。那之中有「光道」怪兽的场合，再让这张卡的攻击力直到对方回合结束时上升200。
-- ②：自己结束阶段发动。从自己卡组上面把2张卡送去墓地。
function c77558536.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。从自己卡组上面把2张卡送去墓地。那之中有「光道」怪兽的场合，再让这张卡的攻击力直到对方回合结束时上升200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77558536,0))  --"送墓"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,77558536)
	e1:SetTarget(c77558536.target)
	e1:SetOperation(c77558536.operation)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段发动。从自己卡组上面把2张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77558536,1))  --"送墓"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c77558536.discon)
	e2:SetTarget(c77558536.distg)
	e2:SetOperation(c77558536.disop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备（检查是否能将卡组卡片送去墓地，并设置操作信息）
function c77558536.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将卡组最上方的2张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	-- 设置操作信息，表示此效果包含将卡组的卡送去墓地的处理
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- 过滤条件：存在于墓地且属于「光道」的怪兽卡
function c77558536.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)
end
-- ①效果的处理（将卡组顶端2张卡送去墓地，若其中有「光道」怪兽，则攻击力上升200）
function c77558536.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己卡组最上方的2张卡送去墓地
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
	-- 获取刚才因效果移动位置（送去墓地）的卡片组
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c77558536.cfilter,nil)
	if ct==0 then return end
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 中断当前效果，使后续的攻击力上升处理不与送墓同时处理
		Duel.BreakEffect()
		-- 再让这张卡的攻击力直到对方回合结束时上升200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件（必须是自己的结束阶段）
function c77558536.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- ②效果的发动准备（必发效果，直接返回true并设置操作信息）
function c77558536.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果包含将卡组的卡送去墓地的处理
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- ②效果的处理（将卡组顶端2张卡送去墓地）
function c77558536.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己卡组最上方的2张卡送去墓地
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
end
