--ソニック・ウォリアー
-- 效果：
-- ①：这张卡被送去墓地的场合发动。自己场上的全部2星以下的怪兽的攻击力上升500。
function c17932494.initial_effect(c)
	-- ①：这张卡被送去墓地的场合发动。自己场上的全部2星以下的怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17932494,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c17932494.operation)
	c:RegisterEffect(e1)
end
-- 筛选己方场上表侧表示且等级为2星以下的怪兽，作为攻击力上升的适用对象。
function c17932494.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(2)
end
-- 效果处理：获取己方场上全部满足条件的怪兽，并逐一为它们赋予攻击力上升500的永续效果。
function c17932494.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上所有表侧表示且2星以下的怪兽组成集合。
	local g=Duel.GetMatchingGroup(c17932494.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部2星以下的怪兽的攻击力上升500（此处为给单个对象怪兽赋予攻击力+500的效果）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
