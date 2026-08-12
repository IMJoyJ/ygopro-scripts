--RR－ファジー・レイニアス
-- 效果：
-- 「急袭猛禽-模糊伯劳」的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是「急袭猛禽」怪兽不能特殊召唤。
-- ①：自己场上有「急袭猛禽-模糊伯劳」以外的「急袭猛禽」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把1只「急袭猛禽-模糊伯劳」加入手卡。
function c5929801.initial_effect(c)
	-- 「急袭猛禽-模糊伯劳」的①的效果1回合能使用1次，这张卡的效果发动的回合，自己不是「急袭猛禽」怪兽不能特殊召唤。①：自己场上有「急袭猛禽-模糊伯劳」以外的「急袭猛禽」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
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
	-- 「急袭猛禽-模糊伯劳」的②的效果1回合能使用1次，这张卡的效果发动的回合，自己不是「急袭猛禽」怪兽不能特殊召唤。②：这张卡被送去墓地的场合才能发动。从卡组把1只「急袭猛禽-模糊伯劳」加入手卡。
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
	-- 添加自定义活动计数器，用于监控玩家在当前回合中特殊召唤的怪兽是否全部为「急袭猛禽」怪兽
	Duel.AddCustomActivityCounter(5929801,ACTIVITY_SPSUMMON,c5929801.counterfilter)
end
-- 自定义计数器的过滤函数，判断特殊召唤的怪兽是否为表侧表示的「急袭猛禽」怪兽
function c5929801.counterfilter(c)
	return c:IsSetCard(0xba) and c:IsFaceup()
end
-- 发动代价，检查本回合是否只特殊召唤过「急袭猛禽」怪兽，并在发动时注册本回合不能特殊召唤「急袭猛禽」以外怪兽的限制
function c5929801.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查玩家在当前回合是否未曾特殊召唤过「急袭猛禽」以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(5929801,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡的效果发动的回合，自己不是「急袭猛禽」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c5929801.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册只能特殊召唤「急袭猛禽」怪兽的誓约限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的过滤函数，限制玩家不能特殊召唤非「急袭猛禽」怪兽
function c5929801.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xba)
end
-- 过滤函数，检查场上是否存在「急袭猛禽-模糊伯劳」以外的表侧表示「急袭猛禽」怪兽
function c5929801.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xba) and not c:IsCode(5929801)
end
-- 特殊召唤效果的发动条件：自己场上有「急袭猛禽-模糊伯劳」以外的表侧表示「急袭猛禽」怪兽存在
function c5929801.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在符合过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c5929801.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动准备与检查：检查怪兽区是否有空位，以及自身是否能特殊召唤
function c5929801.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查玩家场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前处理的连锁信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理逻辑：在卡片仍和效果关联时，将其以表侧表示特殊召唤到自己场上
function c5929801.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于在卡组中检索可以加入手牌的「急袭猛禽-模糊伯劳」
function c5929801.thfilter(c)
	return c:IsCode(5929801) and c:IsAbleToHand()
end
-- 检索效果的发动准备与检查：确认卡组里有可以加入手牌的卡，并设置检索的操作信息
function c5929801.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查卡组中是否存在可以检索加入手牌的「急袭猛禽-模糊伯劳」
	if chk==0 then return Duel.IsExistingMatchingCard(c5929801.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前处理的连锁信息：将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理逻辑：让玩家从卡组选择1只「急袭猛禽-模糊伯劳」加入手牌，并向对方展示
function c5929801.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择需要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只符合条件的「急袭猛禽-模糊伯劳」
	local g=Duel.SelectMatchingCard(tp,c5929801.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
