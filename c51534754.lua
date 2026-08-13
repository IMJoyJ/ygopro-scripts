--黄泉へ渡る船
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。把让这张卡破坏的怪兽破坏。
function c51534754.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地的场合发动。把让这张卡破坏的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51534754,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c51534754.condition)
	e1:SetTarget(c51534754.target)
	e1:SetOperation(c51534754.operation)
	c:RegisterEffect(e1)
end
-- 判断效果发动条件：这张卡在墓地且是被战斗破坏，同时导致其破坏的怪兽仍与本次战斗相关。
function c51534754.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetReasonCard():IsRelateToBattle()
end
-- 发动时无额外选择要求，将导致这张卡破坏的怪兽设为处理对象，并设置对应的破坏信息。
function c51534754.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=e:GetHandler():GetReasonCard()
	-- 将导致这张卡破坏的怪兽设置为当前连锁的处理对象，便于后续效果处理时获取。
	Duel.SetTargetCard(rc)
	-- 设置本次效果处理的操作信息为：破坏那张怪兽，用于连锁判定和效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,0,0)
end
-- 实际处理：取得连锁对象，若该对象仍与此效果关联，则将其破坏。
function c51534754.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的对象卡，即导致这张卡破坏的怪兽。
	local rc=Duel.GetFirstTarget()
	if rc:IsRelateToEffect(e) then
		-- 以效果方式破坏该怪兽，使其被送去墓地。
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
