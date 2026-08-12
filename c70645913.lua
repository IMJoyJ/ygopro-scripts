--ヴァンパイアの眷属
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，支付500基本分才能发动。从卡组把1张「吸血鬼」魔法·陷阱卡加入手卡。
-- ②：这张卡在墓地存在的场合，从手卡以及自己场上的表侧表示的卡之中把1张「吸血鬼」卡送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c70645913.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合，支付500基本分才能发动。从卡组把1张「吸血鬼」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70645913,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,70645913)
	e1:SetCost(c70645913.thcost)
	e1:SetTarget(c70645913.thtg)
	e1:SetOperation(c70645913.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从手卡以及自己场上的表侧表示的卡之中把1张「吸血鬼」卡送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70645913,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,70645914)
	e2:SetCost(c70645913.spcost)
	e2:SetTarget(c70645913.sptg)
	e2:SetOperation(c70645913.spop)
	c:RegisterEffect(e2)
end
-- 效果①的Cost（支付500基本分）的检查与支付函数
function c70645913.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤卡组中「吸血鬼」魔法·陷阱卡且能加入手牌的过滤函数
function c70645913.thfilter(c)
	return c:IsSetCard(0x8e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的Target（发动准备与效果分类声明）函数
function c70645913.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「吸血鬼」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c70645913.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的Operation（效果处理）函数
function c70645913.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「吸血鬼」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c70645913.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤手牌或场上表侧表示的「吸血鬼」卡，且能作为Cost送去墓地，并且送去墓地后能腾出怪兽区域的过滤函数
function c70645913.costfilter(c,tp)
	-- 检查卡片是否为「吸血鬼」卡，是否在手牌或场上表侧表示，是否能作为Cost送去墓地，且该卡送去墓地后是否能让自身特殊召唤到怪兽区域
	return c:IsSetCard(0x8e) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果②的Cost（送去墓地）的检查与执行函数
function c70645913.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或场上是否存在至少1张满足Cost条件的「吸血鬼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c70645913.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌或场上表侧表示的卡中选择1张满足条件的「吸血鬼」卡
	local g=Duel.SelectMatchingCard(tp,c70645913.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil,tp)
	-- 将选中的卡作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的Target（发动准备与效果分类声明）函数
function c70645913.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表示该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的Operation（效果处理）函数
function c70645913.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，并尝试将自身以表侧表示特殊召唤，若特殊召唤成功则执行后续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
