--タイラント・バースト・ドラゴン
-- 效果：
-- 这张卡在用「克里底亚之牙」的效果把自己的手卡·场上的「暴君翼」送去墓地的场合才能特殊召唤。
-- ①：这张卡可以向对方怪兽全部各作1次攻击。
-- ②：以自己场上1只怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
-- ③：用这张卡的效果把这张卡装备的怪兽攻击力·守备力上升400，同1次的战斗阶段中可以作3次攻击。
function c58293343.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡在用「克里底亚之牙」的效果把自己的手卡·场上的「暴君翼」送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ①：这张卡可以向对方怪兽全部各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：以自己场上1只怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。③：用这张卡的效果把这张卡装备的怪兽攻击力·守备力上升400，同1次的战斗阶段中可以作3次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c58293343.eqtg)
	e3:SetOperation(c58293343.eqop)
	c:RegisterEffect(e3)
end
c58293343.material_trap=57470761
-- ②号效果的发动准备与条件判定：检查魔陷区空位及场上是否存在合法的自己怪兽作为对象
function c58293343.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	-- 判定发动效果的玩家魔陷区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己场上是否存在除自身以外的表侧表示怪兽作为合法的效果对象
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- ②号效果的执行：将自身作为装备卡装备给目标怪兽，并赋予其攻击力·守备力上升以及可以作3次攻击的效果
function c58293343.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsLocation(LOCATION_SZONE) or c:IsFacedown() then return end
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区是否有空位，以及目标怪兽是否仍由自己控制、是否表侧表示、是否仍与效果相关联
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若装备条件不满足，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- ②：以自己场上1只怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetLabelObject(tc)
	e1:SetValue(c58293343.eqlimit)
	c:RegisterEffect(e1)
	-- ③：用这张卡的效果把这张卡装备的怪兽攻击力·守备力上升400
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(400)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 同1次的战斗阶段中可以作3次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(2)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e4)
end
-- 装备限制判定：限制这张卡只能装备给作为效果对象的怪兽
function c58293343.eqlimit(e,c)
	return c==e:GetLabelObject()
end
