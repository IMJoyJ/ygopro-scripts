--第弐次未界域探険隊
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡，以自己场上1只「未界域」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升500。
-- ②：这张卡在墓地存在的场合，从手卡丢弃1只「未界域」怪兽才能发动。这张卡回到卡组最下面。那之后，自己从卡组抽1张。
function c52534264.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡，以自己场上1只「未界域」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetDescription(aux.Stringid(52534264,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e2:SetCondition(aux.dscon)
	e2:SetCost(c52534264.atkcost)
	e2:SetTarget(c52534264.atktg)
	e2:SetOperation(c52534264.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，从手卡丢弃1只「未界域」怪兽才能发动。这张卡回到卡组最下面。那之后，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetDescription(aux.Stringid(52534264,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,52534264)
	e3:SetCost(c52534264.tdcost)
	e3:SetTarget(c52534264.tdtg)
	e3:SetOperation(c52534264.tdop)
	c:RegisterEffect(e3)
end
-- 过滤出场上的「未界域」怪兽
function c52534264.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x11e)
end
-- 检查玩家手牌是否存在可丢弃的卡片
function c52534264.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从玩家手牌中丢弃1张可丢弃的卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 判断是否满足发动条件并选择对象
function c52534264.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return e:GetHandler():GetFlagEffect(52534264)==0
		-- 检查场上是否存在符合条件的「未界域」怪兽作为效果对象
		and Duel.IsExistingTarget(c52534264.filter1,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一个符合条件的「未界域」怪兽作为效果对象
	Duel.SelectTarget(tp,c52534264.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	e:GetHandler():RegisterFlagEffect(52534264,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 使选中的怪兽攻击力和守备力上升500
function c52534264.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 给对象怪兽增加500点攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 过滤出手牌中可丢弃的「未界域」怪兽
function c52534264.costfilter(c)
	return c:IsSetCard(0x11e) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 检查玩家手牌是否存在符合条件的「未界域」怪兽并丢弃
function c52534264.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在符合条件的「未界域」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c52534264.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手牌中丢弃1只符合条件的「未界域」怪兽
	Duel.DiscardHand(tp,c52534264.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 设置发动效果时的操作信息，包括将卡送回卡组和抽一张卡
function c52534264.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡是否可以送回卡组并确认玩家能否抽卡
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置将此卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置自己抽一张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行将此卡送回卡组并抽一张卡的效果
function c52534264.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否能被送回卡组且已成功送回卡组
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		-- 中断当前效果处理，使后续处理视为不同时进行
		Duel.BreakEffect()
		-- 让玩家从卡组抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
