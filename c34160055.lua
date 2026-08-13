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
-- 选发效果的发动条件判定（chk==0时）：确认因召唤成功而触发的那只怪兽是否为自己场上且卡名不是「使龙炎剑的高手」；在发动确认（chk==1）时将那只怪兽与效果建立联系作为作用对象。
function c34160055.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:IsControler(tp) and not tc:IsCode(34160055) end
	tc:CreateEffectRelation(e)
end
-- 效果处理：若召唤的怪兽仍表侧表示且与效果关联，则给那只怪兽附加等级上升1星的效果；若这张卡仍表侧表示且与效果关联，则给这张卡附加攻击力上升300直到结束阶段的效果。
function c34160055.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 可以把那只怪兽的等级上升1星
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
