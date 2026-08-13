--炎星仙－ワシンジン
-- 效果：
-- 兽战士族怪兽2只
-- 自己对「炎星仙-鹫真人」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
-- ②：以自己的场上·墓地1张「炎舞」魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡。那之后，从卡组把1只「炎星」怪兽送去墓地。
function c46241344.initial_effect(c)
	c:SetSPSummonOnce(46241344)
	-- 为这张卡添加连接召唤手续，素材为2只兽战士族怪兽（必须且只能使用2只），使这张卡可以通过连接召唤出场。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEASTWARRIOR),2,2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(46241344)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	c:RegisterEffect(e1)
	-- ②：以自己的场上·墓地1张「炎舞」魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡。那之后，从卡组把1只「炎星」怪兽送去墓地。
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
-- 定义②效果可选对象的过滤条件：自己场上表侧表示或墓地的「炎舞」魔法·陷阱卡，且能够加入手卡。
function c46241344.thfilter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
		and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 定义从卡组选择送去墓地的「炎星」怪兽的过滤条件：必须是「炎星」字段的怪兽且能够送去墓地。
function c46241344.tgfilter(c)
	return c:IsSetCard(0x79) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ②效果的目标函数：在连锁确认对象时检查所选卡是否合法（自己场上表侧表示或墓地的「炎舞」魔法·陷阱卡）；在发动时判定场上/墓地是否存在可选对象，以及卡组是否存在可送墓的「炎星」怪兽。
function c46241344.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c46241344.thfilter(chkc) end
	-- 判定自己场上表侧表示或墓地是否存在至少1张符合条件的「炎舞」魔法·陷阱卡可以作为对象，这是发动②效果的条件之一。
	if chk==0 then return Duel.IsExistingTarget(c46241344.thfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
		-- 判定卡组是否存在至少1张符合条件的「炎星」怪兽可以送去墓地，与上一条件同时满足才可发动。
		and Duel.IsExistingMatchingCard(c46241344.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 显示“请选择要返回手牌的卡”的提示消息，用于引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己场上表侧表示或墓地的符合条件的「炎舞」魔法·陷阱卡中选择1张，并将其设置为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c46241344.thfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次操作包含将对象卡返回手牌的信息，数量为1，对象为已选择的g，供连锁判定和后续处理使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 登记本次操作包含从卡组将卡送去墓地的信息，数量为1，位置为发动者卡组；具体卡在效果处理时选择，因此targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理时的实际执行：取得对象「炎舞」卡，若仍与效果相关且成功返回手牌，则从卡组选1只「炎星」怪兽送去墓地。
function c46241344.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡（即作为对象的「炎舞」魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与此效果相关并可以返回手牌；执行返回手牌操作，若返回成功且该卡现在位于手牌，才继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取我方卡组中所有符合条件的「炎星」怪兽，供之后选择1张送去墓地。
		local sg=Duel.GetMatchingGroup(c46241344.tgfilter,tp,LOCATION_DECK,0,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续从卡组送墓与前面的返回手牌不再视为同时处理，对应原文“那之后”的时点分离。
			Duel.BreakEffect()
			-- 显示“请选择要送去墓地的卡”的提示消息，用于选择卡组中要送去墓地的「炎星」怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local tg=sg:Select(tp,1,1,nil)
			-- 将选中的「炎星」怪兽送去墓地，送墓原因视为效果（REASON_EFFECT）。
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	end
end
