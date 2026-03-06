--メタル・リフレクト・スライム
-- 效果：
-- ①：这张卡发动后变成效果怪兽（水族·水·10星·攻0/守3000）在怪兽区域守备表示特殊召唤（也当作陷阱卡使用）。
-- ②：这张卡的效果特殊召唤的这张卡不能攻击。
function c26905245.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（水族·水·10星·攻0/守3000）在怪兽区域守备表示特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c26905245.target)
	e1:SetOperation(c26905245.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果特殊召唤的这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c26905245.atkcon)
	c:RegisterEffect(e2)
end
-- 检查是否满足特殊召唤的条件，包括支付费用、场上是否有空位以及是否可以特殊召唤该怪兽。
function c26905245.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家场上是否有足够的怪兽区域空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定参数的怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,26905245,0,TYPES_EFFECT_TRAP_MONSTER,0,3000,10,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 设置连锁处理时的OperationInfo，表示将要进行特殊召唤操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将此卡以守备表示特殊召唤到场上。
function c26905245.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否可以特殊召唤该怪兽，若不可以则返回。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,26905245,0,TYPES_EFFECT_TRAP_MONSTER,0,3000,10,RACE_AQUA,ATTRIBUTE_WATER) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将此卡以守备表示形式特殊召唤到场上。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP_DEFENSE)
end
-- 判断此卡是否为通过效果特殊召唤的怪兽，用于触发不能攻击效果。
function c26905245.atkcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
