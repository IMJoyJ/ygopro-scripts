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
	-- ②：装备怪兽直接攻击给与战斗伤害时才能发动。对方场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：把装备的这张卡送去墓地才能发动。从卡组选「真刀竹光」以外的1张「竹光」装备魔法卡给场上1只表侧表示怪兽装备。
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
	-- 效果作用
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
-- 效果作用
function c33578406.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否满足装备目标条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，指定装备效果
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果作用
function c33578406.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备目标
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 效果作用
function c33578406.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为装备怪兽直接攻击造成的战斗伤害
	return Duel.GetAttackTarget()==nil and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 效果作用
function c33578406.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置效果处理信息，指定破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用
function c33578406.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上的所有怪兽破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果作用
function c33578406.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将装备卡送入墓地作为费用
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤函数，筛选符合条件的「竹光」装备魔法卡
function c33578406.filter(c,tp)
	return c:IsSetCard(0x60) and not c:IsCode(33578406) and c:IsType(TYPE_EQUIP)
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 检查是否有怪兽可以装备该装备卡
		and Duel.IsExistingMatchingCard(c33578406.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
-- 过滤函数，判断怪兽是否可以装备该装备卡
function c33578406.eqfilter(c,tc)
	return c:IsFaceup() and tc:CheckEquipTarget(c)
end
-- 效果作用
function c33578406.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查装备卡是否满足装备条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>-1
		-- 检查卡组中是否存在符合条件的装备魔法卡
		and Duel.IsExistingMatchingCard(c33578406.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果作用
function c33578406.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从卡组选择符合条件的装备魔法卡
	local g1=Duel.SelectMatchingCard(tp,c33578406.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g1:GetFirst()
	if not tc then return end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择可以装备该装备卡的怪兽
	local g2=Duel.SelectMatchingCard(tp,c33578406.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc)
	-- 将装备卡装备给目标怪兽
	Duel.Equip(tp,tc,g2:GetFirst())
end
