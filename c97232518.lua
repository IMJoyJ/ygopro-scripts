--深淵のスタングレイ
-- 效果：
-- ①：这张卡发动后变成效果怪兽（雷族·光·5星·攻1900/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果特殊召唤的这张卡不会被战斗破坏。
function c97232518.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（雷族·光·5星·攻1900/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c97232518.target)
	e1:SetOperation(c97232518.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果特殊召唤的这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	e2:SetCondition(c97232518.indcon)
	c:RegisterEffect(e2)
end
-- 检查发动效果时的基本条件，判断是否能将此卡作为怪兽特殊召唤
function c97232518.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将此卡作为雷族·光属性·5星·攻1900/守0的效果怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,97232518,0,TYPES_EFFECT_TRAP_MONSTER,1900,0,5,RACE_THUNDER,ATTRIBUTE_LIGHT) end
	-- 设置操作信息，表明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡赋予怪兽属性并特殊召唤到怪兽区域
function c97232518.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理时，再次检查是否仍能将此卡作为怪兽特殊召唤，若不能则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,97232518,0,TYPES_EFFECT_TRAP_MONSTER,1900,0,5,RACE_THUNDER,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将此卡以自身效果特殊召唤到怪兽区域
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 判断此卡是否是通过自身效果特殊召唤上场的
function c97232518.indcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
