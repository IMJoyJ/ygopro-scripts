--E-HERO アダスター・ゴールド
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。除「邪心英雄 黯星金魔」外的1张「暗黑融合」或者有那个卡名记述的卡从卡组加入手卡。
-- ②：自己场上没有融合怪兽存在的场合，这张卡不能攻击。
function c13650422.initial_effect(c)
	-- 为卡片注册“有暗黑融合记述”的卡片代码列表，用于后续效果判断
	aux.AddCodeList(c,94820406)
	-- ①：把这张卡从手卡丢弃才能发动。除「邪心英雄 黯星金魔」外的1张「暗黑融合」或者有那个卡名记述的卡从卡组加入手卡。
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
-- 效果处理时的费用支付函数，用于判断是否满足丢弃条件
function c13650422.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将该卡从手卡送去墓地作为发动费用
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索过滤函数，用于筛选满足条件的卡
function c13650422.filter(c)
	-- 筛选条件：卡名为「暗黑融合」或有其记述，且不是自身，且可以加入手牌
	return aux.IsCodeOrListed(c,94820406) and not c:IsCode(13650422) and c:IsAbleToHand()
end
-- 效果处理时的目标选择函数，用于判断是否可以发动效果
function c13650422.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断在卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c13650422.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定效果将把卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的执行函数，用于执行效果内容
function c13650422.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c13650422.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 攻击条件过滤函数，用于判断是否为融合怪兽
function c13650422.cfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsFaceup()
end
-- 攻击条件判断函数，用于判断场上是否存在融合怪兽
function c13650422.atkcon(e)
	-- 判断场上是否存在融合怪兽，若无则不能攻击
	return not Duel.IsExistingMatchingCard(c13650422.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
