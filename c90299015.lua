--ヴァンパイアの幽鬼
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功的场合，从手卡以及自己场上的表侧表示的卡之中把这张卡以外的1张「吸血鬼」卡送去墓地才能发动。从卡组把1只4星以上的「吸血鬼」怪兽加入手卡，从卡组把1只2星以下的「吸血鬼」怪兽送去墓地。
-- ②：自己·对方的主要阶段，把墓地的这张卡除外，支付500基本分才能发动。把1只「吸血鬼」怪兽召唤。
function c90299015.initial_effect(c)
	-- ①：这张卡召唤成功的场合，从手卡以及自己场上的表侧表示的卡之中把这张卡以外的1张「吸血鬼」卡送去墓地才能发动。从卡组把1只4星以上的「吸血鬼」怪兽加入手卡，从卡组把1只2星以下的「吸血鬼」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,90299015)
	e1:SetCost(c90299015.thcost)
	e1:SetTarget(c90299015.thtg)
	e1:SetOperation(c90299015.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，把墓地的这张卡除外，支付500基本分才能发动。把1只「吸血鬼」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,90299016)
	e2:SetCondition(c90299015.sumcon)
	e2:SetCost(c90299015.sumcost)
	e2:SetTarget(c90299015.sumtg)
	e2:SetOperation(c90299015.sumop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡或场上表侧表示的、自身以外的「吸血鬼」卡
function c90299015.costfilter(c)
	return c:IsSetCard(0x8e) and c:IsAbleToGraveAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 效果①的发动代价：从手卡或自己场上表侧表示的卡中将1张自身以外的「吸血鬼」卡送去墓地
function c90299015.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或自己场上是否存在除这张卡以外可以送去墓地的「吸血鬼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c90299015.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡或场上表侧表示的「吸血鬼」卡
	local g=Duel.SelectMatchingCard(tp,c90299015.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：卡组中4星以上的「吸血鬼」怪兽
function c90299015.filter1(c)
	return c:IsSetCard(0x8e) and c:IsLevelAbove(4) and c:IsAbleToHand()
end
-- 过滤条件：卡组中2星以下的「吸血鬼」怪兽
function c90299015.filter2(c)
	return c:IsSetCard(0x8e) and c:IsLevelBelow(2) and c:IsAbleToGrave()
end
-- 效果①的发动准备与合法性检查
function c90299015.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在4星以上的「吸血鬼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90299015.filter1,tp,LOCATION_DECK,0,1,nil)
		-- 并且检查卡组中是否存在2星以下的「吸血鬼」怪兽
		and Duel.IsExistingMatchingCard(c90299015.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组检索1只4星以上「吸血鬼」怪兽，并从卡组将1只2星以下「吸血鬼」怪兽送去墓地
function c90299015.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只4星以上的「吸血鬼」怪兽
	local g1=Duel.SelectMatchingCard(tp,c90299015.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if g1:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的怪兽
		Duel.ConfirmCards(1-tp,g1)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家从卡组选择1只2星以下的「吸血鬼」怪兽
		local g2=Duel.SelectMatchingCard(tp,c90299015.filter2,tp,LOCATION_DECK,0,1,1,nil)
		if g2:GetCount()>0 then
			-- 将选中的怪兽送去墓地
			Duel.SendtoGrave(g2,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件：自己或对方的主要阶段
function c90299015.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果②的发动代价：将墓地的这张卡除外，并支付500基本分
function c90299015.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地的这张卡是否可以除外，且玩家是否能支付500基本分
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and Duel.CheckLPCost(tp,500) end
	-- 将墓地的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤条件：手卡或场上可以进行通常召唤的「吸血鬼」怪兽
function c90299015.sumfilter(c)
	return c:IsSetCard(0x8e) and c:IsSummonable(true,nil)
end
-- 效果②的发动准备与合法性检查
function c90299015.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可以进行通常召唤的「吸血鬼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90299015.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：进行1次怪兽的通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②的效果处理：将1只「吸血鬼」怪兽召唤
function c90299015.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 玩家选择1只手卡或场上的「吸血鬼」怪兽
	local g=Duel.SelectMatchingCard(tp,c90299015.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 召唤选中的「吸血鬼」怪兽（忽略每回合通常召唤次数限制）
		Duel.Summon(tp,tc,true,nil)
	end
end
