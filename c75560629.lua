--フリント
-- 效果：
-- 这张卡装备的怪兽，不能改变表示形式和攻击宣言，攻击力下降300。装备怪兽破坏的场合，选择场上1只怪兽，把这张卡装备在那只怪兽上。
function c75560629.initial_effect(c)
	-- 把这张卡装备
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c75560629.target)
	e1:SetOperation(c75560629.operation)
	c:RegisterEffect(e1)
	-- 攻击力下降300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c75560629.flcon)
	e2:SetValue(-300)
	c:RegisterEffect(e2)
	-- 不能...攻击宣言
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetCondition(c75560629.flcon)
	c:RegisterEffect(e3)
	-- 不能改变表示形式
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e4:SetCondition(c75560629.flcon)
	c:RegisterEffect(e4)
	-- 这张卡装备的怪兽
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c75560629.eqlimit)
	c:RegisterEffect(e5)
	-- 装备怪兽破坏的场合，选择场上1只怪兽，把这张卡装备在那只怪兽上。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(75560629,0))  --"装备"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCondition(c75560629.eqcon)
	e6:SetTarget(c75560629.target)
	e6:SetOperation(c75560629.operation)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e7)
end
-- 过滤条件：判定装备怪兽是否不是未被无效的「打火石锁」（用于决定是否适用负面效果）
function c75560629.flcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	return not tc:IsCode(83812099) or tc:IsDisabled()
end
-- 装备限制：不能装备给未被无效且已装备有其他「打火石」的「打火石锁」
function c75560629.eqlimit(e,c)
	return not c:IsCode(83812099) or c:IsDisabled()
		or not c:GetEquipGroup():IsExists(Card.IsCode,1,e:GetHandler(),75560629)
end
-- 过滤场上表侧表示且满足装备限制的怪兽
function c75560629.filter(c)
	return c:IsFaceup() and (not c:IsCode(83812099) or c:IsDisabled()
		or not c:GetEquipGroup():IsExists(Card.IsCode,1,nil,75560629))
end
-- 效果发动时的对象选择与操作信息注册
function c75560629.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c75560629.filter(chkc) end
	-- 在发动准备阶段，检测场上是否存在至少1只可以作为装备对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c75560629.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只满足条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c75560629.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的操作信息为：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡装备给选择的目标怪兽
function c75560629.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判定触发条件：这张卡因失去装备对象而送去墓地，且原装备怪兽是被破坏的
function c75560629.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec and ec:IsReason(REASON_DESTROY)
end
