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
-- 检查此卡是否因战斗破坏而进入墓地且破坏此卡的怪兽仍与本次战斗相关
function c51534754.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetReasonCard():IsRelateToBattle()
end
-- 设置效果目标为破坏此卡的怪兽，并设定操作信息为破坏该怪兽
function c51534754.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=e:GetHandler():GetReasonCard()
	-- 将破坏此卡的怪兽设为连锁处理对象
	Duel.SetTargetCard(rc)
	-- 设置操作信息，表明此效果属于破坏类别，目标为1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,0,0)
end
-- 执行效果操作，若目标怪兽仍与效果相关则将其破坏
function c51534754.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的对象（即破坏此卡的怪兽）
	local rc=Duel.GetFirstTarget()
	if rc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因进行破坏
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
