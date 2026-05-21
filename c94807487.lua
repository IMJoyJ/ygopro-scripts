--ホープ剣スラッシュ
-- 效果：
-- 「希望皇 霍普」怪兽才能装备。
-- ①：装备怪兽不会被效果破坏。
-- ②：只要这张卡在魔法与陷阱区域存在，每次怪兽的攻击无效，给这张卡放置1个希望剑指示物。装备怪兽的攻击力上升这张卡的希望剑指示物数量×500。
-- ③：自己场上的装备怪兽把超量素材取除来让效果发动的场合，这张卡可以当作取除的超量素材中的1个使用。
function c94807487.initial_effect(c)
	c:EnableCounterPermit(0x31)
	-- 「希望皇 霍普」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c94807487.target)
	e1:SetOperation(c94807487.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 「希望皇 霍普」怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c94807487.eqlimit)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在魔法与陷阱区域存在，每次怪兽的攻击无效，给这张卡放置1个希望剑指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_ATTACK_DISABLED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(c94807487.regop)
	c:RegisterEffect(e4)
	-- 装备怪兽的攻击力上升这张卡的希望剑指示物数量×500。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetValue(c94807487.value)
	c:RegisterEffect(e5)
	-- ③：自己场上的装备怪兽把超量素材取除来让效果发动的场合，这张卡可以当作取除的超量素材中的1个使用。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(94807487,0))  --"放置1个希望剑指示物"
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c94807487.rcon)
	e6:SetOperation(c94807487.rop)
	c:RegisterEffect(e6)
end
-- 装备限制：只能装备给「希望皇 霍普」怪兽
function c94807487.eqlimit(e,c)
	return c:IsSetCard(0x107f)
end
-- 过滤条件：场上表侧表示的「希望皇 霍普」怪兽
function c94807487.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 装备魔法卡发动时的效果对象选择与处理
function c94807487.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c94807487.filter(chkc) end
	-- 步骤1：检查场上是否存在合法的装备对象
	if chk==0 then return Duel.IsExistingTarget(c94807487.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的「希望皇 霍普」怪兽作为装备对象
	Duel.SelectTarget(tp,c94807487.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的效果处理（执行装备）
function c94807487.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 攻击无效时，给这张卡放置1个希望剑指示物
function c94807487.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x31,1)
end
-- 计算并返回装备怪兽上升的攻击力数值（指示物数量×500）
function c94807487.value(e,c)
	return e:GetHandler():GetCounter(0x31)*500
end
-- 检查是否满足代替取除超量素材的条件（自己场上的装备怪兽作为发动代价取除素材）
function c94807487.rcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_COST)~=0 and re:GetHandler():IsType(TYPE_XYZ)
		and ep==e:GetOwnerPlayer() and e:GetHandler():GetEquipTarget()==re:GetHandler() and re:GetHandler():GetOverlayCount()>=ev-1
end
-- 代替取除超量素材时的具体操作（将此卡送去墓地）
function c94807487.rop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡作为发动代价送去墓地
	return Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
