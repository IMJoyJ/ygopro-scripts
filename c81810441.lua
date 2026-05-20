--星輝士の因子
-- 效果：
-- 自己场上的「星骑士」怪兽才能装备。
-- ①：装备怪兽的攻击力·守备力上升500。装备怪兽不受对方的卡的效果影响。
-- ②：自己场上有「星骑士」怪兽以外的怪兽表侧表示存在的场合这张卡破坏。
function c81810441.initial_effect(c)
	-- 自己场上的「星骑士」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c81810441.target)
	e1:SetOperation(c81810441.operation)
	c:RegisterEffect(e1)
	-- 自己场上的「星骑士」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c81810441.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力·守备力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 装备怪兽不受对方的卡的效果影响。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(c81810441.efilter)
	c:RegisterEffect(e5)
	-- ②：自己场上有「星骑士」怪兽以外的怪兽表侧表示存在的场合这张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_SELF_DESTROY)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c81810441.descon)
	c:RegisterEffect(e6)
end
-- 过滤条件：自己场上表侧表示的「星骑士」怪兽
function c81810441.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9c)
end
-- 装备魔法卡发动时的效果处理：选择自己场上1只表侧表示的「星骑士」怪兽为对象
function c81810441.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c81810441.filter(chkc) end
	-- 检查自己场上是否存在至少1只可以作为装备对象的表侧表示「星骑士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c81810441.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「星骑士」怪兽作为装备对象
	Duel.SelectTarget(tp,c81810441.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理：将这张卡装备给选择的对象怪兽
function c81810441.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的第一个对象（即要装备的怪兽）
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备限制：只能装备在自己场上的「星骑士」怪兽上
function c81810441.eqlimit(e,c)
	return c:IsSetCard(0x9c) and c:GetControler()==e:GetHandler():GetControler()
end
-- 免疫效果过滤：不受对方玩家拥有的卡的效果影响
function c81810441.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
-- 过滤条件：自己场上表侧表示的「星骑士」怪兽以外的怪兽
function c81810441.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x9c)
end
-- 自我破坏效果的触发条件：自己场上存在「星骑士」怪兽以外的表侧表示怪兽
function c81810441.descon(e)
	-- 检查自己场上是否存在至少1只「星骑士」怪兽以外的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c81810441.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
