--金剛真力
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，可以从手卡把1只4星以下的二重怪兽特殊召唤。这个效果1回合只能使用1次。
function c57441100.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，可以从手卡把1只4星以下的二重怪兽特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57441100,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c57441100.condition)
	e1:SetTarget(c57441100.target)
	e1:SetOperation(c57441100.operation)
	c:RegisterEffect(e1)
end
c57441100.has_text_type=TYPE_DUAL
-- 检查发动条件：自己场上没有怪兽存在，且对方场上有怪兽存在。
function c57441100.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否不为0。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0
end
-- 过滤手卡中满足4星以下、二重怪兽、且可以特殊召唤的卡片。
function c57441100.filter(c,e,sp)
	return c:IsType(TYPE_DUAL) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动时的合法性检查：检查自己场上是否有空余的怪兽区域，且手卡中是否存在满足条件的怪兽。
function c57441100.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检查阶段，检查手卡中是否存在至少1张满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c57441100.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：在满足怪兽区域和场上怪兽数量条件的前提下，从手卡特殊召唤怪兽。
function c57441100.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时，若自己场上存在怪兽，则不处理效果。
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 或者对方场上没有怪兽，则不处理效果。
		or Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1张满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c57441100.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
