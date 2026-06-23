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
	-- ②：装备怪兽的攻击力上升2000，装备怪兽的战斗发生的战斗伤害由双方玩家承受。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(2000)
	c:RegisterEffect(e2)
	-- ②：装备怪兽的攻击力上升2000，装备怪兽的战斗发生的战斗伤害由双方玩家承受。
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
	-- ①：「脆刃之剑」在自己场上只能有1张表侧表示存在。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 选择装备怪兽，检查是否有满足条件的怪兽可作为对象。
function c41927278.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否满足发动条件，即场上是否存在表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个场上的表侧表示怪兽作为装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将要进行装备操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给选中的怪兽。
function c41927278.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否满足发动条件，即自己受到战斗伤害且伤害值大于等于2000。
function c41927278.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE)~=0 and ev>=2000
end
-- 设置效果处理信息，表示将要将此卡送去墓地。
function c41927278.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息，表示将要将此卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 执行将此卡送去墓地的效果。
function c41927278.tgop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以效果原因送去墓地。
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
