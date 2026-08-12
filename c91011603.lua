--極星工イーヴァルディ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「极神」怪兽或者「极星」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「极星宝」卡加入手卡。
function c91011603.initial_effect(c)
	-- ①：自己场上有「极神」怪兽或者「极星」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,91011603)
	e1:SetCondition(c91011603.spcon)
	e1:SetTarget(c91011603.sptg)
	e1:SetOperation(c91011603.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「极星宝」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,91011604)
	e2:SetTarget(c91011603.thtg)
	e2:SetOperation(c91011603.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「极神」或「极星」怪兽
function c91011603.spfilter(c)
	return c:IsSetCard(0x4b,0x42) and c:IsFaceup()
end
-- ①效果的发动条件：自己场上存在表侧表示的「极神」或「极星」怪兽
function c91011603.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足过滤条件的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c91011603.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的靶/发动准备：检查自身能否特殊召唤，并设置特殊召唤的操作信息
function c91011603.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：将自身特殊召唤
function c91011603.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：卡组中可以加入手牌的「极星宝」卡
function c91011603.thfilter(c)
	return c:IsSetCard(0x5042) and c:IsAbleToHand()
end
-- ②效果的靶/发动准备：检查卡组中是否存在可检索的「极星宝」卡，并设置检索的操作信息
function c91011603.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足过滤条件的「极星宝」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c91011603.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组选择1张「极星宝」卡加入手牌并给对方确认
function c91011603.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「极星宝」卡
	local g=Duel.SelectMatchingCard(tp,c91011603.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
