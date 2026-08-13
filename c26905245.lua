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
-- 发动时的条件判定：确认本卡发动时无cost问题、自己场上有空余的怪兽区，且玩家能够将本卡作为效果怪兽特殊召唤；满足则效果可发动。
function c26905245.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查己方主要怪兽区域是否存在至少1个可用空格，供这张卡特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能够将这张卡（卡号26905245）作为效果怪兽特殊召唤到场上，即其召唤条件与苏生限制是否允许。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,26905245,0,TYPES_EFFECT_TRAP_MONSTER,0,3000,10,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 将本次连锁的操作信息设置为特殊召唤：对象为本卡、数量为1，供其他卡在此效果处理时进行对应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理①效果的实际特殊召唤：再次确认特殊召唤仍可行后，为本卡附加怪兽属性（作为效果怪兽和陷阱卡），并以表侧守备表示特殊召唤到己方怪兽区。
function c26905245.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次检查玩家是否仍允许特殊召唤这只效果怪兽，若不允许则直接结束处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,26905245,0,TYPES_EFFECT_TRAP_MONSTER,0,3000,10,RACE_AQUA,ATTRIBUTE_WATER) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 执行特殊召唤：将这张卡以表侧守备表示特殊召唤到己方怪兽区，召唤类型记录为自身效果的特殊召唤（SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF），且不检查召唤条件但检查苏生限制。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP_DEFENSE)
end
-- ②效果“不能攻击”的适用条件：判定这张卡是否是由自身①效果成功特殊召唤（召唤类型为特殊召唤并带有自身效果标志），只有满足该条件时不能攻击状态才适用。
function c26905245.atkcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
