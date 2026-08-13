--ワルキューレ・セクスト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把「女武神六女」以外的1只「女武神」怪兽特殊召唤。
-- ②：自己主要阶段才能发动。从对方卡组上面把2张卡送去墓地。
function c44163252.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡特殊召唤成功的场合才能发动。从卡组把「女武神六女」以外的1只「女武神」怪兽特殊召唤。
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
	-- ②：自己主要阶段才能发动。从对方卡组上面把2张卡送去墓地。
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
-- 特殊召唤的检索过滤条件：选择卡组中属于「女武神」系列、不是「女武神六女」自身、且能够被当前效果特殊召唤的怪兽。
function c44163252.spfilter(c,e,tp)
	return c:IsSetCard(0x122) and not c:IsCode(44163252) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件判定：自己场上有可用的怪兽区域，且卡组中存在符合特殊召唤条件的「女武神」怪兽。
function c44163252.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查自己场上是否存在可用的怪兽区域（用于特殊召唤），这是发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1张满足特殊召唤条件的「女武神」怪兽，这是发动条件之二。
		and Duel.IsExistingMatchingCard(c44163252.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，向系统声明本效果包含从卡组将1只怪兽特殊召唤，供连锁判定等规则使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：若场上仍有可用怪兽区域，则从卡组选择1只符合条件的「女武神」怪兽，以表侧表示特殊召唤。
function c44163252.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认自己场上是否仍有可用怪兽区域，若无则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中筛选并选出1只满足特殊召唤条件的「女武神」怪兽。
	local g=Duel.SelectMatchingCard(tp,c44163252.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽以表侧表示特殊召唤到自己的怪兽区域（不无视召唤条件，不解除苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件判定：对方玩家可以把卡组最上方2张卡送去墓地。
function c44163252.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方玩家是否能将卡组最上方2张卡送去墓地，若不能则无法发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,2) end
	-- 设置操作信息，向系统声明本效果将把对方卡组最上方2张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,2)
end
-- 效果②的处理：将对方卡组最上方2张卡以效果原因送去墓地。
function c44163252.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行操作：将对方卡组最上方2张卡送去墓地，原因记为效果。
	Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
end
