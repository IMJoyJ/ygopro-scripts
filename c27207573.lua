--侵略の手段
-- 效果：
-- 从自己卡组把1只名字带有「侵入魔鬼」的怪兽送去墓地，选择自己场上表侧表示存在的1只名字带有「侵入魔鬼」的怪兽发动。选择的怪兽的攻击力直到结束阶段时上升800。
function c27207573.initial_effect(c)
	-- 创建效果对象，设置为魔法卡发动效果，具有改变攻击效果、只能在伤害步骤发动、需要选择对象的属性，自由连锁时点，伤害步骤提示，发动条件为aux.dscon，消耗函数为c27207573.cost，目标函数为c27207573.target，发动效果为c27207573.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件为aux.dscon，限制效果不能在伤害计算后发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c27207573.cost)
	e1:SetTarget(c27207573.target)
	e1:SetOperation(c27207573.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡组中是否存在名字带有「侵入魔鬼」且为怪兽卡并能作为墓地代价的卡片
function c27207573.cfilter(c)
	return c:IsSetCard(0x100a) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果发动的消耗函数，检查卡组中是否存在满足条件的卡片，若存在则提示选择并将其送去墓地
function c27207573.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足c27207573.cfilter条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c27207573.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c27207573.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，用于判断场上是否存在表侧表示且名字带有「侵入魔鬼」的怪兽
function c27207573.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x100a)
end
-- 效果发动的目标函数，检查场上是否存在满足条件的怪兽，若存在则提示选择并设置为目标
function c27207573.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27207573.filter(chkc) end
	-- 检查场上是否存在至少1张满足c27207573.filter条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c27207573.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1张怪兽作为目标
	Duel.SelectTarget(tp,c27207573.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动的处理函数，获取目标怪兽并为其附加攻击力上升800的效果
function c27207573.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为选择的怪兽附加攻击力上升800的效果，该效果在结束阶段重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(800)
		tc:RegisterEffect(e1)
	end
end
