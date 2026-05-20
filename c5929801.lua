--RR－ファジー・レイニアス
-- 效果：
-- 「急袭猛禽-模糊伯劳」的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是「急袭猛禽」怪兽不能特殊召唤。
-- ①：自己场上有「急袭猛禽-模糊伯劳」以外的「急袭猛禽」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把1只「急袭猛禽-模糊伯劳」加入手卡。
function c5929801.initial_effect(c)
	-- ①：自己场上有「急袭猛禽-模糊伯劳」以外的「急袭猛禽」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,5929801)
	e1:SetCondition(c5929801.spcon)
	e1:SetCost(c5929801.cost)
	e1:SetTarget(c5929801.sptg)
	e1:SetOperation(c5929801.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把1只「急袭猛禽-模糊伯劳」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,5929802)
	e2:SetCost(c5929801.cost)
	e2:SetTarget(c5929801.thtg)
	e2:SetOperation(c5929801.thop)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器，用于记录本回合玩家特殊召唤非「急袭猛禽」怪兽的次数。
	Duel.AddCustomActivityCounter(5929801,ACTIVITY_SPSUMMON,c5929801.counterfilter)
end
-- 计数器过滤函数，用于判定特殊召唤的怪兽是否为「急袭猛禽」怪兽。
function c5929801.counterfilter(c)
	return c:IsSetCard(0xba)
end
-- 效果发动的Cost函数，检查本回合是否未特殊召唤过非「急袭猛禽」怪兽，并注册本回合不能特殊召唤非「急袭猛禽」怪兽的誓约效果。
function c5929801.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查本回合玩家是否未特殊召唤过非「急袭猛禽」怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(5929801,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡的效果发动的回合，自己不是「急袭猛禽」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c5929801.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册不能特殊召唤非「急袭猛禽」怪兽的誓约效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的怪兽过滤函数，判定非「急袭猛禽」怪兽不能特殊召唤。
function c5929801.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xba)
end
-- 过滤场上表侧表示存在的「急袭猛禽-模糊伯劳」以外的「急袭猛禽」怪兽。
function c5929801.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xba) and not c:IsCode(5929801)
end
-- 特殊召唤效果的发动条件判定函数：自己场上存在「急袭猛禽-模糊伯劳」以外的「急袭猛禽」怪兽。
function c5929801.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「急袭猛禽-模糊伯劳」以外的「急袭猛禽」怪兽。
	return Duel.IsExistingMatchingCard(c5929801.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的Target函数，检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息。
function c5929801.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的Operation函数，将手牌中的这张卡特殊召唤到场上。
function c5929801.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤卡组中可以加入手牌的「急袭猛禽-模糊伯劳」。
function c5929801.thfilter(c)
	return c:IsCode(5929801) and c:IsAbleToHand()
end
-- 检索效果的Target函数，检查卡组中是否存在「急袭猛禽-模糊伯劳」，并设置加入手牌的操作信息。
function c5929801.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在可以加入手牌的「急袭猛禽-模糊伯劳」。
	if chk==0 then return Duel.IsExistingMatchingCard(c5929801.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手牌的操作信息，表示从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的Operation函数，从卡组选择1只「急袭猛禽-模糊伯劳」加入手牌并给对方确认。
function c5929801.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张「急袭猛禽-模糊伯劳」。
	local g=Duel.SelectMatchingCard(tp,c5929801.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
