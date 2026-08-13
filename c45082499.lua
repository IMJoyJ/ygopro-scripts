--ZW－雷神猛虎剣
-- 效果：
-- ①：「异热同心武器-雷神猛虎剑」在自己场上只能有1张表侧表示存在。
-- ②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1200的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
-- ③：这张卡装备中的场合，自己场上的「异热同心武器」卡不会被对方的效果破坏。
-- ④：装备怪兽被效果破坏的场合，作为代替把这张卡破坏。
function c45082499.initial_effect(c)
	c:SetUniqueOnField(1,0,45082499)
	-- ①「异热同心武器-雷神猛虎剑」在自己场上只能有1张表侧表示存在；②以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1200的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
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
	-- 指定该保护效果适用的对象为场上（己方）的「异热同心武器」卡（setcode 0x107e）。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x107e))
	e2:SetCondition(c45082499.indcon)
	-- 设定“不会被对方的效果破坏”的判定条件：只有对方玩家的效果造成破坏时才适用，己方效果不保护。
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
-- 作为②发动条件，检查这张卡在自己场上是否满足“只能有1张表侧表示存在”的唯一性规则（对应①）。
function c45082499.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 过滤函数：选择自己场上1只表侧表示的「希望皇 霍普」怪兽（setcode 0x107f）作为装备对象。
function c45082499.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- ②的发动目标选择处理：以自己场上1只表侧表示「希望皇 霍普」怪兽为对象；若为效果处理中的对象回调则校验目标合法性；若为发动判定则确认存在合法对象。
function c45082499.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c45082499.filter(chkc) end
	-- 发动判定时确认自己魔法与陷阱区域有空位，以便后续将这张卡装备到怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动判定时确认自己场上存在至少1只表侧表示的「希望皇 霍普」怪兽可以作为装备对象。
		and Duel.IsExistingTarget(c45082499.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只表侧表示的「希望皇 霍普」怪兽，并将其设为这张卡装备效果的对象。
	Duel.SelectTarget(tp,c45082499.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：验证这张卡与目标对象的状态是否合法；若因场地/对象/唯一性等原因无法装备，则将此卡送去墓地；否则执行装备流程。
function c45082499.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 取得发动时选择的那只「希望皇 霍普」怪兽作为装备对象。
	local tc=Duel.GetFirstTarget()
	-- 装备前判定：若魔陷区无空位、目标怪兽已不在自己场上或变成里侧/与效果失去联系、或这张卡不满足唯一性限制，则装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 装备失败时，以效果原因（REASON_EFFECT）把这张卡送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c45082499.zw_equip_monster(c,tp,tc)
end
-- 将这张卡装备给目标怪兽，并赋予“只能装备给该怪兽”的限制以及攻击力上升1200的装备效果。
function c45082499.zw_equip_monster(c,tp,tc)
	-- 执行装备动作；如果装备失败（例如对象已不合法）则直接结束处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 从自己的手卡·场上把这张卡当作攻击力上升1200的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c45082499.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 攻击力上升1200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1200)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制判定：只有当初选择的那只「希望皇 霍普」怪兽（LabelObject）才能装备这张卡，其他怪兽不能装备。
function c45082499.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 保护效果条件：这张卡处于装备状态（存在装备对象），即满足“这张卡装备中的场合”。
function c45082499.indcon(e)
	return e:GetHandler():GetEquipTarget()
end
-- 代替破坏判定：仅当装备怪兽要被“效果”破坏时，才使用这张卡作为代替破坏；战斗破坏等不触发。
function c45082499.repval(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
