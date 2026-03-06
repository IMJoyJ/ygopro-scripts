--コピー・ナイト
-- 效果：
-- 自己场上有4星以下的战士族怪兽召唤时才能发动。这张卡发动后变成和那只召唤的怪兽相同等级的同名怪兽卡（战士族·光·攻/守0）在怪兽卡区域特殊召唤。这张卡也当作陷阱卡使用。
function c21843307.initial_effect(c)
	-- 效果原文：自己场上有4星以下的战士族怪兽召唤时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c21843307.condition)
	e1:SetTarget(c21843307.target)
	e1:SetOperation(c21843307.activate)
	c:RegisterEffect(e1)
end
-- 规则层面：检查召唤的怪兽是否为4星以下且属于战士族
function c21843307.condition(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep==tp and ec:IsLevelBelow(4) and ec:IsRace(RACE_WARRIOR)
end
-- 规则层面：判断是否满足特殊召唤条件，包括场地空位和能否特殊召唤指定怪兽
function c21843307.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=eg:GetFirst()
	if chk==0 then return e:IsCostChecked()
		-- 规则层面：检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：检查玩家是否可以特殊召唤指定的怪兽（战士族·光·攻/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,ec:GetCode(),0,TYPES_NORMAL_TRAP_MONSTER,0,0,ec:GetLevel(),RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	ec:CreateEffectRelation(e)
	-- 规则层面：设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面：发动效果，先确认目标怪兽是否仍然存在，然后设置卡的属性并尝试特殊召唤
function c21843307.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	if not ec:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	-- 规则层面：再次检查是否可以特殊召唤该怪兽，防止因条件变化导致错误
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,ec:GetCode(),0,TYPES_NORMAL_TRAP_MONSTER,0,0,ec:GetLevel(),RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP,0,0,ec:GetLevel(),0,0)
	-- 规则层面：执行特殊召唤步骤，将此卡作为怪兽特殊召唤到场上
	if Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP) then
		-- 效果原文：这张卡发动后变成和那只召唤的怪兽相同等级的同名怪兽卡（战士族·光·攻/守0）在怪兽卡区域特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ec:GetCode())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
	-- 规则层面：完成特殊召唤流程，结束本次特殊召唤处理
	Duel.SpecialSummonComplete()
end
