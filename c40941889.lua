--ZW－阿修羅副腕
-- 效果：
-- ①：「异热同心武器-阿修罗副腕」在自己场上只能有1张表侧表示存在。
-- ②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1000的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
-- ③：这张卡装备中的场合，装备怪兽可以向对方场上的全部怪兽各作1次攻击。
function c40941889.initial_effect(c)
	c:SetUniqueOnField(1,0,40941889)
	-- 效果原文：②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1000的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40941889,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCondition(c40941889.eqcon)
	e1:SetTarget(c40941889.eqtg)
	e1:SetOperation(c40941889.eqop)
	c:RegisterEffect(e1)
	-- 效果原文：③：这张卡装备中的场合，装备怪兽可以向对方场上的全部怪兽各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 规则层面：检查此卡在场上是否唯一存在
function c40941889.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 规则层面：过滤场上自己方的「希望皇 霍普」怪兽
function c40941889.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 规则层面：设置选择目标的条件，确保能选择到符合条件的怪兽
function c40941889.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40941889.filter(chkc) end
	-- 规则层面：判断场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 规则层面：判断自己场上是否存在符合条件的「希望皇 霍普」怪兽
		and Duel.IsExistingTarget(c40941889.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 规则层面：提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 规则层面：选择目标怪兽
	Duel.SelectTarget(tp,c40941889.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 规则层面：执行装备操作，若条件不满足则将卡送入墓地
function c40941889.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 规则层面：获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 规则层面：判断装备条件是否满足，包括区域是否足够、目标是否为己方、是否表侧表示等
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 规则层面：将此卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c40941889.zw_equip_monster(c,tp,tc)
end
-- 规则层面：执行装备操作并注册装备限制和攻击力加成效果
function c40941889.zw_equip_monster(c,tp,tc)
	-- 规则层面：尝试将卡装备给目标怪兽，若失败则返回
	if not Duel.Equip(tp,c,tc) then return end
	-- 效果原文：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1000的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c40941889.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 效果原文：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1000的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 规则层面：限制此卡只能装备给特定怪兽
function c40941889.eqlimit(e,c)
	return c==e:GetLabelObject()
end
