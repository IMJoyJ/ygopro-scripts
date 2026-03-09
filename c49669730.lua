--ウォーターハザード
-- 效果：
-- 自己场上没有怪兽存在的场合，可以从手卡把1只4星以下的水属性怪兽特殊召唤。这个效果1回合只能使用1次。
function c49669730.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：自己场上没有怪兽存在的场合，可以从手卡把1只4星以下的水属性怪兽特殊召唤。这个效果1回合只能使用1次。
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
-- 规则层面作用：检查玩家场上是否没有怪兽存在
function c49669730.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断玩家场上怪兽区是否为空
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 规则层面作用：定义可用于特殊召唤的水属性4星以下怪兽的过滤条件
function c49669730.filter(c,e,sp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 规则层面作用：设置效果发动时的目标选择逻辑，检查手牌中是否存在符合条件的怪兽
function c49669730.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断玩家场上是否有可用空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查手牌中是否存在满足条件的水属性4星以下怪兽
		and Duel.IsExistingMatchingCard(c49669730.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面作用：设置连锁处理信息，表明将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面作用：执行效果的处理流程，包括检查场地限制、选择目标怪兽并进行特殊召唤
function c49669730.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：如果场上没有可用空间则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：如果场上已有怪兽存在则不执行特殊召唤
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	-- 规则层面作用：向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从手牌中选择满足条件的1只怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,c49669730.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
