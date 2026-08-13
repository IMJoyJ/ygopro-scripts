--脆刃の剣
-- 效果：
-- ①：「脆刃之剑」在自己场上只能有1张表侧表示存在。
-- ②：装备怪兽的攻击力上升2000，装备怪兽的战斗发生的战斗伤害由双方玩家承受。
-- ③：自己受到2000以上的战斗伤害的场合发动。这张卡送去墓地。
function c41927278.initial_effect(c)
	c:SetUniqueOnField(1,0,41927278)
	-- ②：装备怪兽的攻击力上升2000，装备怪兽的战斗发生的战斗伤害由双方玩家承受。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c41927278.target)
	e1:SetOperation(c41927278.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升2000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(2000)
	c:RegisterEffect(e2)
	-- 装备怪兽的战斗发生的战斗伤害由双方玩家承受
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_BOTH_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e3)
	-- ③：自己受到2000以上的战斗伤害的场合发动。这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c41927278.tgcon)
	e4:SetTarget(c41927278.tgtg)
	e4:SetOperation(c41927278.tgop)
	c:RegisterEffect(e4)
	-- 装备怪兽
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 发动时的目标处理：确认对象为场上表侧表示怪兽；非发动时检查是否存在合法目标；提示玩家选择1只表侧表示怪兽作为装备对象，并登记装备类操作信息。
function c41927278.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动时（chk==0）检查场上是否存在至少1只可装备的表侧表示怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 由玩家从双方怪兽区域选择1只表侧表示怪兽，登记为这张卡的装备对象（取对象）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记本连锁的处理信息为‘装备’分类，供后续规则判定使用。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：取得对象，检查这张卡和对象仍与效果关联且对象仍表侧表示后，执行装备。
function c41927278.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象（怪兽）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽，使它后续获得②的加成与战斗伤害分担效果。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- ③的发动条件：本次伤害为对自己造成的战斗伤害，且伤害数值在2000以上。
function c41927278.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE)~=0 and ev>=2000
end
-- ③的发动处理：无需选择对象，直接返回可发动，并登记将自身送去墓地的操作信息。
function c41927278.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明本效果处理时会将这张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- ③的效果处理：确认此卡仍与效果关联后，将其送去墓地。
function c41927278.tgop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果原因把这张卡送去墓地。
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
