--怒気土器
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：从手卡丢弃1只岩石族怪兽才能发动。原本的属性·等级和那只怪兽相同的1只岩石族怪兽从卡组表侧攻击表示或者里侧守备表示特殊召唤。
function c42143067.initial_effect(c)
	-- 效果原文内容：这个卡名的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42143067,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,42143067)
	e1:SetCost(c42143067.spcost)
	e1:SetTarget(c42143067.sptg)
	e1:SetOperation(c42143067.spop)
	c:RegisterEffect(e1)
end
-- 效果作用：设置标记为100，表示可以发动效果。
function c42143067.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 效果作用：过滤手牌中满足条件的岩石族怪兽（可丢弃且卡组中有相同属性和等级的岩石族怪兽）。
function c42143067.cfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsDiscardable()
		-- 效果作用：检查卡组中是否存在满足条件的岩石族怪兽。
		and Duel.IsExistingMatchingCard(c42143067.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalAttribute(),c:GetOriginalLevel())
end
-- 效果作用：过滤卡组中满足条件的岩石族怪兽（属性和等级与丢弃的怪兽相同且可特殊召唤）。
function c42143067.spfilter(c,e,tp,att,lv)
	return c:IsRace(RACE_ROCK) and c:GetOriginalAttribute()==att and c:GetOriginalLevel()==lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 效果作用：判断是否满足发动条件并选择丢弃的手牌，将手牌送去墓地并设置操作信息。
function c42143067.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 效果作用：判断玩家场上是否有空位。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 效果作用：检查手牌中是否存在满足条件的岩石族怪兽。
			and Duel.IsExistingMatchingCard(c42143067.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 效果作用：提示玩家选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 效果作用：选择满足条件的手牌。
	local g=Duel.SelectMatchingCard(tp,c42143067.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	e:SetLabelObject(g:GetFirst())
	-- 效果作用：将选中的手牌送去墓地作为代价。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	-- 效果作用：设置操作信息，表示将从卡组特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果作用：执行特殊召唤操作，选择卡组中符合条件的怪兽进行特殊召唤。
function c42143067.spop(e,tp,eg,ep,ev,re,r,rp)
	local gc=e:GetLabelObject()
	-- 效果作用：判断玩家场上是否有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的卡组怪兽。
	local g=Duel.SelectMatchingCard(tp,c42143067.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,gc:GetOriginalAttribute(),gc:GetOriginalLevel())
	local tc=g:GetFirst()
	if tc then
		-- 效果作用：将选中的怪兽特殊召唤到场上，并确认对方是否能看到里侧表示的怪兽。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
			-- 效果作用：向对方确认特殊召唤的里侧表示怪兽的卡面。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
