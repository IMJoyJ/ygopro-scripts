--霞の谷の神風
-- 效果：
-- 自己场上表侧表示存在的风属性怪兽回到手卡的场合，可以从自己卡组把1只4星以下的风属性怪兽特殊召唤。这个效果1回合只能使用1次。
function c15854426.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的风属性怪兽回到手卡的场合，可以从自己卡组把1只4星以下的风属性怪兽特殊召唤。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15854426,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCountLimit(1)
	e2:SetCondition(c15854426.condition)
	e2:SetTarget(c15854426.target)
	e2:SetOperation(c15854426.operation)
	c:RegisterEffect(e2)
end
-- 该过滤函数判断一张卡是否满足‘自己场上表侧表示存在的风属性怪兽’：要求其上一控制者为当前玩家、上一位位置为怪兽区、在场上时的属性为风、且之前为表侧表示。
function c15854426.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_WIND)~=0
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 检查触发事件组eg中是否存在至少1张满足c15854426.cfilter的卡，即确认发生了‘自己场上表侧表示的风属性怪兽回到手卡’的事件。
function c15854426.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15854426.cfilter,1,nil,tp)
end
-- 筛选可特殊召唤的卡组怪兽：必须是4星以下、风属性，且能够被效果特殊召唤（通过召唤条件/苏生限制的检查）。
function c15854426.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的合法性检查与操作信息设置：在chk==0阶段确认自己怪兽区有空位、此卡不在连锁处理中（避免连锁处理中重复触发），且卡组存在符合条件的怪兽；随后设置特殊召唤的操作信息。
function c15854426.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查：确认自己场上存在空余的主要怪兽区，否则不能发动效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 效果发动条件检查：确认卡组中存在1张以上满足c15854426.filter的怪兽，作为可特殊召唤的牌源。
		and Duel.IsExistingMatchingCard(c15854426.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息，标明本效果将进行特殊召唤，目标为卡组内的1只怪兽（数量1，归属玩家tp），供其他卡/效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作：若仍有空余怪兽区，则让玩家从卡组选择1只符合条件的风属性4星以下怪兽，并表侧表示特殊召唤到自己场上。
function c15854426.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有空余怪兽区；若已无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示特殊召唤的选择提示（HINTMSG_SPSUMMON），准备从卡组选卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的卡组中筛选并选择1张满足c15854426.filter的怪兽卡（4星以下、风属性、可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c15854426.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择成功的怪兽以表侧表示特殊召唤到自己场上，完成特殊召唤处理。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
