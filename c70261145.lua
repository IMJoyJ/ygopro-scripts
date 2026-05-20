--ナチュル・トライアンフ
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，每次对方把魔法·陷阱卡发动，自己场上表侧表示存在的名字带有「自然」的怪兽的攻击力直到那个回合的结束阶段时上升500。
function c70261145.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，每次对方把魔法·陷阱卡发动，自己场上表侧表示存在的名字带有「自然」的怪兽的攻击力直到那个回合的结束阶段时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetOperation(c70261145.chop)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的名字带有「自然」的怪兽
function c70261145.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
-- 在连锁处理结束时，若对方发动了魔法·陷阱卡，则使自己场上所有表侧表示的「自然」怪兽的攻击力直到回合结束阶段上升500
function c70261145.chop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 获取自己场上所有表侧表示的名字带有「自然」的怪兽
	local g=Duel.GetMatchingGroup(c70261145.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力直到那个回合的结束阶段时上升500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
