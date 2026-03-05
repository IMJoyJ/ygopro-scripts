--D・レトロエンジン
-- 效果：
-- 名字带有「变形斗士」的怪兽才能装备。装备怪兽被破坏的场合，双方受到那只怪兽的原本攻击力数值的伤害。
function c20686759.initial_effect(c)
	-- 名字带有「变形斗士」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c20686759.target)
	e1:SetOperation(c20686759.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽被破坏的场合，双方受到那只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c20686759.eqlimit)
	c:RegisterEffect(e2)
	-- 效果作用
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c20686759.damcon)
	e3:SetTarget(c20686759.damtg)
	e3:SetOperation(c20686759.damop)
	c:RegisterEffect(e3)
end
-- 装备对象必须为名字带有「变形斗士」的怪兽
function c20686759.eqlimit(e,c)
	return c:IsSetCard(0x26)
end
-- 过滤名字带有「变形斗士」的表侧表示怪兽
function c20686759.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x26)
end
-- 选择装备对象，要求为名字带有「变形斗士」的表侧表示怪兽
function c20686759.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c20686759.filter(chkc) end
	-- 判断是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(c20686759.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽作为装备对象
	Duel.SelectTarget(tp,c20686759.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备操作
function c20686759.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断装备怪兽被破坏且失去装备对象
function c20686759.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec and ec:IsReason(REASON_DESTROY)
end
-- 计算并设置伤害值
function c20686759.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetPreviousEquipTarget():GetBaseAttack()
	if dam<0 then dam=0 end
	e:SetLabel(dam)
	-- 设置伤害效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dam)
end
-- 造成伤害效果
function c20686759.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给对方造成伤害
	Duel.Damage(1-tp,e:GetLabel(),REASON_EFFECT,true)
	-- 给自己造成伤害
	Duel.Damage(tp,e:GetLabel(),REASON_EFFECT,true)
	-- 完成伤害处理时点
	Duel.RDComplete()
end
