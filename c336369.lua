--ガスタ・スクイレル
-- 效果：
-- 这张卡被卡的效果破坏送去墓地时，可以从自己卡组把1只5星以上的名字带有「薰风」的怪兽特殊召唤。
function c336369.initial_effect(c)
	-- 这张卡被卡的效果破坏送去墓地时，可以从自己卡组把1只5星以上的名字带有「薰风」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(336369,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c336369.condition)
	e1:SetTarget(c336369.target)
	e1:SetOperation(c336369.operation)
	c:RegisterEffect(e1)
end
-- 判断这张卡被送去墓地的原因是否同时包含“被破坏”与“效果”标志，即限定为被卡的效果破坏送去墓地的场合。
function c336369.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41
end
-- 定义可特殊召唤的卡牌筛选条件：等级在5星以上、卡名带有「薰风」字段，且能够被当前效果正常特殊召唤。
function c336369.filter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动效果时的合法性检查：确认自己主要怪兽区有空位，并且卡组中存在符合筛选条件的怪兽，才能发动该效果。
function c336369.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空位（数量大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足c336369.filter条件的「薰风」怪兽。
		and Duel.IsExistingMatchingCard(c336369.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果处理的操作信息，标明效果分类为特殊召唤，且预计从卡组把1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：若主要怪兽区仍有空位，则从卡组选择1只符合条件的「薰风」怪兽进行特殊召唤。
function c336369.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认主要怪兽区是否有空位，若没有则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家发送选择提示，提示信息为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家自己的卡组中选取1张满足c336369.filter条件的卡牌作为特殊召唤对象。
	local g = Duel.SelectMatchingCard(tp,c336369.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上（此处为正常的召唤手续，需满足苏生限制及召唤条件）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
