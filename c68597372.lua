--発条機甲ゼンマイスター
-- 效果：
-- 4星怪兽×2
-- 这张卡的攻击力上升这张卡的超量素材数量×300的数值。1回合1次，把这张卡1个超量素材取除，选择自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽变成里侧守备表示。这个回合的结束阶段时，选择的怪兽变成表侧攻击表示。
function c68597372.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽2只
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 这张卡的攻击力上升这张卡的超量素材数量×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c68597372.atkval)
	c:RegisterEffect(e1)
	-- 1回合1次，把这张卡1个超量素材取除，选择自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽变成里侧守备表示。这个回合的结束阶段时，选择的怪兽变成表侧攻击表示。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetDescription(aux.Stringid(68597372,0))  --"改变表示形式"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c68597372.cost)
	e2:SetTarget(c68597372.target)
	e2:SetOperation(c68597372.operation)
	c:RegisterEffect(e2)
end
-- 计算并返回攻击力上升的数值（超量素材数量×300）
function c68597372.atkval(e,c)
	return c:GetOverlayCount()*300
end
-- 检查并取除1个超量素材作为发动的代价
function c68597372.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：自己场上表侧表示且可以变成里侧表示的怪兽
function c68597372.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果的目标选择与处理，选择自己场上1只表侧表示的怪兽作为对象
function c68597372.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c68597372.filter(chkc) end
	-- 检查场上是否存在符合条件的、可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c68597372.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68597372.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示该效果包含改变表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：将选择的怪兽变成里侧守备表示，并注册一个在结束阶段将其变成表侧攻击表示的延迟效果
function c68597372.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽变成里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		tc:RegisterFlagEffect(68597372,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
		-- 这个回合的结束阶段时，选择的怪兽变成表侧攻击表示。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(c68597372.flipcon)
		e1:SetOperation(c68597372.flipop)
		e1:SetLabelObject(tc)
		-- 注册全局延迟效果，用于在结束阶段处理表示形式的变更
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查延迟效果的触发条件：目标怪兽处于里侧表示且带有特定的标记
function c68597372.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:IsFacedown() and tc:GetFlagEffect(68597372)~=0
end
-- 执行延迟效果的处理：将目标怪兽变成表侧攻击表示
function c68597372.flipop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽改变为表侧攻击表示
	Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
end
