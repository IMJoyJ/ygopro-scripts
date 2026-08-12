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
	-- 为卡片添加融合召唤手续，使用2个编号为89631139的怪兽作为融合素材
	aux.AddFusionProcCodeRep(c,89631139,2,true,true)
	-- 为卡片添加接触融合特殊召唤规则，允许将自己场上的怪兽送去墓地来特殊召唤
	aux.AddContactFusionProcedure(c,Card.IsAbleToGraveAsCost,LOCATION_MZONE,0,Duel.SendtoGrave,REASON_COST)
	-- 这张卡只能通过融合召唤特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c2129638.splimit)
	c:RegisterEffect(e1)
	-- 这张卡不会被战斗破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 伤害步骤结束时才能发动。那只对方怪兽除外
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
-- 判断召唤方式是否为融合召唤
function c2129638.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 判断是否为战斗阶段结束时触发的效果，且攻击怪兽与对方怪兽处于战斗状态
function c2129638.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	-- 判断当前攻击怪兽是否为该卡，且满足战斗结束条件
	return c==Duel.GetAttacker() and aux.dsercon(e,tp,eg,ep,ev,re,r,rp)
		and bc and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsOnField() and bc:IsRelateToBattle()
end
-- 设置效果发动时的目标为对方怪兽，准备除外操作
function c2129638.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():IsAbleToRemove() end
	-- 设置连锁操作信息，指定将对方怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
-- 执行将对方怪兽除外的操作
function c2129638.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() then
		-- 将对方怪兽以正面表示形式除外
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
