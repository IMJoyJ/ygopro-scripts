--守護者スフィンクス
-- 效果：
-- 这张卡1个回合可以有1次变回里侧守备表示。这张卡反转召唤成功时，对方场上的全部怪兽回到持有者手卡。
function c40659562.initial_effect(c)
	-- 这张卡1个回合可以有1次变回里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40659562,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c40659562.target)
	e1:SetOperation(c40659562.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转召唤成功时，对方场上的全部怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40659562,1))  --"对方场上的全部怪兽返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c40659562.thtg)
	e2:SetOperation(c40659562.thop)
	c:RegisterEffect(e2)
end
-- 检查是否可以将此卡变为里侧表示且此卡在本回合未使用过该效果
function c40659562.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(40659562)==0 end
	c:RegisterFlagEffect(40659562,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁操作信息为改变表示形式效果
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 将此卡变为里侧守备表示
function c40659562.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 设置连锁操作信息为将对方场上怪兽送入手牌
function c40659562.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有可以送入手牌的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为将对方场上怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 将对方场上所有可以送入手牌的怪兽送入手牌
function c40659562.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以送入手牌的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	-- 将怪兽送入手牌，原因来自效果
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
