--コピー・ナイト
-- 效果：
-- 自己场上有4星以下的战士族怪兽召唤时才能发动。这张卡发动后变成和那只召唤的怪兽相同等级的同名怪兽卡（战士族·光·攻/守0）在怪兽卡区域特殊召唤。这张卡也当作陷阱卡使用。
function c21843307.initial_effect(c)
	-- 自己场上有4星以下的战士族怪兽召唤时才能发动。这张卡发动后变成和那只召唤的怪兽相同等级的同名怪兽卡（战士族·光·攻/守0）在怪兽卡区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c21843307.condition)
	e1:SetTarget(c21843307.target)
	e1:SetOperation(c21843307.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：召唤成功的怪兽的控制者为发动玩家（ep==tp），且该怪兽等级为4以下、种族为战士族。
function c21843307.condition(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep==tp and ec:IsLevelBelow(4) and ec:IsRace(RACE_WARRIOR)
end
-- 发动时的合法性检查：确认该效果没有需要支付的代价，且满足特殊召唤所需条件（场上空位、可特召陷阱怪兽），以此判定是否允许发动。
function c21843307.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=eg:GetFirst()
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上主要怪兽区域是否存在空位，用于将这张卡作为怪兽特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己能否将以该召唤怪兽的卡名、等级、种族·属性（战士族·光）以及攻守0构成的通常陷阱怪兽特殊召唤到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,ec:GetCode(),0,TYPES_NORMAL_TRAP_MONSTER,0,0,ec:GetLevel(),RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	ec:CreateEffectRelation(e)
	-- 设置本次连锁的操作信息：效果处理时将进行1只怪兽的特殊召唤，对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：确认召唤成功的怪兽仍与效果关联后，把这张卡变成与那只怪兽相同等级、种族为战士族、属性为光、攻击力/守备力为0的怪兽卡（同时仍当作陷阱卡），以表侧表示特殊召唤到自己的怪兽区；随后使这张卡的卡名变为那只怪兽的卡名。
function c21843307.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	if not ec:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	-- 效果处理时再次确认能否特殊召唤该怪兽（若此时不能特召则效果处理失败，直接中止）。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,ec:GetCode(),0,TYPES_NORMAL_TRAP_MONSTER,0,0,ec:GetLevel(),RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP,0,0,ec:GetLevel(),0,0)
	-- 通过分步特殊召唤过程将这张卡以表侧表示特殊召唤到自己的主要怪兽区；若特殊召唤成功，则继续为其附加卡名变更效果。
	if Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP) then
		-- 这张卡发动后变成和那只召唤的怪兽相同等级的同名怪兽卡（战士族·光·攻/守0）在怪兽卡区域特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ec:GetCode())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
	-- 结束分步特殊召唤流程，完成这次特殊召唤，并触发相关时点。
	Duel.SpecialSummonComplete()
end
