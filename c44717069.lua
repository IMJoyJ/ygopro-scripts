--スターフィッシュ
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。自己场上的全部「海星」的等级上升1星。
function c44717069.initial_effect(c)
	-- 1回合1次，自己的主要阶段时才能发动。自己场上的全部「海星」的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44717069,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c44717069.target)
	e1:SetOperation(c44717069.operation)
	c:RegisterEffect(e1)
end
-- 筛选函数：判断怪兽是否为表侧表示且卡名是「海星」（44717069）。
function c44717069.filter(c)
	return c:IsFaceup() and c:IsCode(44717069)
end
-- 发动条件判定函数：效果发动时（chk==0）检查自己场上是否存在满足筛选条件的表侧表示「海星」怪兽，若存在则允许发动。
function c44717069.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时判定自己场上是否存在至少1张表侧表示且卡名为「海星」的怪兽，作为效果的发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c44717069.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理函数：获取自己场上所有表侧表示「海星」，对其中每只怪兽赋予等级上升1星的持续效果，直到其离开场上等状态重置。
function c44717069.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足筛选条件的卡组：自己场上所有表侧表示且卡名为「海星」的怪兽集合。
	local g=Duel.GetMatchingGroup(c44717069.filter,tp,LOCATION_MZONE,0,nil)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部「海星」的等级上升1星。
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
