--ガスタ・グリフ
-- 效果：
-- 这张卡从手卡送去墓地的场合，可以从自己卡组把1只名字带有「薰风」的怪兽特殊召唤。「薰风狮鹫」的效果1回合只能使用1次。
function c42082363.initial_effect(c)
	-- 这张卡从手卡送去墓地的场合，可以从自己卡组把1只名字带有「薰风」的怪兽特殊召唤。「薰风狮鹫」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42082363,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,42082363)
	e1:SetCondition(c42082363.condition)
	e1:SetTarget(c42082363.target)
	e1:SetOperation(c42082363.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡在被送去墓地之前是否位于手牌，即满足“从手卡送去墓地”的触发条件。
function c42082363.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 筛选卡组中满足条件的怪兽：名字带有「薰风」且可以被当前效果特殊召唤。
function c42082363.filter(c,e,tp)
	return c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的合法判定：自己场上存在可用的怪兽区域，且卡组中存在满足筛选条件的怪兽。
function c42082363.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足筛选条件的怪兽。
		and Duel.IsExistingMatchingCard(c42082363.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的特殊召唤操作信息，预告将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段，进行特殊召唤的实际操作。
function c42082363.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否还有可用怪兽区域，若无则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组选择1张满足筛选条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c42082363.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的那只怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
