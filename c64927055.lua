--天空の歌声
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付1000基本分，以自己墓地1只天使族怪兽为对象才能发动。那只怪兽加入手卡。那之后，场上或者墓地有「天空的圣域」存在的场合，可以从除外的自己的卡之中选1张「天空的圣域」或者有那个卡名记述的卡加入手卡。
function c64927055.initial_effect(c)
	-- 注册卡片记述有「天空的圣域」（卡号56433456）的信息
	aux.AddCodeList(c,56433456)
	-- 这个卡名的卡在1回合只能发动1张。①：支付1000基本分，以自己墓地1只天使族怪兽为对象才能发动。那只怪兽加入手卡。那之后，场上或者墓地有「天空的圣域」存在的场合，可以从除外的自己的卡之中选1张「天空的圣域」或者有那个卡名记述的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,64927055+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c64927055.cost)
	e1:SetTarget(c64927055.target)
	e1:SetOperation(c64927055.activate)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理函数：检查并支付1000基本分
function c64927055.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数：自己墓地的天使族怪兽且能加入手卡
function c64927055.thfilter1(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与检测（Target）处理函数
function c64927055.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c64927055.thfilter1(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的天使族怪兽
	if chk==0 then return Duel.IsExistingTarget(c64927055.thfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只天使族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c64927055.thfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤函数：除外区表侧表示的「天空的圣域」或记述了该卡名的卡，且能加入手卡
function c64927055.filter(c)
	-- 过滤条件：表侧表示、是「天空的圣域」或记述了「天空的圣域」的卡、且能加入手卡
	return c:IsFaceup() and aux.IsCodeOrListed(c,56433456) and c:IsAbleToHand()
end
-- 效果处理（Operation）函数
function c64927055.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将对象怪兽加入手牌，并确认其已成功加入手牌
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取除外区中自己所有满足条件的「天空的圣域」或记述了该卡名的卡
		local g=Duel.GetMatchingGroup(c64927055.filter,tp,LOCATION_REMOVED,0,nil)
		-- 检查场上或双方墓地是否存在「天空的圣域」
		if Duel.IsEnvironment(56433456,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
			-- 如果存在符合条件的卡，且玩家选择发动后续效果
			and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(64927055,0)) then  --"是否选除外的卡加入手卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sc=g:Select(tp,1,1,nil)
			-- 中断当前效果处理，使后续处理不与前面同时进行（用于“那之后”的时点处理）
			Duel.BreakEffect()
			-- 将选中的除外卡片加入手牌
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
		end
	end
end
