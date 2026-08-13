--ビーストライカー
-- 效果：
-- 丢弃1张手卡发动。从自己卡组把1只「毛扎」特殊召唤。这个效果1回合只能使用1次。
function c21362970.initial_effect(c)
	-- 丢弃1张手卡发动。从自己卡组把1只「毛扎」特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21362970,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c21362970.spcost)
	e1:SetTarget(c21362970.sptg)
	e1:SetOperation(c21362970.spop)
	c:RegisterEffect(e1)
end
-- 代价函数：指定丢弃手牌作为发动代价，并检查是否满足代价条件。
function c21362970.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：确认手牌中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行丢弃：从手牌选择1张可以丢弃的卡，以代价+丢弃的理由送入墓地。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：筛选卡名为「毛扎」（94878265）且能够被特殊召唤的卡。
function c21362970.filter(c,e,tp)
	return c:IsCode(94878265) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标阶段：确认自己主要怪兽区有空位，且卡组中存在符合条件的「毛扎」。
function c21362970.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只符合条件的「毛扎」。
		and Duel.IsExistingMatchingCard(c21362970.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行1只怪兽的特殊召唤，来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：选择卡组中的「毛扎」并将其特殊召唤。
function c21362970.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认主要怪兽区仍有空格，若无则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张符合条件的「毛扎」。
	local g=Duel.SelectMatchingCard(tp,c21362970.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「毛扎」以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
