--青眼の双爆裂龍
-- 效果：
-- 「青眼白龙」＋「青眼白龙」
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把自己的怪兽区域的上记的卡送去墓地的场合可以从额外卡组特殊召唤。
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ③：这张卡的攻击没让对方怪兽被破坏的伤害步骤结束时才能发动。那只对方怪兽除外。
function c2129638.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册融合召唤手续：需要2只「青眼白龙」（卡号89631139）作为融合素材。
	aux.AddFusionProcCodeRep(c,89631139,2,true,true)
	-- 为这张卡注册接触融合手续：可以从自己怪兽区域把满足条件的融合素材作为代价送去墓地，从额外卡组特殊召唤这张卡。
	aux.AddContactFusionProcedure(c,Card.IsAbleToGraveAsCost,LOCATION_MZONE,0,Duel.SendtoGrave,REASON_COST)
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c2129638.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ③：这张卡的攻击没让对方怪兽被破坏的伤害步骤结束时才能发动。那只对方怪兽除外。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(2129638,0))  --"对方怪兽除外"
	e7:SetCategory(CATEGORY_REMOVE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_DAMAGE_STEP_END)
	e7:SetCondition(c2129638.rmcon)
	e7:SetTarget(c2129638.rmtg)
	e7:SetOperation(c2129638.rmop)
	c:RegisterEffect(e7)
end
-- 作为特殊召唤条件的值：只有召唤类型为融合召唤时才允许特殊召唤，以此限制这张卡只能通过融合召唤/接触融合方式出场，其他特殊召唤方式（如死者苏生）不能特殊召唤。
function c2129638.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- ③效果的发动条件：这张卡作为攻击怪兽进行战斗，在伤害步骤结束时自身仍与战斗相关，且战斗对象仍存在于场上并和本次战斗关联；只有满足这些条件才能发动除外效果。
function c2129638.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	-- 确认发动条件之一：这张卡是本次战斗的攻击者，且当前处于伤害步骤结束、满足战斗相关判定的时机（防止离场或无关情况下误发动）。
	return c==Duel.GetAttacker() and aux.dsercon(e,tp,eg,ep,ev,re,r,rp)
		and bc and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsOnField() and bc:IsRelateToBattle()
end
-- 效果发动时的对象检查和操作信息设置：在发动时点确认战斗对象可以被除外，并登记本次操作将除外该对象。
function c2129638.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():IsAbleToRemove() end
	-- 向系统登记操作信息：本连锁要把1只对象怪兽除外（效果分类为除外），用于给其他卡（如星尘龙等）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
-- 效果处理：若战斗对象仍在场上且与本次战斗关联，则将那只对方怪兽表侧表示除外；若已离场则效果不适用。
function c2129638.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() then
		-- 把战斗对象怪兽以表侧表示除外，原因记为效果，完成③效果的除外操作。
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
