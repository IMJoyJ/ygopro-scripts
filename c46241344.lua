--炎星仙－ワシンジン
-- 效果：
-- 兽战士族怪兽2只
-- 自己对「炎星仙-鹫真人」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
-- ②：以自己的场上·墓地1张「炎舞」魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡。那之后，从卡组把1只「炎星」怪兽送去墓地。
function c46241344.initial_effect(c)
	c:SetSPSummonOnce(46241344)
	-- 为卡片添加连接召唤手续，需要2个兽战士族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEASTWARRIOR),2,2)
	c:EnableReviveLimit()
	-- 效果原文内容：自己对「炎星仙-鹫真人」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(46241344)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：以自己的场上·墓地1张「炎舞」魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡。那之后，从卡组把1只「炎星」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46241344,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,46241344)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c46241344.thtg)
	e2:SetOperation(c46241344.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「炎舞」魔法·陷阱卡（包括场上正面表示和墓地中的卡）
function c46241344.thfilter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
		and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 过滤函数，用于筛选满足条件的「炎星」怪兽（从卡组中选择）
function c46241344.tgfilter(c)
	return c:IsSetCard(0x79) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 判断是否满足发动条件，检查场上或墓地是否存在符合条件的「炎舞」卡以及卡组中是否存在符合条件的「炎星」怪兽
function c46241344.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c46241344.thfilter(chkc) end
	-- 检查场上或墓地是否存在符合条件的「炎舞」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c46241344.thfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
		-- 检查卡组中是否存在符合条件的「炎星」怪兽
		and Duel.IsExistingMatchingCard(c46241344.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标卡，从场上或墓地中选择一张符合条件的「炎舞」魔法·陷阱卡
	local g=Duel.SelectTarget(tp,c46241344.thfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，指定将选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息，指定从卡组送去墓地的卡数量和位置
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行效果的后续处理
function c46241344.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且成功送入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取卡组中所有符合条件的「炎星」怪兽
		local sg=Duel.GetMatchingGroup(c46241344.tgfilter,tp,LOCATION_DECK,0,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 向玩家提示选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local tg=sg:Select(tp,1,1,nil)
			-- 将选中的「炎星」怪兽从卡组送去墓地
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	end
end
