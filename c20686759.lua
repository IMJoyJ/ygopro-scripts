--D・レトロエンジン
-- 效果：
-- 名字带有「变形斗士」的怪兽才能装备。装备怪兽被破坏的场合，双方受到那只怪兽的原本攻击力数值的伤害。
function c20686759.initial_effect(c)
	-- 名字带有「变形斗士」的怪兽才能装备。装备怪兽被破坏的场合，双方受到那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c20686759.target)
	e1:SetOperation(c20686759.operation)
	c:RegisterEffect(e1)
	-- 名字带有「变形斗士」的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c20686759.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽被破坏的场合，双方受到那只怪兽的原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c20686759.damcon)
	e3:SetTarget(c20686759.damtg)
	e3:SetOperation(c20686759.damop)
	c:RegisterEffect(e3)
end
-- 判断装备对象是否为名字带有「变形斗士」的怪兽
function c20686759.eqlimit(e,c)
	return c:IsSetCard(0x26)
end
-- 筛选场上表侧表示的名字带有「变形斗士」的怪兽
function c20686759.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x26)
end
-- 选择场上表侧表示的名字带有「变形斗士」的怪兽作为装备对象，并设置操作信息
function c20686759.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c20686759.filter(chkc) end
	-- 检查是否存在符合条件的目标怪兽用于装备
	if chk==0 then return Duel.IsExistingTarget(c20686759.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择一个符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c20686759.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次操作的信息为装备一张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 将装备卡装备给选定的目标怪兽
function c20686759.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备动作，将当前卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 检查装备卡是否因失去装备对象且该对象被破坏而触发效果
function c20686759.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec and ec:IsReason(REASON_DESTROY)
end
-- 计算并记录应造成的伤害值，并设置操作信息为对双方造成伤害
function c20686759.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetPreviousEquipTarget():GetBaseAttack()
	if dam<0 then dam=0 end
	e:SetLabel(dam)
	-- 设置操作信息为对所有玩家造成指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dam)
end
-- 对双方玩家造成等于原装备怪兽攻击力的伤害
function c20686759.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 对对手造成等于原装备怪兽攻击力的伤害
	Duel.Damage(1-tp,e:GetLabel(),REASON_EFFECT,true)
	-- 对自己造成等于原装备怪兽攻击力的伤害
	Duel.Damage(tp,e:GetLabel(),REASON_EFFECT,true)
	-- 完成伤害处理流程并触发相关时点
	Duel.RDComplete()
end
