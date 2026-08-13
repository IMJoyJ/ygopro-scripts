--ZW－阿修羅副腕
-- 效果：
-- ①：「异热同心武器-阿修罗副腕」在自己场上只能有1张表侧表示存在。
-- ②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1000的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
-- ③：这张卡装备中的场合，装备怪兽可以向对方场上的全部怪兽各作1次攻击。
function c40941889.initial_effect(c)
	c:SetUniqueOnField(1,0,40941889)
	-- ②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1000的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
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
	-- ③：这张卡装备中的场合，装备怪兽可以向对方场上的全部怪兽各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 发动条件检查：确认这张卡在自己场上满足『同名卡只能有1张表侧表示』的唯一性限制（CheckUniqueOnField）。
function c40941889.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 对象过滤器：选择表侧表示且属于「希望皇」字段（0x107f）的怪兽作为对象。
function c40941889.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 目标处理：若连锁中指定对象，则检查该对象是否在自己怪兽区且为表侧「希望皇 霍普」怪兽；若为发动时判定，则检查存在符合条件对象且自己魔陷区有空位。
function c40941889.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40941889.filter(chkc) end
	-- 检查自己魔陷区是否存在空闲位置，用于放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己怪兽区是否存在至少1只符合过滤器条件的「希望皇 霍普」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c40941889.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要装备的卡”，供选择卡片时使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上的「希望皇 霍普」怪兽中选择1只，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c40941889.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：先检查这张卡和对象是否仍满足装备条件，若满足则将其作为装备卡装备给对象，否则这张卡送去墓地。
function c40941889.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 取得效果发动时所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 装备前的合法性检查：若魔陷区无空位、对象控制权变更、对象变成里侧、对象与效果失去关联、或这张卡不再满足场上唯一性限制，则不能继续装备。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 因装备条件不满足，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c40941889.zw_equip_monster(c,tp,tc)
end
-- 执行装备流程：把这张卡装备给对象，并给这张卡附加装备对象限制（只能装备给该对象）和攻击力上升1000的效果。
function c40941889.zw_equip_monster(c,tp,tc)
	-- 尝试将这张卡装备给对象；如果装备失败（如格子或限制不允许），则直接结束，不进行后续处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 给那只自己的「希望皇 霍普」怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c40941889.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 攻击力上升1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备对象限制判定：当前要装备的怪兽必须是这张卡被指定装备的那只对象怪兽（即LabelObject记录的怪兽）。
function c40941889.eqlimit(e,c)
	return c==e:GetLabelObject()
end
