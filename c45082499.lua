--ZW－雷神猛虎剣
-- 效果：
-- ①：「异热同心武器-雷神猛虎剑」在自己场上只能有1张表侧表示存在。
-- ②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1200的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
-- ③：这张卡装备中的场合，自己场上的「异热同心武器」卡不会被对方的效果破坏。
-- ④：装备怪兽被效果破坏的场合，作为代替把这张卡破坏。
function c45082499.initial_effect(c)
	c:SetUniqueOnField(1,0,45082499)
	-- ②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1200的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45082499,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCondition(c45082499.eqcon)
	e1:SetTarget(c45082499.eqtg)
	e1:SetOperation(c45082499.eqop)
	c:RegisterEffect(e1)
	-- ③：这张卡装备中的场合，自己场上的「异热同心武器」卡不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置效果目标为场上所有「异热同心武器」卡
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x107e))
	e2:SetCondition(c45082499.indcon)
	-- 设置效果值为无视对方效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ④：装备怪兽被效果破坏的场合，作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e3:SetValue(c45082499.repval)
	c:RegisterEffect(e3)
end
-- 效果发动条件：自己场上「异热同心武器-雷神猛虎剑」只能有1张表侧表示存在
function c45082499.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 过滤函数：对象怪兽为表侧表示的「希望皇 霍普」怪兽
function c45082499.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 效果目标选择：选择自己场上1只表侧表示的「希望皇 霍普」怪兽
function c45082499.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c45082499.filter(chkc) end
	-- 判断场上是否有足够空位进行装备
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断自己场上是否存在符合条件的「希望皇 霍普」怪兽
		and Duel.IsExistingTarget(c45082499.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c45082499.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：将装备卡装备给目标怪兽
function c45082499.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若条件不满足则将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c45082499.zw_equip_monster(c,tp,tc)
end
-- 执行装备操作并设置装备限制和攻击力加成
function c45082499.zw_equip_monster(c,tp,tc)
	-- 尝试将装备卡装备给目标怪兽，若失败则返回
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备对象限制，只能装备给指定怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c45082499.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 设置装备卡装备时攻击力上升1200
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1200)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备对象限制函数：只能装备给指定的怪兽
function c45082499.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果发动条件：装备卡必须已装备怪兽
function c45082499.indcon(e)
	return e:GetHandler():GetEquipTarget()
end
-- 代替破坏判断函数：仅当破坏原因为效果时才生效
function c45082499.repval(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
