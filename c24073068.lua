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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 过肩摔霸王龙」以外的1张「刚鬼」卡加入手卡。
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
-- 过滤函数：检查卡片是否为「刚鬼」怪兽，并且满足由当前玩家通过本次效果特殊召唤的召唤条件。
function c24073068.filter(c,e,tp)
	return c:IsSetCard(0xfc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动条件判定：确认自己场上有可用的怪兽区空格，且手卡中存在满足特殊召唤条件的「刚鬼」怪兽，才能发动。
function c24073068.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件之一：自己主要怪兽区（含额外怪兽区）存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动条件之二：手卡中存在至少1只可被本次效果特殊召唤的「刚鬼」怪兽。
		and Duel.IsExistingMatchingCard(c24073068.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：宣布本次效果处理将进行1次从手卡的特殊召唤，目标位置为手卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：若场上仍有空格，从手卡选择1只「刚鬼」怪兽，以表侧表示特殊召唤到自己场上。
function c24073068.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认场上是否有空格，若无则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1张满足filter条件的「刚鬼」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c24073068.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（不检查召唤条件，不解除苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果发动条件：本卡被送去墓地前的位置是场上，即满足“从场上送去墓地”。
function c24073068.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：检索卡组中「刚鬼」系列卡，卡名不是「刚鬼 过肩摔霸王龙」本身，且能够加入手卡。
function c24073068.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(24073068) and c:IsAbleToHand()
end
-- ②效果发动目标条件：确认卡组中存在至少1张满足thfilter的「刚鬼」卡，并登记检索加入手卡的操作。
function c24073068.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认卡组中存在符合条件的「刚鬼」卡（除自身外且可加入手卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c24073068.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果处理将把1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张符合条件的「刚鬼」卡加入手卡，并向对手展示该卡。
function c24073068.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足thfilter条件的「刚鬼」卡。
	local g=Duel.SelectMatchingCard(tp,c24073068.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，理由为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手卡的卡片信息，以公开检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
