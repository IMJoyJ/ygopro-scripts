--女神の聖弓－アルテミス
-- 效果：
-- 这张卡在用「赫谟之爪」的效果把自己的手卡·场上的战士族怪兽送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只怪兽为对象发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：这张卡的效果让这张卡装备中的场合，自己·对方的战斗阶段中只有1次，对方发动的魔法·陷阱·怪兽的效果无效。这个效果适用的战斗阶段中，装备怪兽可以作2次攻击。
function c83743222.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡在用「赫谟之爪」的效果把自己的手卡·场上的战士族怪兽送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上1只怪兽为对象发动。这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c83743222.eqtg)
	e2:SetOperation(c83743222.eqop)
	c:RegisterEffect(e2)
end
c83743222.material_race=RACE_WARRIOR
-- ①号效果的靶向/发动准备：确认场上是否存在除自身以外的表侧表示怪兽作为装备对象，并进行取对象选择。
function c83743222.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	if chk==0 then return true end
	-- 给玩家发送提示信息，提示选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只除自身以外的表侧表示怪兽作为效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- ①号效果的执行：将自身作为装备卡装备给目标怪兽，并注册装备限制以及无效对方效果的永续/辅助效果。
function c83743222.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsLocation(LOCATION_SZONE) or c:IsFacedown() then return end
	-- 检查魔陷区是否有空位、对象怪兽是否仍表侧表示存在以及是否仍与效果相关联，若不满足则将自身送去墓地。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 因效果处理无法装备时，将这张卡送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽。
	Duel.Equip(tp,c,tc)
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(c83743222.eqlimit)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果让这张卡装备中的场合，自己·对方的战斗阶段中只有1次，对方发动的魔法·陷阱·怪兽的效果无效。这个效果适用的战斗阶段中，装备怪兽可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c83743222.negcon)
	e2:SetOperation(c83743222.negop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 限制此卡只能装备给通过效果选择的目标怪兽。
function c83743222.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②号效果的发动条件：此卡处于装备状态，且当前处于自己或对方的战斗阶段，并且是对方发动的效果。
function c83743222.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return e:GetHandler():GetEquipTarget() and (ph>PHASE_MAIN1 and ph<PHASE_MAIN2) and ep~=tp
end
-- ②号效果的执行：无效对方发动的效果，并在该战斗阶段内赋予装备怪兽可以作2次攻击的效果。
function c83743222.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果成功使对方发动的效果无效。
	if Duel.NegateEffect(ev,true) then
		-- 这个效果适用的战斗阶段中，装备怪兽可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
