--DZW－魔装鵺妖衣
-- 效果：
-- 自己的主要阶段时，手卡或者自己场上的这只怪兽可以当作装备卡使用给自己场上的名字带有「混沌No.39」的怪兽装备。此外，这张卡当作装备卡使用而装备中的场合，装备怪兽不会被战斗破坏。装备怪兽的攻击没让对方怪兽被破坏的伤害步骤结束时，可以把那只对方怪兽的攻击力变成0并只再1次可以向同只怪兽继续攻击。
function c6330307.initial_effect(c)
	-- 自己的主要阶段时，手卡或者自己场上的这只怪兽可以当作装备卡使用给自己场上的名字带有「混沌No.39」的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6330307,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c6330307.eqtg)
	e1:SetOperation(c6330307.eqop)
	c:RegisterEffect(e1)
	-- 此外，这张卡当作装备卡使用而装备中的场合，装备怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击没让对方怪兽被破坏的伤害步骤结束时，可以把那只对方怪兽的攻击力变成0并只再1次可以向同只怪兽继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6330307,1))  --"多次攻击"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c6330307.atkcon)
	e3:SetOperation(c6330307.atkop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的名字带有「混沌No.39」的怪兽
function c6330307.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f) and c:IsSetCard(0x1048)
end
-- 装备效果的发动准备与对象选择判定
function c6330307.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c6330307.filter(chkc) end
	-- 判定自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己场上是否存在可以装备的「混沌No.39」怪兽
		and Duel.IsExistingTarget(c6330307.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「混沌No.39」怪兽作为效果对象
	Duel.SelectTarget(tp,c6330307.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果的发动处理
function c6330307.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取作为装备对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区是否有空位、对象怪兽是否仍在场上表侧表示存在、以及此卡是否能唯一存在于场上
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若不满足装备条件，则将此卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c6330307.zw_equip_monster(c,tp,tc)
end
-- 执行将此卡作为装备卡装备给目标怪兽的辅助函数
function c6330307.zw_equip_monster(c,tp,tc)
	-- 将此卡装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc) then return end
	-- 当作装备卡使用给自己场上的名字带有「混沌No.39」的怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c6330307.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制：此卡只能装备给作为对象的怪兽
function c6330307.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判定是否满足“装备怪兽的攻击没让对方怪兽被破坏的伤害步骤结束时”的发动条件
function c6330307.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local at=Duel.GetAttackTarget()
	return at and a==e:GetHandler():GetEquipTarget() and at:IsRelateToBattle() and at:GetAttack()>0 and a:IsChainAttackable()
end
-- 降低对方怪兽攻击力并追加攻击的效果处理
function c6330307.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的被攻击怪兽
	local at=Duel.GetAttackTarget()
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if at:IsRelateToBattle() and not at:IsImmuneToEffect(e) and at:GetAttack()>0 then
		-- 把那只对方怪兽的攻击力变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		at:RegisterEffect(e1)
		-- 使装备怪兽可以再1次向同1只怪兽继续攻击
		Duel.ChainAttack(at)
	end
end
