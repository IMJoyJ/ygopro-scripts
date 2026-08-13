--ロケット・パイルダー
-- 效果：
-- 装备怪兽攻击的场合，装备怪兽不会被战斗破坏。装备怪兽进行攻击的伤害步骤结束时，受到装备怪兽的攻击的怪兽的攻击力直到结束阶段时下降装备怪兽的攻击力数值。
function c27863269.initial_effect(c)
	-- 作为装备魔法发动，选择场上1只表侧表示怪兽作为装备对象（对应效果原文中‘装备怪兽’的装备前提）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c27863269.target)
	e1:SetOperation(c27863269.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽攻击的场合，装备怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c27863269.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 装备对象必须为怪兽（对应效果原文中的‘装备怪兽’）。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 装备怪兽进行攻击的伤害步骤结束时，受到装备怪兽的攻击的怪兽的攻击力直到结束阶段时下降装备怪兽的攻击力数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27863269,0))  --"攻击下降"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(c27863269.atkcon)
	e4:SetOperation(c27863269.atkop)
	c:RegisterEffect(e4)
end
-- 发动时的目标选择处理：判断是否存在可装备的表侧表示怪兽，让玩家选择1只装备对象，并登记为效果对象和设置装备操作信息。
function c27863269.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动合法性检查：场上（双方怪兽区域）是否存在至少1只表侧表示怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，提示文本为‘请选择要装备的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方的怪兽区域选择1只表侧表示怪兽，将其设为这张卡的装备对象（取对象）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明此效果将进行装备卡装备；目标为此卡自身，数量1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：取得发动时选择的对象，若此装备卡和对象仍与效果关联且对象表侧，则将此卡装备给对象怪兽。
function c27863269.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的目标怪兽（装备对象）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给对象怪兽，使其成为装备魔法。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- “装备怪兽不会被战斗破坏”效果的满足条件：只有当攻击怪兽就是这张装备卡装备的怪兽时，该效果才适用。
function c27863269.indcon(e)
	-- 检查当前攻击怪兽是否等于这张装备卡装备的怪兽（即装备怪兽在进行攻击）。
	return Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
-- 降攻效果（伤害步骤结束时诱发）的条件：装备怪兽进行攻击的伤害步骤结束，且被攻击怪兽仍与战斗相关并表侧表示。
function c27863269.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得被攻击的怪兽（本次战斗的攻击对象）。
	local at=Duel.GetAttackTarget()
	-- 条件判断：攻击对象存在并仍与本次战斗关联、表侧表示，且攻击者是装备怪兽。
	return at and at:IsRelateToBattle() and at:IsFaceup() and Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
-- 降攻效果处理：取装备怪兽当前攻击力，为攻击对象怪兽附加相同数值的攻击力下降效果，持续到结束阶段。
function c27863269.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前被攻击的怪兽（攻击目标），用于后续攻击力下降计算。
	local at=Duel.GetAttackTarget()
	if not c:IsRelateToEffect(e) or not at:IsRelateToBattle() or at:IsFacedown() then return end
	local atk=c:GetEquipTarget():GetAttack()
	-- 受到装备怪兽的攻击的怪兽的攻击力直到结束阶段时下降装备怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	at:RegisterEffect(e1)
end
