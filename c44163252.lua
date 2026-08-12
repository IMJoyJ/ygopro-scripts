--ワルキューレ・セクスト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把「女武神六女」以外的1只「女武神」怪兽特殊召唤。
-- ②：自己主要阶段才能发动。从对方卡组上面把2张卡送去墓地。
function c44163252.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44163252,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,44163252)
	e1:SetTarget(c44163252.sptg)
	e1:SetOperation(c44163252.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44163252,1))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,44163253)
	e2:SetTarget(c44163252.tgtg)
	e2:SetOperation(c44163252.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「女武神」怪兽（不包括女武神六女）
function c44163252.spfilter(c,e,tp)
	return c:IsSetCard(0x122) and not c:IsCode(44163252) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的条件判断，检查是否满足特殊召唤的条件
function c44163252.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「女武神」怪兽
		and Duel.IsExistingMatchingCard(c44163252.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤操作
function c44163252.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c44163252.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果处理时的条件判断，检查对方是否可以将卡组顶部2张卡送去墓地
function c44163252.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否可以将卡组顶部2张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,2) end
	-- 设置操作信息，表示将要从对方卡组送去墓地2张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,2)
end
-- 效果处理函数，执行将卡组顶部2张卡送去墓地的操作
function c44163252.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方卡组顶部2张卡送去墓地
	Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
end
