--アマゾネスの秘宝
-- 效果：
-- 名字带有「亚马逊」的怪兽才能装备。装备怪兽1回合只有1次不会被战斗破坏。装备怪兽攻击的场合，受到那次攻击的怪兽在伤害计算后破坏。
function c79965360.initial_effect(c)
	-- 名字带有「亚马逊」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c79965360.target)
	e1:SetOperation(c79965360.operation)
	c:RegisterEffect(e1)
	-- 名字带有「亚马逊」的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c79965360.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽1回合只有1次不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetValue(c79965360.valcon)
	e3:SetCountLimit(1)
	c:RegisterEffect(e3)
	-- 装备怪兽攻击的场合，受到那次攻击的怪兽在伤害计算后破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(79965360,0))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c79965360.descon)
	e4:SetTarget(c79965360.destg)
	e4:SetOperation(c79965360.desop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给「亚马逊」怪兽
function c79965360.eqlimit(e,c)
	return c:IsSetCard(0x4)
end
-- 过滤条件：场上表侧表示的「亚马逊」怪兽
function c79965360.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4)
end
-- 放入连锁的发动准备：选择场上1只表侧表示的「亚马逊」怪兽作为装备对象
function c79965360.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c79965360.filter(chkc) end
	-- 检查场上是否存在可以作为装备对象的「亚马逊」怪兽
	if chk==0 then return Duel.IsExistingTarget(c79965360.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的「亚马逊」怪兽作为效果对象
	Duel.SelectTarget(tp,c79965360.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将自身作为装备卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 发动效果处理：将这张卡装备给选择的怪兽
function c79965360.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 不破坏的保护条件：仅在受到战斗破坏时适用
function c79965360.valcon(e,re,r,rp)
	return r==REASON_BATTLE
end
-- 破坏效果的发动条件：装备怪兽进行攻击且存在攻击对象
function c79965360.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击怪兽是否为装备怪兽，且被攻击的怪兽存在
	return e:GetHandler():GetEquipTarget()==Duel.GetAttacker() and Duel.GetAttackTarget()
end
-- 破坏效果的发动准备：将受到攻击的怪兽设为破坏操作的对象
function c79965360.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：破坏受到攻击的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 破坏效果的处理：将受到那次攻击的怪兽破坏
function c79965360.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取受到攻击的怪兽
	local tc=Duel.GetAttackTarget()
	if tc:IsRelateToBattle() then
		-- 将受到攻击的怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
