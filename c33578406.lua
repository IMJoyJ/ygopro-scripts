--真刀竹光
-- 效果：
-- ①：装备怪兽的攻击力上升0。
-- ②：装备怪兽直接攻击给与战斗伤害时才能发动。对方场上的怪兽全部破坏。
-- ③：把装备的这张卡送去墓地才能发动。从卡组选「真刀竹光」以外的1张「竹光」装备魔法卡给场上1只表侧表示怪兽装备。
function c33578406.initial_effect(c)
	-- ①：装备怪兽的攻击力上升0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c33578406.target)
	e1:SetOperation(c33578406.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升0。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：装备怪兽直接攻击给与战斗伤害时才能发动。对方场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33578406,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c33578406.descon)
	e3:SetTarget(c33578406.destg)
	e3:SetOperation(c33578406.desop)
	c:RegisterEffect(e3)
	-- ③：把装备的这张卡送去墓地才能发动。从卡组选「真刀竹光」以外的1张「竹光」装备魔法卡给场上1只表侧表示怪兽装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(33578406,1))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c33578406.eqcost)
	e4:SetTarget(c33578406.eqtg)
	e4:SetOperation(c33578406.eqop)
	c:RegisterEffect(e4)
end
-- 装备魔法发动时的目标选择函数：检查是否存在表侧表示怪兽作为装备对象，让玩家选择一只怪兽，并设置装备操作信息。
function c33578406.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在目标选择阶段，检查双方场上是否存在至少一只表侧表示怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示，提示选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择一只表侧表示怪兽作为效果的对象（装备目标）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表明效果处理时将进行装备操作，装备卡是当前卡片，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法发动后的效果处理函数：获取选择的目标，如果卡片和目标都有效，则将卡片装备到目标怪兽上。
function c33578406.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中第一个也是唯一的目标怪兽（装备对象）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将当前卡片装备到目标怪兽上。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 破坏效果的触发条件函数：检查是否满足直接攻击给与战斗伤害的条件。
function c33578406.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：攻击目标为空（直接攻击）且造成战斗伤害的怪兽是这张卡的装备怪兽。
	return Duel.GetAttackTarget()==nil and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 破坏效果的目标设置函数：检查对方场上是否有怪兽，获取所有对方怪兽，并设置破坏操作信息。
function c33578406.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标设置阶段，检查对方场上是否存在至少一只怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，表明效果处理时将破坏这些怪兽，数量为获取的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的效果处理函数：获取对方场上所有怪兽，并将其破坏。
function c33578406.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因破坏这些怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 替换装备效果的成本函数：检查卡片是否可以送去墓地作为成本，然后将其送去墓地。
function c33578406.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将卡片送去墓地作为发动成本。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤函数：定义从卡组选择符合条件的“竹光”装备魔法卡的条件（是“竹光”卡、不是“真刀竹光”、是装备魔法、可唯一存在、不被禁止，且存在可装备的怪兽）。
function c33578406.filter(c,tp)
	return c:IsSetCard(0x60) and not c:IsCode(33578406) and c:IsType(TYPE_EQUIP)
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 检查是否存在至少一只表侧表示怪兽可以装备指定的“竹光”卡。
		and Duel.IsExistingMatchingCard(c33578406.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
-- 过滤函数：检查怪兽是否表侧表示且可以装备指定的装备卡。
function c33578406.eqfilter(c,tc)
	return c:IsFaceup() and tc:CheckEquipTarget(c)
end
-- 替换装备效果的目标设置函数：检查魔陷区有空位且卡组有符合条件的“竹光”装备魔法卡。
function c33578406.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家自己的魔陷区是否有空位（包括被装备卡占据的位置）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>-1
		-- 检查卡组中是否存在至少一张符合条件的“竹光”装备魔法卡。
		and Duel.IsExistingMatchingCard(c33578406.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 替换装备效果的效果处理函数：让玩家从卡组选择一张“竹光”装备魔法卡，然后选择一只表侧表示怪兽，将装备卡装备到该怪兽上。
function c33578406.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示，提示选择要装备的卡（从卡组）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从卡组选择一张符合条件的“竹光”装备魔法卡。
	local g1=Duel.SelectMatchingCard(tp,c33578406.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g1:GetFirst()
	if not tc then return end
	-- 向玩家发送选择提示，提示选择表侧表示的怪兽（作为装备对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择一只表侧表示怪兽可以装备之前选择的装备卡。
	local g2=Duel.SelectMatchingCard(tp,c33578406.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc)
	-- 将选择的装备卡装备到选择的怪兽上。
	Duel.Equip(tp,tc,g2:GetFirst())
end
