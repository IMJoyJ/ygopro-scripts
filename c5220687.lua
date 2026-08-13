--素早いビッグハムスター
-- 效果：
-- 反转：可以从自己卡组把1只3星以下的兽族怪兽里侧守备表示特殊召唤。
function c5220687.initial_effect(c)
	-- 反转：可以从自己卡组把1只3星以下的兽族怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5220687,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c5220687.target)
	e1:SetOperation(c5220687.operation)
	c:RegisterEffect(e1)
end
-- 目标函数：检查效果能否发动，需要自己场上有空位且卡组存在符合条件的兽族怪兽。
function c5220687.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有空余格子，若没有则效果不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在1只满足条件的兽族怪兽（等级3以下且可里侧守备表示特殊召唤），存在时效果可以发动。
		and Duel.IsExistingMatchingCard(c5220687.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明本次效果会进行特殊召唤，预计从卡组特殊召唤1只怪兽，处理对象来自卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤器：选择等级3以下、兽族、能被效果以里侧守备表示特殊召唤的怪兽。
function c5220687.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果处理函数：在场上仍有空位时，从卡组选出符合条件的怪兽，以里侧守备表示特殊召唤，并让对方确认。
function c5220687.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查主要怪兽区是否有空位，没有空位则直接不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组中取出所有满足条件的怪兽，作为可选择的集合。
	local g=Duel.GetMatchingGroup(c5220687.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 向自己显示选择提示，提示选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的怪兽以里侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方展示特殊召唤成功的怪兽卡片，使对方确认该卡信息。
		Duel.ConfirmCards(1-tp,sg)
	end
end
