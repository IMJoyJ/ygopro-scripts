--7カード
-- 效果：
-- 机械族怪兽才能装备。装备怪兽的攻击力或者守备力上升700。
function c86198326.initial_effect(c)
	-- 装备怪兽的攻击力或者守备力上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c86198326.target)
	e1:SetOperation(c86198326.operation)
	c:RegisterEffect(e1)
	-- 机械族怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c86198326.eqlimit)
	c:RegisterEffect(e2)
end
-- 定义装备限制：只能装备给机械族怪兽
function c86198326.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE)
end
-- 过滤条件：场上表侧表示的机械族怪兽
function c86198326.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 效果发动的靶向处理：选择场上1只表侧表示的机械族怪兽作为对象，并由玩家选择上升攻击力还是守备力
function c86198326.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c86198326.filter(chkc) end
	-- 判断场上是否存在符合装备条件的表侧表示机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(c86198326.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的机械族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c86198326.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local opt=0
	-- 若目标怪兽拥有守备力，则让玩家选择上升攻击力还是守备力（若无守备力则默认上升攻击力）
	if g:GetFirst():IsDefenseAbove(0) then opt=Duel.SelectOption(tp,aux.Stringid(86198326,0),aux.Stringid(86198326,1)) end  --"攻击力上升７００/守备力上升７００"
	e:SetLabel(opt)
	-- 设置操作信息，表示此效果包含装备自身的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果解决：将自身装备给目标怪兽，并根据玩家的选择适用攻击力或守备力上升700的效果
function c86198326.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=e:GetLabel()
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 装备怪兽的攻击力或者守备力上升700。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		if opt==0 then
			e1:SetCode(EFFECT_UPDATE_ATTACK)
		else
			e1:SetCode(EFFECT_UPDATE_DEFENSE)
		end
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
