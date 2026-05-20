--御巫の誘い輪舞
-- 效果：
-- 可以给对方场上的怪兽装备。这个卡名的卡在1回合只能发动1张。
-- ①：「御巫的诱轮舞」在自己场上只能有1张表侧表示存在。
-- ②：只要自己场上有「御巫」怪兽存在，得到装备怪兽的控制权。
-- ③：装备怪兽只要在自己场上存在，不能把效果发动。
-- ④：这张卡从场上离开时装备怪兽送去墓地。
function c79912449.initial_effect(c)
	c:SetUniqueOnField(1,0,79912449)
	-- 可以给对方场上的怪兽装备。这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCountLimit(1,79912449+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c79912449.target)
	e1:SetOperation(c79912449.activate)
	c:RegisterEffect(e1)
	-- 可以给对方场上的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c79912449.eqlimit)
	c:RegisterEffect(e2)
	-- ②：只要自己场上有「御巫」怪兽存在，得到装备怪兽的控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetCondition(c79912449.ctcon)
	e3:SetValue(c79912449.ctval)
	c:RegisterEffect(e3)
	-- ③：装备怪兽只要在自己场上存在，不能把效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_TRIGGER)
	e4:SetCondition(c79912449.con)
	c:RegisterEffect(e4)
	-- ④：这张卡从场上离开时装备怪兽送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetOperation(c79912449.tgop)
	c:RegisterEffect(e5)
end
-- 效果发动的对象选择与信息设置
function c79912449.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置将该怪兽装备的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 效果发动时的装备处理
function c79912449.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备限制：只能装备在对方场上的怪兽上
function c79912449.eqlimit(e,c)
	return e:GetHandlerPlayer()~=c:GetControler() or e:GetHandler():GetEquipTarget()==c
end
-- 过滤自己场上表侧表示的「御巫」怪兽
function c79912449.filter(c)
	return c:IsSetCard(0x18d) and c:IsFaceup()
end
-- 控制权转移效果的适用条件
function c79912449.ctcon(e)
	-- 检查自己场上是否存在表侧表示的「御巫」怪兽
	return Duel.IsExistingMatchingCard(c79912449.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 将控制权转移给装备卡的控制者
function c79912449.ctval(e,c)
	return e:GetHandlerPlayer()
end
-- 装备怪兽在自己场上存在时的条件判定
function c79912449.con(e)
	return e:GetHandler():GetEquipTarget():IsControler(e:GetHandlerPlayer())
end
-- 装备卡离场时将装备怪兽送去墓地的处理
function c79912449.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将装备怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
