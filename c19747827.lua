--真紅眼の黒竜剣
-- 效果：
-- 这张卡在用「赫谟之爪」的效果把自己的手卡·场上的龙族怪兽送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只怪兽为对象发动。这张卡当作攻击力上升1000的装备卡使用给那只怪兽装备。
-- ②：用这张卡的效果把这张卡装备的怪兽的攻击力·守备力上升双方的场上·墓地的龙族怪兽数量×500。
function c19747827.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡在用「赫谟之爪」的效果把自己的手卡·场上的龙族怪兽送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只怪兽为对象发动。这张卡当作攻击力上升1000的装备卡使用给那只怪兽装备。②：用这张卡的效果把这张卡装备的怪兽的攻击力·守备力上升双方的场上·墓地的龙族怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c19747827.eqtg)
	e2:SetOperation(c19747827.eqop)
	c:RegisterEffect(e2)
end
c19747827.material_race=RACE_DRAGON
-- ①效果发动时的取对象处理：若正在检查对象，则校验对象是场上表侧表示且不是这张卡；在发动时无条件允许，随后提示并选择1只表侧表示怪兽作为对象（不能选择自身）。
function c19747827.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	if chk==0 then return true end
	-- 向操作者显示“请选择要装备的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方场上选择1只表侧表示怪兽作为装备对象，且不能选择这张卡自身，并将选择结果设为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- ①效果处理：获取对象怪兽；若这张卡已不关联或处于魔陷区/里侧，或对象里侧/不关联/自身魔陷区无空位，则将这张卡送去墓地；否则将其装备给对象怪兽，并注册只能装备给该怪兽的限制、攻击力上升1000以及②的攻防上升效果。
function c19747827.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsLocation(LOCATION_SZONE) or c:IsFacedown() then return end
	-- 判定装备条件：自身魔陷区是否有空位、对象怪兽是否仍表侧表示且与效果仍有关联；任一不满足则进入装备失败处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备条件不满足时，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给选择的对象怪兽。
	Duel.Equip(tp,c,tc)
	-- 给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(c19747827.eqlimit)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- ②：用这张卡的效果把这张卡装备的怪兽的攻击力·守备力上升双方的场上·墓地的龙族怪兽数量×500（此段实现攻击力部分，守备力部分由克隆效果实现）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c19747827.atkval)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
-- 装备限制判定函数：仅当对象卡与效果记录的目标（LabelObject）相同才允许装备，即只能装备给选择的那只怪兽。
function c19747827.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 计数过滤条件：用于筛选双方场上·墓地中表侧表示的龙族怪兽。
function c19747827.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- ②的攻防上升值计算函数：统计双方场上·墓地表侧表示龙族怪兽数量并乘以500，作为攻击力（或守备力）上升数值。
function c19747827.atkval(e,c)
	-- 返回龙族怪兽数量×500的数值，作为攻防上升量。
	return Duel.GetMatchingGroupCount(c19747827.cfilter,0,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)*500
end
