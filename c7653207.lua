--アクア・ジェット
-- 效果：
-- ①：以自己场上1只鱼族·海龙族·水族怪兽为对象才能发动。那只怪兽的攻击力上升1000。
function c7653207.initial_effect(c)
	-- ①：以自己场上1只鱼族·海龙族·水族怪兽为对象才能发动。那只怪兽的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c7653207.target)
	e1:SetOperation(c7653207.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的鱼族、海龙族或水族怪兽
function c7653207.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 效果发动的靶向检测与对象选择
function c7653207.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7653207.filter(chkc) end
	-- 在发动阶段，检查自己场上是否存在符合条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c7653207.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c7653207.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使作为对象的怪兽攻击力上升1000
function c7653207.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
