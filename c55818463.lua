--死王リッチーロード
-- 效果：
-- 这张卡上级召唤的场合，解放的怪兽必须是暗属性怪兽。
-- ①：这张卡被效果解放送去墓地的场合发动。墓地的这张卡加入手卡。
function c55818463.initial_effect(c)
	-- 这张卡上级召唤的场合，解放的怪兽必须是暗属性怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRIBUTE_LIMIT)
	e1:SetValue(c55818463.tlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡被效果解放送去墓地的场合发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55818463,0))  --"返回手牌"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCondition(c55818463.retcon)
	e2:SetTarget(c55818463.rettg)
	e2:SetOperation(c55818463.retop)
	c:RegisterEffect(e2)
end
-- 限制上级召唤此卡时解放的怪兽不能是非暗属性怪兽（即必须是暗属性怪兽）
function c55818463.tlimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
-- 检查此卡当前是否在墓地，且是否因效果被解放而送去墓地
function c55818463.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_EFFECT)
end
-- 效果发动的目标，确认效果可以发动并设置将自身加入手卡的操作信息
function c55818463.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将此卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理，若此卡仍与效果存在联系，则将其加入手卡并给对方确认
function c55818463.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡因效果加入持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,c)
	end
end
