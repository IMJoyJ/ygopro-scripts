--ゴルゴネイオの呪眼
-- 效果：
-- 「咒眼」怪兽才能装备。这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡只要在魔法与陷阱区域存在，卡名当作「太阴之咒眼」使用。
-- ②：自己基本分比对方少的场合，装备怪兽的攻击力上升基本分差的数值。
-- ③：把墓地的这张卡除外，从手卡丢弃1张「咒眼」卡才能发动。从卡组把「蛇发之咒眼」以外的1张「咒眼」魔法·陷阱卡加入手卡。
function c28957126.initial_effect(c)
	-- ①：这张卡只要在魔法与陷阱区域存在，卡名当作「太阴之咒眼」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,28957126+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c28957126.target)
	e1:SetOperation(c28957126.operation)
	c:RegisterEffect(e1)
	-- 使此卡在满足条件时视为「太阴之咒眼」卡号
	aux.EnableChangeCode(c,44133040)
	-- ②：自己基本分比对方少的场合，装备怪兽的攻击力上升基本分差的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(c28957126.atkcon)
	e3:SetValue(c28957126.atkval)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外，从手卡丢弃1张「咒眼」卡才能发动。从卡组把「蛇发之咒眼」以外的1张「咒眼」魔法·陷阱卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetValue(c28957126.eqlimit)
	c:RegisterEffect(e4)
	-- 将此卡装备给对方场上的「咒眼」怪兽时，若自己基本分少于对方，则装备怪兽的攻击力上升基本分差值
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
-- 装备对象必须为「咒眼」种族
function c28957126.eqlimit(e,c)
	return c:IsSetCard(0x129)
end
-- 用于筛选场上「咒眼」种族的表侧表示怪兽
function c28957126.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x129)
end
-- 选择场上1只「咒眼」种族的表侧表示怪兽作为装备对象
function c28957126.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c28957126.filter(chkc) end
	-- 检查场上是否存在1只「咒眼」种族的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c28957126.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只「咒眼」种族的表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,c28957126.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c28957126.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否满足装备后攻击力上升的条件
function c28957126.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断自己基本分是否少于对方基本分
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 计算并返回基本分差值
function c28957126.atkval(e,c)
	-- 返回双方基本分的绝对差值
	return math.abs(Duel.GetLP(0)-Duel.GetLP(1))
end
-- 用于筛选手牌中可丢弃的「咒眼」卡
function c28957126.costfilter(c)
	return c:IsSetCard(0x129) and c:IsDiscardable()
end
-- 设置③效果的发动费用
function c28957126.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足将此卡除外的条件
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		-- 检查手牌中是否存在1张「咒眼」卡
		and Duel.IsExistingMatchingCard(c28957126.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将此卡从场上除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
	-- 从手牌中丢弃1张「咒眼」卡
	Duel.DiscardHand(tp,c28957126.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 用于筛选卡组中「咒眼」魔法或陷阱卡（不包括自身）
function c28957126.thfilter(c)
	return c:IsSetCard(0x129) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(28957126) and c:IsAbleToHand()
end
-- 设置③效果的发动条件
function c28957126.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「咒眼」魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c28957126.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行③效果的处理
function c28957126.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「咒眼」魔法或陷阱卡
	local g=Duel.SelectMatchingCard(tp,c28957126.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
