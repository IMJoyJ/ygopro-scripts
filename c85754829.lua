--ワーム・グルス
-- 效果：
-- 每次场上里侧守备表示存在的怪兽反转，给这张卡放置1个虫指示物。这张卡放置的虫指示物每有1个，这张卡的攻击力上升300。
function c85754829.initial_effect(c)
	c:EnableCounterPermit(0xf)
	-- 每次场上里侧守备表示存在的怪兽反转，给这张卡放置1个虫指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c85754829.accon)
	e1:SetOperation(c85754829.acop)
	c:RegisterEffect(e1)
	-- 这张卡放置的虫指示物每有1个，这张卡的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c85754829.atkval)
	c:RegisterEffect(e2)
end
-- 计算并返回这张卡上的虫指示物数量乘以300的数值，作为攻击力上升的值。
function c85754829.atkval(e,c)
	return c:GetCounter(0xf)*300
end
-- 过滤条件：检查怪兽在表示形式变更前是否为里侧表示，且当前是否为表侧表示（即判定是否反转）。
function c85754829.cfilter(c)
	return c:IsPreviousPosition(POS_FACEDOWN) and c:IsFaceup()
end
-- 触发条件：检查发生表示形式变更的怪兽中，是否存在至少1只满足反转条件的怪兽（排除自身）。
function c85754829.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c85754829.cfilter,1,e:GetHandler())
end
-- 效果处理：给这张卡放置1个虫指示物。
function c85754829.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0xf,1)
end
