--ワーム・ホープ
-- 效果：
-- 反转：被对方怪兽的攻击反转的场合，从自己卡组抽1张卡。此外，这张卡从场上送去墓地时，自己把1张手卡送去墓地。
function c11159464.initial_effect(c)
	-- 反转：被对方怪兽的攻击反转的场合，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetTarget(c11159464.drtg)
	e1:SetOperation(c11159464.drop)
	c:RegisterEffect(e1)
	-- 此外，这张卡从场上送去墓地时，自己把1张手卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11159464,0))  --"把1张手牌送去墓地"
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c11159464.tgcon)
	e2:SetTarget(c11159464.tgtg)
	e2:SetOperation(c11159464.tgop)
	c:RegisterEffect(e2)
end
-- 设置抽卡效果的处理函数
function c11159464.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 判断是否处于伤害步骤且当前怪兽为攻击目标
	if Duel.GetCurrentPhase()==PHASE_DAMAGE and e:GetHandler()==Duel.GetAttackTarget() then
		-- 设置抽卡效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 设置丢弃手卡效果的处理函数
function c11159464.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于伤害步骤且当前怪兽为攻击目标
	if Duel.GetCurrentPhase()==PHASE_DAMAGE and e:GetHandler()==Duel.GetAttackTarget() then
		-- 执行抽卡操作
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 设置送去墓地时的触发条件函数
function c11159464.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置丢弃手卡效果的目标函数
function c11159464.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置丢弃手卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 设置丢弃手卡效果的执行函数
function c11159464.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行丢弃手卡操作
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT,nil)
end
