--極星獣ガルム
-- 效果：
-- 这张卡和4星以下的怪兽进行战斗的伤害计算后，可以让那只怪兽回到手卡。
function c88283496.initial_effect(c)
	-- 这张卡和4星以下的怪兽进行战斗的伤害计算后，可以让那只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88283496,0))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c88283496.retcon)
	e1:SetTarget(c88283496.rettg)
	e1:SetOperation(c88283496.retop)
	c:RegisterEffect(e1)
end
-- 验证与这张卡战斗的怪兽是否为4星以下且未被战斗破坏，并将其保存为标签对象
function c88283496.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果自身是攻击方，则将对方怪兽（被攻击怪兽）作为目标怪兽
	if tc==e:GetHandler() then tc=Duel.GetAttackTarget() end
	if not tc then return false end
	e:SetLabelObject(tc)
	return tc:IsLevelBelow(4) and not tc:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 确认目标怪兽是否可以回到手卡，并向系统宣告将要把该怪兽送回手卡
function c88283496.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():IsAbleToHand() end
	-- 设置将目标怪兽送回手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetLabelObject(),0,0,0)
end
-- 效果处理时，若目标怪兽仍与战斗相关联，则将其送回手卡
function c88283496.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():IsRelateToBattle() then
		-- 将目标怪兽送回持有者的手卡
		Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
	end
end
