--ビーストライカー
-- 效果：
-- 丢弃1张手卡发动。从自己卡组把1只「毛扎」特殊召唤。这个效果1回合只能使用1次。
function c21362970.initial_effect(c)
	-- 效果原文内容：丢弃1张手卡发动。从自己卡组把1只「毛扎」特殊召唤。这个效果1回合只能使用1次。
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
-- 效果作用：检查是否可以丢弃手卡作为代价
function c21362970.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断玩家手牌中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 效果作用：执行丢弃1张手卡的操作，作为效果的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果作用：定义用于筛选「毛扎」怪兽的过滤函数
function c21362970.filter(c,e,tp)
	return c:IsCode(94878265) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：检查是否满足特殊召唤条件
function c21362970.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断玩家卡组中是否存在符合条件的「毛扎」怪兽
		and Duel.IsExistingMatchingCard(c21362970.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 效果作用：设置连锁处理信息，表明将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行特殊召唤操作
function c21362970.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断玩家场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的「毛扎」怪兽
	local g=Duel.SelectMatchingCard(tp,c21362970.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
