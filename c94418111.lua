--魔弾の射手 ワイルド
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
-- ②：和这张卡相同纵列有魔法·陷阱卡发动的场合，以自己墓地3张「魔弹」卡为对象才能发动。那3张卡加入卡组洗切。那之后，自己从卡组抽1张。
function c94418111.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94418111,1))  --"适用「魔弹射手 狂野」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	-- 设置手卡发动效果的对象为「魔弹」系列卡片
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetValue(32841045)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	-- ②：和这张卡相同纵列有魔法·陷阱卡发动的场合，以自己墓地3张「魔弹」卡为对象才能发动。那3张卡加入卡组洗切。那之后，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94418111,0))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,94418111)
	e3:SetCondition(c94418111.tdcon)
	e3:SetTarget(c94418111.tdtg)
	e3:SetOperation(c94418111.tdop)
	c:RegisterEffect(e3)
end
-- 检查是否有魔法·陷阱卡在与这张卡相同的纵列发动
function c94418111.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():GetColumnGroup():IsContains(re:GetHandler())
end
-- 过滤出自己墓地中可以返回卡组的「魔弹」卡片
function c94418111.filter(c)
	return c:IsSetCard(0x108) and c:IsAbleToDeck()
end
-- 效果②的发动准备与目标选择（检查是否能抽卡、墓地是否有3张「魔弹」卡，并进行取对象操作）
function c94418111.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c94418111.filter(chkc) end
	-- 检查玩家当前是否具有抽卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己墓地是否存在至少3张满足条件的「魔弹」卡片
		and Duel.IsExistingTarget(c94418111.filter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地3张「魔弹」卡作为效果的对象
	local g=Duel.SelectTarget(tp,c94418111.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置当前连锁的操作信息为将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置当前连锁的操作信息为玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理（将对象卡片返回卡组洗切，若成功返回3张则抽1张卡）
function c94418111.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 将作为对象的卡片送回持有者的卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际被操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果有卡片被送回了主卡组，则洗切玩家的卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		-- 中断当前效果处理，使后续的抽卡处理与返回卡组不视为同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
