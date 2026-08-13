--戦乙女の戦車
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只天使族怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ②：装备怪兽的攻击宣言时才能发动。装备怪兽的攻击力上升500。
function c19190082.initial_effect(c)
	-- 调用辅助函数为该卡注册同盟怪兽的共通效果（装备、代替破坏、解除装备特殊召唤），装备对象限定为天使族怪兽。
	aux.EnableUnionAttribute(c,c19190082.filter)
	-- ②：装备怪兽的攻击宣言时才能发动。装备怪兽的攻击力上升500。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(19190082,2))
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c19190082.atkcon)
	e5:SetOperation(c19190082.atkop)
	c:RegisterEffect(e5)
end
-- 定义装备对象的过滤条件：对象必须是天使族怪兽。
function c19190082.filter(c)
	return c:IsRace(RACE_FAIRY)
end
-- 效果②的发动条件：取得该装备卡当前的装备对象，判断其是否为攻击宣言的怪兽。
function c19190082.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 若装备对象存在，且攻击宣言的怪兽正是该装备怪兽，则发动条件成立。
	return ec and Duel.GetAttacker()==ec
end
-- 效果②处理：该装备卡与效果关联时，为装备怪兽赋予攻击力上升500的永续效果，并随标准事件重置。
function c19190082.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and c:IsRelateToEffect(e) then
		-- 装备怪兽的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
	end
end
