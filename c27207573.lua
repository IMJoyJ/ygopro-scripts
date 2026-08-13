--侵略の手段
-- 效果：
-- 从自己卡组把1只名字带有「侵入魔鬼」的怪兽送去墓地，选择自己场上表侧表示存在的1只名字带有「侵入魔鬼」的怪兽发动。选择的怪兽的攻击力直到结束阶段时上升800。
function c27207573.initial_effect(c)
	-- 从自己卡组把1只名字带有「侵入魔鬼」的怪兽送去墓地，选择自己场上表侧表示存在的1只名字带有「侵入魔鬼」的怪兽发动。选择的怪兽的攻击力直到结束阶段时上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件：非伤害步骤或伤害计算前，即允许该卡在伤害步骤的伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c27207573.cost)
	e1:SetTarget(c27207573.target)
	e1:SetOperation(c27207573.activate)
	c:RegisterEffect(e1)
end
-- 定义代价过滤函数：筛选出卡组中满足名字带有『侵入魔鬼』、是怪兽卡且能作为代价送去墓地的卡。
function c27207573.cfilter(c)
	return c:IsSetCard(0x100a) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 定义发动代价：从自己卡组选择1只名字带有『侵入魔鬼』的怪兽送去墓地作为代价。
function c27207573.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认卡组中是否存在符合条件的『侵入魔鬼』怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27207573.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 显示‘请选择要送去墓地的卡’的提示消息，供玩家选择代价时参考。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己卡组选择1张满足条件的『侵入魔鬼』怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c27207573.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将所选卡以『规则代价』（REASON_COST）送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义对象过滤函数：选择自己场上表侧表示且名字带有『侵入魔鬼』的怪兽。
function c27207573.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x100a)
end
-- 定义效果发动时的取对象目标：选择自己场上表侧表示存在的1只『侵入魔鬼』怪兽。
function c27207573.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27207573.filter(chkc) end
	-- 对象检查阶段：确认自己场上是否存在表侧表示的『侵入魔鬼』怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c27207573.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示‘请选择表侧表示的卡’的提示消息，供玩家选择对象时参考。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择自己场上1只表侧表示的『侵入魔鬼』怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c27207573.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果处理：使对象怪兽的攻击力上升800，直到结束阶段。
function c27207573.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时被选择为对象的『侵入魔鬼』怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的攻击力直到结束阶段时上升800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(800)
		tc:RegisterEffect(e1)
	end
end
