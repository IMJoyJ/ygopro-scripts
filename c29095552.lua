--M・HERO アシッド
-- 效果：
-- 这张卡用「假面变化」的效果才能特殊召唤。
-- ①：这张卡特殊召唤的场合发动。对方场上的魔法·陷阱卡全部破坏，对方场上的全部怪兽的攻击力下降300。
function c29095552.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「假面变化」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为必须通过假面变化进行召唤
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合发动。对方场上的魔法·陷阱卡全部破坏，对方场上的全部怪兽的攻击力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29095552,0))  --"魔陷破坏"
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c29095552.destg)
	e2:SetOperation(c29095552.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选魔法·陷阱卡
function c29095552.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果目标为对方场上的所有魔法·陷阱卡
function c29095552.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有魔法·陷阱卡组成的组
	local g=Duel.GetMatchingGroup(c29095552.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，表明将要破坏对方场上的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数，先破坏对方场上的魔法·陷阱卡，再降低对方场上怪兽的攻击力
function c29095552.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有魔法·陷阱卡组成的组
	local g=Duel.GetMatchingGroup(c29095552.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 执行破坏操作，若成功则继续处理后续效果
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取对方场上所有表侧表示的怪兽组成的组
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=mg:GetFirst()
		while tc do
			-- 给对方场上所有表侧表示的怪兽降低300攻击力
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=mg:GetNext()
		end
	end
end
