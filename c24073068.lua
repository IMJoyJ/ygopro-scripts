--剛鬼スープレックス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。从手卡把1只「刚鬼」怪兽特殊召唤。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 过肩摔霸王龙」以外的1张「刚鬼」卡加入手卡。
function c24073068.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只「刚鬼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24073068,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c24073068.sptg)
	e1:SetOperation(c24073068.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 过肩摔霸王龙」以外的1张「刚鬼」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24073068,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,24073068)
	e2:SetCondition(c24073068.thcon)
	e2:SetTarget(c24073068.thtg)
	e2:SetOperation(c24073068.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在可特殊召唤的「刚鬼」怪兽
function c24073068.filter(c,e,tp)
	return c:IsSetCard(0xfc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，用于判断是否满足特殊召唤条件
function c24073068.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的「刚鬼」怪兽
		and Duel.IsExistingMatchingCard(c24073068.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的处理函数
function c24073068.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「刚鬼」怪兽
	local g=Duel.SelectMatchingCard(tp,c24073068.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断该卡是否从场上送去墓地
function c24073068.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于判断卡组中是否存在可加入手牌的「刚鬼」卡
function c24073068.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(24073068) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，用于判断是否满足检索条件
function c24073068.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「刚鬼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c24073068.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将要将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数
function c24073068.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「刚鬼」卡
	local g=Duel.SelectMatchingCard(tp,c24073068.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
