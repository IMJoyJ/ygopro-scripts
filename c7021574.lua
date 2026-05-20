--クリブー
-- 效果：
-- 这个卡名在规则上也当作「栗子球」卡使用。
-- ①：对方怪兽的攻击宣言时把这张卡从手卡丢弃才能发动。从卡组把「栗子圆」以外的1只「栗子球」怪兽加入手卡。
-- ②：1回合1次，从手卡丢弃1张陷阱卡，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降1500。这个效果在对方回合也能发动。
function c7021574.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时把这张卡从手卡丢弃才能发动。从卡组把「栗子圆」以外的1只「栗子球」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7021574,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c7021574.condition)
	e1:SetCost(c7021574.cost)
	e1:SetTarget(c7021574.target)
	e1:SetOperation(c7021574.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从手卡丢弃1张陷阱卡，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降1500。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(7021574,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1)
	-- 设置效果在伤害步骤（除伤害计算时外）也能发动
	e3:SetCondition(aux.dscon)
	e3:SetCost(c7021574.atkcost)
	e3:SetTarget(c7021574.atktg)
	e3:SetOperation(c7021574.atkop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定函数
function c7021574.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合是否为对方回合
	return tp~=Duel.GetTurnPlayer()
end
-- 效果①的发动代价判定与执行函数
function c7021574.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价，将这张卡从手卡丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中「栗子圆」以外的「栗子球」怪兽的条件函数
function c7021574.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa4) and not c:IsCode(7021574) and c:IsAbleToHand()
end
-- 效果①的发动检测与操作信息设置函数
function c7021574.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「栗子球」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7021574.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果包含从卡组将卡加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（检索）函数
function c7021574.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的「栗子球」怪兽
	local sg=Duel.SelectMatchingCard(tp,c7021574.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if sg:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤手牌中可丢弃的陷阱卡的条件函数
function c7021574.costfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsDiscardable()
end
-- 效果②的发动代价判定与执行函数
function c7021574.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可丢弃的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c7021574.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 作为发动代价，从手牌丢弃1张陷阱卡
	Duel.DiscardHand(tp,c7021574.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果②的对象选择与发动检测函数
function c7021574.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果②的效果处理（降低攻击力）函数
function c7021574.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时下降1500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-1500)
		tc:RegisterEffect(e1)
	end
end
