--ブンボーグ・ベース
-- 效果：
-- ①：场上的「文具电子人」怪兽的攻击力·守备力上升500。
-- ②：1回合1次，自己主要阶段才能发动。手卡的「文具电子人」卡任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
-- ③：把「文具电子人基地」以外的自己的场上·墓地的「文具电子人」卡9种类各1张除外才能发动。对方的手卡·场上·墓地的卡全部回到持有者卡组。
function c12215894.initial_effect(c)
	-- ①：场上的「文具电子人」怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。手卡的「文具电子人」卡任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 效果作用：设置目标为「文具电子人」卡
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xab))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：把「文具电子人基地」以外的自己的场上·墓地的「文具电子人」卡9种类各1张除外才能发动。对方的手卡·场上·墓地的卡全部回到持有者卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(12215894,0))  --"抽卡"
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(c12215894.target)
	e4:SetOperation(c12215894.operation)
	c:RegisterEffect(e4)
	-- 效果作用：检索满足条件的「文具电子人」手卡并送入卡组，然后抽等量的卡
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(12215894,1))  --"对方卡返回卡组"
	e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCost(c12215894.cost2)
	e5:SetTarget(c12215894.target2)
	e5:SetOperation(c12215894.operation2)
	c:RegisterEffect(e5)
end
-- 过滤函数：判断是否为「文具电子人」且可送入卡组且未公开
function c12215894.filter(c)
	return c:IsSetCard(0xab) and c:IsAbleToDeck() and not c:IsPublic()
end
-- 效果作用：设置发动②效果时的处理条件
function c12215894.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以发动②效果：检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 判断是否可以发动②效果：检查手卡是否存在「文具电子人」卡
		and Duel.IsExistingMatchingCard(c12215894.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果操作信息：将手卡中的「文具电子人」卡送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果作用：处理②效果的发动
function c12215894.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示选择要送入卡组的「文具电子人」卡
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
	-- 选择1~99张手卡中的「文具电子人」卡
	local g=Duel.SelectMatchingCard(p,c12215894.filter,p,LOCATION_HAND,0,1,99,nil)
	if g:GetCount()>0 then
		-- 向对方确认选择的卡
		Duel.ConfirmCards(1-p,g)
		-- 将选择的卡送入卡组并洗切
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(p)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 从卡组抽等量的卡
		Duel.Draw(p,ct,REASON_EFFECT)
		-- 洗切玩家的手卡
		Duel.ShuffleHand(p)
	end
end
-- 过滤函数：判断是否为「文具电子人」且可除外且非「文具电子人基地」
function c12215894.cfilter(c)
	return c:IsSetCard(0xab) and c:IsAbleToRemoveAsCost() and not c:IsCode(12215894)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 效果作用：处理③效果的发动费用
function c12215894.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上及墓地的「文具电子人」卡
	local g=Duel.GetMatchingGroup(c12215894.cfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=9 end
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 设置额外检查条件为卡名不同
	aux.GCheckAdditional=aux.dncheck
	-- 选择9种不同卡名的「文具电子人」卡
	local rg=g:SelectSubGroup(tp,aux.TRUE,false,9,9)
	-- 取消额外检查条件
	aux.GCheckAdditional=nil
	-- 将选择的卡除外作为发动费用
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 效果作用：设置发动③效果时的处理条件
function c12215894.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以发动③效果：检查对方手卡·场上·墓地是否存在可送入卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 获取对方手卡·场上·墓地的可送入卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 设置效果操作信息：将对方手卡·场上·墓地的卡全部送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果作用：处理③效果的发动
function c12215894.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡·场上·墓地的可送入卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND,nil)
	-- 检查是否受到奈落的葬列影响
	if aux.NecroValleyNegateCheck(g) then return end
	if g:GetCount()>0 then
		-- 将对方手卡·场上·墓地的卡送入卡组并洗切
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
