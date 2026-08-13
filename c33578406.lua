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
	-- 装备怪兽的攻击力上升0。
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
-- 装备效果发动时的目标选择函数：检查是否存在表侧表示怪兽可作为装备对象，并选择1只对象，同时设置操作信息为装备本卡。
function c33578406.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动合法性检查：场上必须存在至少1只表侧表示怪兽才能作为装备对象发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为本卡的装备对象（取对象效果）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：本连锁处理中执行将这张卡装备给对象怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备处理的执行函数：装备魔法发动成功且关联有效时，将这张卡装备给选择的怪兽。
function c33578406.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- ②效果的发动条件函数：仅当装备怪兽直接攻击并造成战斗伤害时满足条件。
function c33578406.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定本次战斗伤害来自直接攻击，且造成伤害的怪兽正是这张卡装备的怪兽。
	return Duel.GetAttackTarget()==nil and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- ②效果的目标处理：确认对方场上有怪兽可破坏，并设置破坏对象为对方场上全部怪兽。
function c33578406.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：对方场上必须至少存在1只怪兽才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上当前全部怪兽，作为破坏对象集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 登记操作信息：本次效果将破坏g中的所有怪兽（数量为g:GetCount()）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果的破坏处理：获取对方场上怪兽并全部破坏。
function c33578406.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次获取对方场上当前全部怪兽（不取对象，以处理时的场上情况为准）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因（REASON_EFFECT）将对方场上全部怪兽破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- ③效果的代价函数：以将装备中的这张卡送去墓地为代价发动。
function c33578406.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将这张卡从魔陷区送去墓地（作为发动代价，不视为效果破坏）。
	Duel.SendtoGrave(c,REASON_COST)
end
-- ③效果的卡组检索过滤器：筛选卡组中的‘竹光’装备魔法卡，要求不是「真刀竹光」本身、场上没有同名卡、未被禁止，并且场上存在能装备它的表侧表示怪兽。
function c33578406.filter(c,tp)
	return c:IsSetCard(0x60) and not c:IsCode(33578406) and c:IsType(TYPE_EQUIP)
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 追加条件：场上至少要存在1只表侧表示怪兽能够装备该检索出的装备卡。
		and Duel.IsExistingMatchingCard(c33578406.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
-- 装备目标的过滤器：判断场上怪兽是否表侧表示且可装备所选择的装备卡。
function c33578406.eqfilter(c,tc)
	return c:IsFaceup() and tc:CheckEquipTarget(c)
end
-- ③效果发动合法性：魔陷区存在可装备的空间，且卡组中有符合条件的‘竹光’装备魔法卡可检索。
function c33578406.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件之一：自己的魔陷区有空位（或本卡送墓后空出位置），能放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>-1
		-- 发动条件之二：卡组中存在至少1张符合filter条件的‘竹光’装备魔法卡。
		and Duel.IsExistingMatchingCard(c33578406.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- ③效果的处理函数：从卡组选择1张符合条件的‘竹光’装备魔法卡，再选择场上1只表侧表示怪兽并装备。
function c33578406.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家从卡组选择要装备的‘竹光’装备魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从卡组中选出1张符合条件的‘竹光’装备魔法卡，结果存入g1。
	local g1=Duel.SelectMatchingCard(tp,c33578406.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g1:GetFirst()
	if not tc then return end
	-- 提示玩家选择要装备给的表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象（该怪兽必须能够装备所选的装备卡）。
	local g2=Duel.SelectMatchingCard(tp,c33578406.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc)
	-- 将选择的‘竹光’装备魔法卡装备给选中的怪兽。
	Duel.Equip(tp,tc,g2:GetFirst())
end
