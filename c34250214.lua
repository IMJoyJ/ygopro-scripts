--ヴァンパイアの使い魔
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，支付500基本分才能发动。从卡组把「吸血鬼的使魔」以外的1只「吸血鬼」怪兽加入手卡。
-- ②：这张卡在墓地存在的场合，从手卡以及自己场上的表侧表示的卡之中把1张「吸血鬼」卡送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c34250214.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合，支付500基本分才能发动。从卡组把「吸血鬼的使魔」以外的1只「吸血鬼」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34250214,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,34250214)
	e1:SetCost(c34250214.thcost)
	e1:SetTarget(c34250214.thtg)
	e1:SetOperation(c34250214.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从手卡以及自己场上的表侧表示的卡之中把1张「吸血鬼」卡送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34250214,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,34250215)
	e2:SetCost(c34250214.spcost)
	e2:SetTarget(c34250214.sptg)
	e2:SetOperation(c34250214.spop)
	c:RegisterEffect(e2)
end
-- 支付500基本分的费用处理
function c34250214.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 检索满足条件的「吸血鬼」怪兽的过滤函数
function c34250214.thfilter(c)
	return c:IsSetCard(0x8e) and c:IsType(TYPE_MONSTER) and not c:IsCode(34250214) and c:IsAbleToHand()
end
-- 设置效果发动时的处理信息，准备从卡组检索1张「吸血鬼」怪兽
function c34250214.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否在卡组中存在满足条件的「吸血鬼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34250214.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动时的检索和展示操作
function c34250214.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡从卡组加入手牌
	local g=Duel.SelectMatchingCard(tp,c34250214.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 用于选择送去墓地的「吸血鬼」卡的过滤函数
function c34250214.costfilter(c,tp)
	-- 过滤条件：卡为「吸血鬼」种族，且在手牌或场上表侧表示，可作为墓地费用，且场上存在可用怪兽区
	return c:IsSetCard(0x8e) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 处理特殊召唤时的费用支付操作
function c34250214.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否在手牌或场上存在满足条件的「吸血鬼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c34250214.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡送去墓地作为费用
	local g=Duel.SelectMatchingCard(tp,c34250214.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil,tp)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置特殊召唤时的处理信息
function c34250214.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤效果的发动和后续处理
function c34250214.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否能被特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 特殊召唤后将该卡从场上离开时将其移除
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
