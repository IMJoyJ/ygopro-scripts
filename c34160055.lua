--龍炎剣の使い手
-- 效果：
-- 自己场上有「使龙炎剑的高手」以外的怪兽召唤时，可以把那只怪兽的等级上升1星，这张卡的攻击力直到结束阶段时上升300。
function c34160055.initial_effect(c)
	-- 自己场上有「使龙炎剑的高手」以外的怪兽召唤时，可以把那只怪兽的等级上升1星，这张卡的攻击力直到结束阶段时上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34160055,0))  --"等级攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c34160055.target)
	e1:SetOperation(c34160055.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的怪兽组，确保该怪兽是自己控制且不是「使龙炎剑的高手」
function c34160055.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:IsControler(tp) and not tc:IsCode(34160055) end
	tc:CreateEffectRelation(e)
end
-- 将目标怪兽的等级上升1星，将此卡的攻击力直到结束阶段时上升300
function c34160055.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 把那只怪兽的等级上升1星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 这张卡的攻击力直到结束阶段时上升300
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(300)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
		end
	end
end
