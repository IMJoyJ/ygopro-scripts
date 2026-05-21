--紋章獣ベルナーズ・ファルコン
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时才能发动。自己场上的全部5星以上的怪兽的等级变成4星。
function c96704018.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时才能发动。自己场上的全部5星以上的怪兽的等级变成4星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96704018,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c96704018.target)
	e1:SetOperation(c96704018.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示且等级在5星以上的怪兽
function c96704018.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(5)
end
-- 效果发动的可行性检查，确认是否存在可适用的怪兽
function c96704018.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示且等级在5星以上的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96704018.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：获取自己场上所有5星以上的怪兽，并将其等级全部变为4星
function c96704018.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且等级在5星以上的怪兽组
	local g=Duel.GetMatchingGroup(c96704018.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 等级变成4星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
