--D・パワーユニット
-- 效果：
-- 名字带有「变形斗士」的3星的怪兽才能装备。装备怪兽的原本攻击力变成2倍。发动后第2次的自己的准备阶段时这张卡破坏，自己受到装备怪兽的原本攻击力数值的伤害。
function c7817703.initial_effect(c)
	-- 名字带有「变形斗士」的3星的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c7817703.target)
	e1:SetOperation(c7817703.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的原本攻击力变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetValue(c7817703.value)
	c:RegisterEffect(e2)
	-- 名字带有「变形斗士」的3星的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c7817703.eqlimit)
	c:RegisterEffect(e3)
end
-- 装备限制：只能装备给3星的「变形斗士」怪兽
function c7817703.eqlimit(e,c)
	return c:IsSetCard(0x26) and c:IsLevel(3)
end
-- 过滤条件：场上表侧表示的3星「变形斗士」怪兽
function c7817703.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x26) and c:IsLevel(3)
end
-- 魔法卡发动时的对象选择与效果处理准备
function c7817703.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c7817703.filter(chkc) end
	-- 检查场上是否存在可以装备的合法目标
	if chk==0 then return Duel.IsExistingTarget(c7817703.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择并锁定一个合法的怪兽作为装备对象
	Duel.SelectTarget(tp,c7817703.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 魔法卡发动后的效果处理：装备给目标怪兽并注册后续的自爆效果
function c7817703.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
		-- 发动后第2次的自己的准备阶段时这张卡破坏，自己受到装备怪兽的原本攻击力数值的伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCountLimit(1)
		-- 记录当前发动时的回合数，用于计算后续的准备阶段
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c7817703.descon)
		e1:SetTarget(c7817703.destg)
		e1:SetOperation(c7817703.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
		e:GetHandler():RegisterEffect(e1)
	end
end
-- 装备怪兽的原本攻击力变成2倍的数值计算
function c7817703.value(e,c)
	return c:GetBaseAttack()*2
end
-- 检查是否满足“发动后第2次的自己的准备阶段”这一时间条件
function c7817703.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合数与发动回合数之差是否为4（即发动后第2次自己的准备阶段）
	return Duel.GetTurnCount()-e:GetLabel()==4
end
-- 破坏与伤害效果的发动准备与连锁信息设置
function c7817703.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息，表示该效果包含破坏自身的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置连锁信息，表示该效果包含给与玩家伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0)
end
-- 破坏自身并给与玩家装备怪兽原本攻击力数值伤害的具体处理
function c7817703.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local dam=c:GetEquipTarget():GetBaseAttack()
		-- 尝试破坏这张卡，若破坏失败则不处理后续的伤害效果
		if Duel.Destroy(e:GetHandler(),REASON_EFFECT)==0 then return end
		-- 给与自己装备怪兽原本攻击力数值的伤害
		Duel.Damage(tp,dam,REASON_EFFECT)
	end
end
