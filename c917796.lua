--ガガガタッグ
-- 效果：
-- 自己场上的全部名字带有「我我我」的怪兽的攻击力直到下次的自己的准备阶段时上升自己场上的名字带有「我我我」的怪兽数量×500的数值。「我我我组队」在1回合只能发动1张。
function c917796.initial_effect(c)
	-- 自己场上的全部名字带有「我我我」的怪兽的攻击力直到下次的自己的准备阶段时上升自己场上的名字带有「我我我」的怪兽数量×500的数值。「我我我组队」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,917796+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c917796.target)
	e1:SetOperation(c917796.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的名字带有「我我我」的怪兽
function c917796.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x54)
end
-- 卡片发动时的目标检查函数
function c917796.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的名字带有「我我我」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c917796.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 卡片发动时的效果处理函数，使自己场上所有「我我我」怪兽的攻击力上升
function c917796.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上全部表侧表示的名字带有「我我我」的怪兽
	local sg=Duel.GetMatchingGroup(c917796.filter,tp,LOCATION_MZONE,0,nil)
	local atk=sg:GetCount()*500
	local c=e:GetHandler()
	local tc=sg:GetFirst()
	while tc do
		-- 自己场上的全部名字带有「我我我」的怪兽的攻击力直到下次的自己的准备阶段时上升自己场上的名字带有「我我我」的怪兽数量×500的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
		tc:RegisterEffect(e1)
		tc=sg:GetNext()
	end
end
