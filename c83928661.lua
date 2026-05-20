--未界域捕縛作戦
-- 效果：
-- 「未界域」怪兽才能装备。
-- ①：装备怪兽的攻击力·守备力上升800，不会被效果破坏。
-- ②：装备怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c83928661.initial_effect(c)
	-- 「未界域」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c83928661.target)
	e1:SetOperation(c83928661.activate)
	c:RegisterEffect(e1)
	-- 「未界域」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c83928661.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力·守备力上升800
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(800)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 不会被效果破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- ②：装备怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end
-- 过滤场上表侧表示的「未界域」怪兽
function c83928661.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x11e)
end
-- 装备魔法卡发动时的效果处理，选择场上1只符合条件的怪兽作为对象
function c83928661.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c83928661.filter(chkc) end
	-- 检查场上是否存在可以装备的表侧表示「未界域」怪兽
	if chk==0 then return Duel.IsExistingTarget(c83928661.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的「未界域」怪兽作为装备对象
	Duel.SelectTarget(tp,c83928661.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果的操作分类为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理，将这张卡装备给目标怪兽
function c83928661.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 限制这张卡只能装备给「未界域」怪兽
function c83928661.eqlimit(e,c)
	return c:IsSetCard(0x11e)
end
