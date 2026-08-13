--ゴルゴネイオの呪眼
-- 效果：
-- 「咒眼」怪兽才能装备。这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡只要在魔法与陷阱区域存在，卡名当作「太阴之咒眼」使用。
-- ②：自己基本分比对方少的场合，装备怪兽的攻击力上升基本分差的数值。
-- ③：把墓地的这张卡除外，从手卡丢弃1张「咒眼」卡才能发动。从卡组把「蛇发之咒眼」以外的1张「咒眼」魔法·陷阱卡加入手卡。
function c28957126.initial_effect(c)
	-- 「咒眼」怪兽才能装备。这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,28957126+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c28957126.target)
	e1:SetOperation(c28957126.operation)
	c:RegisterEffect(e1)
	-- 为这张卡注册卡名变更效果：在魔法与陷阱区域时，卡名视为「太阴之咒眼」。
	aux.EnableChangeCode(c,44133040)
	-- ②：自己基本分比对方少的场合，装备怪兽的攻击力上升基本分差的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(c28957126.atkcon)
	e3:SetValue(c28957126.atkval)
	c:RegisterEffect(e3)
	-- 「咒眼」怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetValue(c28957126.eqlimit)
	c:RegisterEffect(e4)
	-- ③：把墓地的这张卡除外，从手卡丢弃1张「咒眼」卡才能发动。从卡组把「蛇发之咒眼」以外的1张「咒眼」魔法·陷阱卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(28957126,0))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,28957126)
	e5:SetCost(c28957126.thcost)
	e5:SetTarget(c28957126.thtg)
	e5:SetOperation(c28957126.thop)
	c:RegisterEffect(e5)
end
-- 装备限制判定：只允许装备给持有「咒眼」字段（0x129）的怪兽。
function c28957126.eqlimit(e,c)
	return c:IsSetCard(0x129)
end
-- 对象筛选条件：怪兽为表侧表示且属于「咒眼」字段（0x129）。
function c28957126.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x129)
end
-- 装备魔法发动时的处理：选择场上1只表侧表示「咒眼」怪兽作为装备对象，并设置装备的操作信息。
function c28957126.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c28957126.filter(chkc) end
	-- 发动条件检查：确认场上存在至少1只可选择的表侧表示「咒眼」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c28957126.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择装备对象的消息提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示「咒眼」怪兽作为装备对象。
	Duel.SelectTarget(tp,c28957126.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：本次处理为将这张卡装备给对象，数量1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡和目标怪兽仍与本次效果关联且目标表侧表示，则将此卡装备给目标怪兽。
function c28957126.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备到目标怪兽身上。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 攻击力上升效果的发动条件判定：自己基本分比对方少时满足。
function c28957126.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断自己基本分是否低于对方基本分。
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 计算攻击力上升数值：取双方基本分之差的绝对值。
function c28957126.atkval(e,c)
	-- 返回双方基本分之差（绝对值）作为攻击力上升量。
	return math.abs(Duel.GetLP(0)-Duel.GetLP(1))
end
-- 代价筛选：手卡中属于「咒眼」字段且可以被丢弃的卡。
function c28957126.costfilter(c)
	return c:IsSetCard(0x129) and c:IsDiscardable()
end
-- ③的代价整体判定：墓地中的这张卡可除外，且手卡存在至少1张可丢弃的「咒眼」卡。
function c28957126.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查前半部分：确认这张卡可以从墓地除外作为代价。
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		-- 代价检查后半部分：确认手卡存在至少1张可丢弃的「咒眼」卡。
		and Duel.IsExistingMatchingCard(c28957126.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：将墓地的这张卡除外。
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
	-- 执行代价：从手卡丢弃1张「咒眼」卡（计为代价和丢弃）。
	Duel.DiscardHand(tp,c28957126.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 检索筛选：卡组中满足「咒眼」字段、是魔法·陷阱卡、卡名不是「蛇发之咒眼」、且可以加入手卡的卡。
function c28957126.thfilter(c)
	return c:IsSetCard(0x129) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(28957126) and c:IsAbleToHand()
end
-- ③的发动条件与操作信息设置：确认卡组存在检索对象，并设置从卡组将1张卡加入手卡的操作信息。
function c28957126.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认卡组存在至少1张符合条件的「咒眼」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c28957126.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次处理从卡组将1张卡加入手卡，具体卡在效果处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1张符合条件的「咒眼」魔法·陷阱卡加入手卡，并向对方展示。
function c28957126.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择要加入手牌的卡的消息提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「咒眼」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c28957126.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
