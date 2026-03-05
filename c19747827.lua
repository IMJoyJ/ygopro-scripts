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
	-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只怪兽为对象发动。这张卡当作攻击力上升1000的装备卡使用给那只怪兽装备。
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
-- 选择装备对象，从对方场上选择1只表侧表示怪兽作为装备对象。
function c19747827.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	if chk==0 then return true end
	-- 向玩家提示“请选择要装备的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只对方场上的表侧表示怪兽作为装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 装备处理流程，包括检查装备条件、执行装备、设置装备限制和攻击力加成效果。
function c19747827.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsLocation(LOCATION_SZONE) or c:IsFacedown() then return end
	-- 判断装备条件是否满足，若不满足则将装备卡送入墓地。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将装备卡装备给目标怪兽。
	Duel.Equip(tp,c,tc)
	-- 装备对象限制效果，确保只有指定的怪兽能装备此卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(c19747827.eqlimit)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 装备卡的攻击力上升1000效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- ②：用这张卡的效果把这张卡装备的怪兽的攻击力·守备力上升双方的场上·墓地的龙族怪兽数量×500。
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
-- 装备对象限制函数，确保只有指定的怪兽能装备此卡。
function c19747827.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤函数，用于筛选场上或墓地中的龙族怪兽。
function c19747827.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 计算双方场上和墓地中龙族怪兽的数量，并乘以500作为攻击力和守备力的加成。
function c19747827.atkval(e,c)
	-- 返回双方场上和墓地中龙族怪兽数量乘以500的结果。
	return Duel.GetMatchingGroupCount(c19747827.cfilter,0,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)*500
end
