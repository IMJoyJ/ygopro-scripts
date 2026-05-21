--調星のドラッグスター
-- 效果：
-- ①：这张卡发动后变成效果怪兽（机械族·调整·炎·1星·攻0/守1800）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
-- ②：只要这张卡的效果特殊召唤的这张卡在怪兽区域存在，这张卡以外的自己场上的调整不会被战斗以及对方的效果破坏。
function c92092092.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（机械族·调整·炎·1星·攻0/守1800）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c92092092.target)
	e1:SetOperation(c92092092.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡的效果特殊召唤的这张卡在怪兽区域存在，这张卡以外的自己场上的调整不会被战斗以及对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c92092092.indcon)
	e2:SetTarget(c92092092.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果破坏抗性仅在受到对方的效果影响时适用
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
-- 发动效果时的状态检查：检查怪兽区域是否有空位，且玩家是否能将该卡作为怪兽特殊召唤
function c92092092.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将该卡作为特定属性、种族、等级、攻守的怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,92092092,0,TYPES_EFFECT_TRAP_MONSTER+TYPE_TUNER,0,1800,1,RACE_MACHINE,ATTRIBUTE_FIRE) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡作为怪兽特殊召唤到怪兽区域
function c92092092.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查是否满足特殊召唤该怪兽的条件，若不满足则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,92092092,0,TYPES_EFFECT_TRAP_MONSTER+TYPE_TUNER,0,1800,1,RACE_MACHINE,ATTRIBUTE_FIRE) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TUNER+TYPE_TRAP)
	-- 将这张卡以自身效果正面表示特殊召唤到怪兽区域
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 保护效果的适用条件：这张卡是通过自身效果特殊召唤的
function c92092092.indcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 保护效果的影响对象：这张卡以外的自己场上的调整怪兽
function c92092092.indtg(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_TUNER)
end
