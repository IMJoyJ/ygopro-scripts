--E-HERO アダスター・ゴールド
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。除「邪心英雄 黯星金魔」外的1张「暗黑融合」或者有那个卡名记述的卡从卡组加入手卡。
-- ②：自己场上没有融合怪兽存在的场合，这张卡不能攻击。
function c13650422.initial_effect(c)
	-- 将卡号94820406（暗黑融合）登记为本卡卡名所记述的卡，使后续可用aux.IsCodeOrListed判断检索对象。
	aux.AddCodeList(c,94820406)
	-- 这个卡名的①的效果1回合只能使用1次。①：把这张卡从手卡丢弃才能发动。除「邪心英雄 黯星金魔」外的1张「暗黑融合」或者有那个卡名记述的卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,13650422)
	e1:SetCost(c13650422.cost)
	e1:SetTarget(c13650422.target)
	e1:SetOperation(c13650422.operation)
	c:RegisterEffect(e1)
	-- ②：自己场上没有融合怪兽存在的场合，这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c13650422.atkcon)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动代价函数：检测这张卡能否从手卡丢弃；若可以，则将其丢入墓地作为发动代价。
function c13650422.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡以代价兼丢弃的理由从手卡送去墓地，完成发动代价。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 定义检索过滤器：满足条件的是卡名或效果文本中包含「暗黑融合」、且不是本卡（邪心英雄 黯星金魔）、并且能被加入手卡的卡。
function c13650422.filter(c)
	-- 判断候选卡是否为「暗黑融合」或记述有「暗黑融合」的卡，同时排除本卡，并确认它可以加入手卡。
	return aux.IsCodeOrListed(c,94820406) and not c:IsCode(13650422) and c:IsAbleToHand()
end
-- 定义①效果的发动目标函数：在发动时确认卡组中有满足检索条件的卡；若存在，则设置操作信息为将1张卡从卡组加入手卡。
function c13650422.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己卡组中存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c13650422.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，向系统声明本效果处理时会将1张卡从卡组加入手卡，供其他效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义①效果处理函数：效果处理时从卡组选择1张符合条件的卡加入手牌，并向对手展示。
function c13650422.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己卡组中选出1张满足检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,c13650422.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入其持有者的手卡，操作原因记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果的条件过滤器：用于判断场上是否存在表侧表示的融合怪兽。
function c13650422.cfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsFaceup()
end
-- 定义②效果的适用条件函数：当自己场上不存在任何表侧表示的融合怪兽时返回真，使不能攻击效果生效。
function c13650422.atkcon(e)
	-- 检查自己主要怪兽区是否存在表侧表示融合怪兽；若不存在，则本卡不能攻击。
	return not Duel.IsExistingMatchingCard(c13650422.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
