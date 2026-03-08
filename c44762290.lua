--光学迷彩アーマー
-- 效果：
-- 只能给1星的怪兽装备。装备这张卡的怪兽可以对对方进行直接攻击。
function c44762290.initial_effect(c)
	-- 装备这张卡的怪兽可以对对方进行直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c44762290.target)
	e1:SetOperation(c44762290.operation)
	c:RegisterEffect(e1)
	-- 只能给1星的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c44762290.dircon)
	c:RegisterEffect(e2)
	-- 效果作用
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c44762290.eqlimit)
	c:RegisterEffect(e3)
end
-- 检查目标怪兽是否为1星
function c44762290.eqlimit(e,c)
	return c:IsLevel(1)
end
-- 筛选条件：表侧表示且为1星的怪兽
function c44762290.filter(c)
	return c:IsFaceup() and c:IsLevel(1)
end
-- 选择1星的表侧表示怪兽作为装备对象
function c44762290.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c44762290.filter(chkc) end
	-- 判断是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(c44762290.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1星的表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,c44762290.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c44762290.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断装备怪兽是否为装备者控制者
function c44762290.dircon(e)
	return e:GetHandler():GetEquipTarget():GetControler()==e:GetHandlerPlayer()
end
