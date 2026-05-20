--賢者の石－サバティエル
-- 效果：
-- ①：自己墓地有「羽翼栗子球」怪兽存在的场合，把基本分支付一半才能发动。从卡组把1张「融合」魔法卡加入手卡。
-- ②：这张卡在墓地存在的场合，把自己墓地3张「贤者之石-萨巴希尔」除外，以场上1只怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升场上的攻击力最高的怪兽的攻击力数值。
function c80831721.initial_effect(c)
	-- ①：自己墓地有「羽翼栗子球」怪兽存在的场合，把基本分支付一半才能发动。从卡组把1张「融合」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80831721,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c80831721.condition)
	e1:SetCost(c80831721.cost)
	e1:SetTarget(c80831721.target)
	e1:SetOperation(c80831721.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把自己墓地3张「贤者之石-萨巴希尔」除外，以场上1只怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升场上的攻击力最高的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80831721,1))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c80831721.atkcost)
	e2:SetTarget(c80831721.atktg)
	e2:SetOperation(c80831721.atkop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己墓地存在「羽翼栗子球」怪兽
function c80831721.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1张「羽翼栗子球」怪兽（字段0x10a4）
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0x10a4)
end
-- 效果①的消耗：支付一半基本分
function c80831721.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前基本分的一半（向下取整）
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤条件：属于「融合」字段（0x46）的魔法卡，且能加入手卡
function c80831721.filter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果①的发动准备（靶向与操作信息注册）
function c80831721.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在满足条件的「融合」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c80831721.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组检索「融合」魔法卡
function c80831721.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「融合」魔法卡
	local g=Duel.SelectMatchingCard(tp,c80831721.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：墓地中卡名为「贤者之石-萨巴希尔」且可以作为cost除外的卡
function c80831721.rfilter(c)
	return c:IsCode(80831721) and c:IsAbleToRemoveAsCost()
end
-- 效果②的消耗：将墓地3张「贤者之石-萨巴希尔」除外
function c80831721.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己墓地是否存在至少3张可除外的「贤者之石-萨巴希尔」
	if chk==0 then return Duel.IsExistingMatchingCard(c80831721.rfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 给玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地选择3张「贤者之石-萨巴希尔」
	local g=Duel.SelectMatchingCard(tp,c80831721.rfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选中的3张卡表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 效果②的发动准备：选择场上1只表侧表示怪兽为对象
function c80831721.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动阶段，检查场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息：请选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果②的处理：使目标怪兽的攻击力上升场上最高攻击力数值
function c80831721.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() then
		-- 获取场上所有表侧表示的怪兽
		local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local mg,matk=og:GetMaxGroup(Card.GetAttack)
		-- 那只怪兽的攻击力直到回合结束时上升场上的攻击力最高的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(matk)
		tc:RegisterEffect(e1)
	end
end
