--ブンボーグ・ベース
-- 效果：
-- ①：场上的「文具电子人」怪兽的攻击力·守备力上升500。
-- ②：1回合1次，自己主要阶段才能发动。手卡的「文具电子人」卡任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
-- ③：把「文具电子人基地」以外的自己的场上·墓地的「文具电子人」卡9种类各1张除外才能发动。对方的手卡·场上·墓地的卡全部回到持有者卡组。
function c12215894.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「文具电子人」怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为场上所有「文具电子人」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xab))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己主要阶段才能发动。手卡的「文具电子人」卡任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量。
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
	-- ③：把「文具电子人基地」以外的自己的场上·墓地的「文具电子人」卡9种类各1张除外才能发动。对方的手卡·场上·墓地的卡全部回到持有者卡组。
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
-- 过滤函数，用于筛选手卡中满足条件的「文具电子人」卡（可公开）
function c12215894.filter(c)
	return c:IsSetCard(0xab) and c:IsAbleToDeck() and not c:IsPublic()
end
-- 判断是否可以发动效果，检查手卡是否存在「文具电子人」卡且玩家可以抽卡
function c12215894.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查手卡中是否存在至少1张「文具电子人」卡
		and Duel.IsExistingMatchingCard(c12215894.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果操作信息，表示将手卡中的卡送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，选择手卡中的「文具电子人」卡送入卡组并抽卡
function c12215894.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要送入卡组的卡
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
	-- 从玩家手卡中选择1到99张「文具电子人」卡
	local g=Duel.SelectMatchingCard(p,c12215894.filter,p,LOCATION_HAND,0,1,99,nil)
	if g:GetCount()>0 then
		-- 向对方确认所选卡
		Duel.ConfirmCards(1-p,g)
		-- 将选中的卡送入卡组并洗切
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切玩家卡组
		Duel.ShuffleDeck(p)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 让玩家从卡组抽卡
		Duel.Draw(p,ct,REASON_EFFECT)
		-- 洗切玩家手卡
		Duel.ShuffleHand(p)
	end
end
-- 过滤函数，用于筛选场上或墓地中的「文具电子人」卡（不含自身）
function c12215894.cfilter(c)
	return c:IsSetCard(0xab) and c:IsAbleToRemoveAsCost() and not c:IsCode(12215894)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 效果发动时的费用支付函数，选择9种不同卡名的「文具电子人」卡除外
function c12215894.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上或墓地中的所有「文具电子人」卡
	local g=Duel.GetMatchingGroup(c12215894.cfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=9 end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 设置额外检查条件，确保所选卡名各不相同
	aux.GCheckAdditional=aux.dncheck
	-- 从符合条件的卡中选择9张卡组成子组
	local rg=g:SelectSubGroup(tp,aux.TRUE,false,9,9)
	-- 清除额外检查条件
	aux.GCheckAdditional=nil
	-- 将选中的卡除外作为费用
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 效果发动时的目标设定函数，设置对方所有卡返回卡组
function c12215894.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否存在至少1张可送入卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 获取对方所有可送入卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 设置效果操作信息，表示将对方所有卡送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理函数，将对方所有卡送入卡组
function c12215894.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方所有可送入卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND,nil)
	-- 检查是否受到王家长眠之谷影响，若存在则无效当前效果
	if aux.NecroValleyNegateCheck(g) then return end
	if g:GetCount()>0 then
		-- 将卡送入卡组并洗切
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
