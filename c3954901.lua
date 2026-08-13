--フェルグラントドラゴン
-- 效果：
-- 这张卡不是从墓地中不能特殊召唤，若没已从场上送去墓地则也不能作从墓地的特殊召唤。
-- ①：这张卡从墓地的特殊召唤成功的场合，以自己墓地1只怪兽为对象发动。这张卡的攻击力上升作为对象的怪兽的等级×200。
function c3954901.initial_effect(c)
	-- 这张卡不是从墓地中不能特殊召唤，若没已从场上送去墓地则也不能作从墓地的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c3954901.spcon)
	c:RegisterEffect(e1)
	-- ①：这张卡从墓地的特殊召唤成功的场合，以自己墓地1只怪兽为对象发动。这张卡的攻击力上升作为对象的怪兽的等级×200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3954901,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c3954901.atkcon)
	e2:SetTarget(c3954901.atktg)
	e2:SetOperation(c3954901.atkop)
	c:RegisterEffect(e2)
end
-- 特殊召唤条件判定：该卡必须位于墓地且曾从场上送去墓地，才允许从墓地特殊召唤。
function c3954901.spcon(e)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 诱发效果发动条件：该卡从墓地特殊召唤成功，即特殊召唤成功前所在区域为墓地。
function c3954901.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 取对象处理：发动时选择自己墓地1只等级1以上的怪兽作为对象；连锁处理时验证对象是否为满足条件的卡。
function c3954901.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsLevelAbove(1) end
	if chk==0 then return true end
	-- 向当前玩家发送选择对象的提示信息，显示“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己墓地选择1只等级1以上的怪兽，将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsLevelAbove,tp,LOCATION_GRAVE,0,1,1,nil,1)
end
-- 效果处理：若对象怪兽仍与效果相关且自身表侧表示且在场上，则给自身增加攻击力，数值为对象怪兽当前等级×200，该攻击力变化在标准重置条件（离场、无效等）时重置。
function c3954901.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中登记的第一张对象卡（即被选择的墓地怪兽）并存入变量tc。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升作为对象的怪兽的等级×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetLevel()*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
