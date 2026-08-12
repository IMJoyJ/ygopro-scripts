--マジェスペクター・スーパーセル
-- 效果：
-- ①：自己的灵摆区域有「威风妖怪」卡存在的场合，这张卡以外的「威风妖怪」卡的自己场上发动的效果的发动和效果不会被无效化。
-- ②：1回合1次，以自己墓地5张「威风妖怪」卡为对象才能发动。那5张卡加入卡组洗切。那之后，自己从卡组抽1张。
function c78949372.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己墓地5张「威风妖怪」卡为对象才能发动。那5张卡加入卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78949372,0))  --"墓地回收"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c78949372.drtg)
	e2:SetOperation(c78949372.drop)
	c:RegisterEffect(e2)
	-- ①：自己的灵摆区域有「威风妖怪」卡存在的场合，这张卡以外的「威风妖怪」卡的自己场上发动的效果的发动不会被无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_INACTIVATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c78949372.tgcon)
	e4:SetValue(c78949372.effectfilter)
	c:RegisterEffect(e4)
	-- ①：自己的灵摆区域有「威风妖怪」卡存在的场合，这张卡以外的「威风妖怪」卡的自己场上发动的效果的效果不会被无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_DISEFFECT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c78949372.tgcon)
	e5:SetValue(c78949372.effectfilter)
	c:RegisterEffect(e5)
end
-- 过滤墓地中属于「威风妖怪」系列且可以回到卡组的卡片
function c78949372.filter(c)
	return c:IsSetCard(0xd0) and c:IsAbleToDeck()
end
-- 效果②的发动准备与判定函数
function c78949372.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c78949372.filter(chkc) end
	-- 判定当前玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 判定自己墓地是否存在至少5张可以回到卡组的「威风妖怪」卡
		and Duel.IsExistingTarget(c78949372.filter,tp,LOCATION_GRAVE,0,5,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地5张「威风妖怪」卡作为效果对象
	local g=Duel.SelectTarget(tp,c78949372.filter,tp,LOCATION_GRAVE,0,5,5,nil)
	-- 设置操作信息，表示该效果包含将选中的5张卡送回卡组的处理
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	-- 设置操作信息，表示该效果包含抽1张卡的处理
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理函数
function c78949372.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end
	-- 将作为对象的卡片送回持有者卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果有卡片实际回到了主卡组，则洗切玩家的卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		-- 中断当前效果处理，使后续的抽卡处理不与洗卡同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 效果①的适用条件判定函数
function c78949372.tgcon(e)
	-- 判定自己的灵摆区域是否存在「威风妖怪」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil,0xd0)
end
-- 过滤受到“不会被无效化”效果保护的卡片效果
function c78949372.effectfilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取触发连锁的效果、发动玩家以及发动位置
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	local tc=te:GetHandler()
	return p==tp and bit.band(loc,LOCATION_ONFIELD)~=0 and tc:IsSetCard(0xd0) and tc~=e:GetHandler()
end
