--ロケット・ヘルモス・キャノン
-- 效果：
-- 这张卡在用「赫谟之爪」的效果把自己的手卡·场上的战士族怪兽送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只怪兽为对象发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：用这张卡的效果把这张卡装备的怪兽在同1次的战斗阶段中可以作2次攻击，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c46354113.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡在用「赫谟之爪」的效果把自己的手卡·场上的战士族怪兽送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只怪兽为对象发动。这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c46354113.eqtg)
	e2:SetOperation(c46354113.eqop)
	c:RegisterEffect(e2)
end
c46354113.material_race=RACE_WARRIOR
-- 发动时先检查被连锁选择的对象是否合法（须为场上表侧表示且不是这张卡自身）；若为发动前检查则返回true，随后提示并选择场上1只除自身以外的表侧表示怪兽作为对象。
function c46354113.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	if chk==0 then return true end
	-- 给玩家显示“请选择要装备的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方主要怪兽区选择1张表侧表示怪兽（不能选这张卡自身）作为效果对象，选定后与当前连锁建立关联。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 效果处理：若这张卡仍与效果相关且未被送去魔陷区或变成里侧，同时己方魔陷区有空位、对象怪兽仍表侧且与效果相关，则将这张卡装备给对象并赋予装备限制、额外攻击次数和贯穿伤害效果；否则这张卡因效果送去墓地。
function c46354113.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsLocation(LOCATION_SZONE) or c:IsFacedown() then return end
	-- 检查己方魔陷区是否没有可用空格，或者对象怪兽已变成里侧/不再与效果关联，条件成立则无法进行装备。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 由于无法装备，将这张火箭赫谟炮以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 把这张卡作为装备卡装备给选定的对象怪兽。
	Duel.Equip(tp,c,tc)
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(c46354113.eqlimit)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- ②：用这张卡的效果把这张卡装备的怪兽在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
-- 装备限制函数：判定将要装备的怪兽是否为效果发动时选定的对象，是则允许装备，从而确保这张卡只能装备给那只怪兽。
function c46354113.eqlimit(e,c)
	return c==e:GetLabelObject()
end
