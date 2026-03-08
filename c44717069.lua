--スターフィッシュ
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。自己场上的全部「海星」的等级上升1星。
function c44717069.initial_effect(c)
	-- 效果原文内容：1回合1次，自己的主要阶段时才能发动。自己场上的全部「海星」的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44717069,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c44717069.target)
	e1:SetOperation(c44717069.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义过滤函数，用于筛选场上表侧表示的海星怪兽
function c44717069.filter(c)
	return c:IsFaceup() and c:IsCode(44717069)
end
-- 规则层面作用：效果的发动条件判断，检查自己场上是否存在至少1只表侧表示的海星怪兽
function c44717069.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查自己场上是否存在至少1只表侧表示的海星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44717069.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 规则层面作用：效果的处理流程，获取场上所有表侧表示的海星怪兽并为它们加上等级上升1的永久效果
function c44717069.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取场上所有表侧表示的海星怪兽
	local g=Duel.GetMatchingGroup(c44717069.filter,tp,LOCATION_MZONE,0,nil)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		-- 效果原文内容：自己场上的全部「海星」的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
