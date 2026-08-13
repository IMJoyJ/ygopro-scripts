--ウォーターハザード
-- 效果：
-- 自己场上没有怪兽存在的场合，可以从手卡把1只4星以下的水属性怪兽特殊召唤。这个效果1回合只能使用1次。
function c49669730.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上没有怪兽存在的场合，可以从手卡把1只4星以下的水属性怪兽特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49669730,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c49669730.condition)
	e1:SetTarget(c49669730.target)
	e1:SetOperation(c49669730.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件检测：自己场上没有怪兽存在时才能发动。
function c49669730.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己场上主要怪兽区的卡数量，判断是否为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 筛选可特殊召唤的手牌怪兽：必须为水属性、等级4以下，并且满足特殊召唤的规则限制。
function c49669730.filter(c,e,sp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动时的目标选择与合法性判断：确认主怪兽区有空位且手牌存在符合条件的怪兽，并设置操作信息。
function c49669730.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有空闲区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足水属性、4星以下且可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c49669730.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果的操作信息：效果处理时将从手牌特殊召唤1只怪兽，用于连锁判定与后续检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时的实际操作：再次确认条件成立后，从手牌选择1只符合条件的怪兽特殊召唤。
function c49669730.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查主怪兽区是否有空位，若无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时再次确认自己场上没有怪兽，若已有怪兽则终止处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	-- 向玩家展示选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选出1张满足水属性、4星以下且可特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,c49669730.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
