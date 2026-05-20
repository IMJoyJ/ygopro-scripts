--ネクロバレーの祭殿
-- 效果：
-- 场上有名字带有「守墓」的怪兽以及「王家长眠之谷」存在的场合才能发动。只要这张卡在场上存在，双方不能把名字带有「守墓」的怪兽以外的怪兽特殊召唤。名字带有「守墓」的怪兽以及「王家长眠之谷」不在场上存在的场合，这张卡破坏。
function c70000776.initial_effect(c)
	-- 场上有名字带有「守墓」的怪兽以及「王家长眠之谷」存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c70000776.actcon)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，双方不能把名字带有「守墓」的怪兽以外的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c70000776.sumlimit)
	c:RegisterEffect(e2)
	-- 名字带有「守墓」的怪兽以及「王家长眠之谷」不在场上存在的场合，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(c70000776.sdcon)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查卡片是否是表侧表示且卡名含有「守墓」
function c70000776.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x2e)
end
-- 发动条件：检查场上是否存在「守墓」怪兽以及「王家长眠之谷」
function c70000776.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方怪兽区是否存在至少1只表侧表示的「守墓」怪兽
	return Duel.IsExistingMatchingCard(c70000776.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 并且场上存在「王家长眠之谷」
		and Duel.IsEnvironment(47355498)
end
-- 限制特殊召唤的怪兽过滤：非「守墓」怪兽不能特殊召唤
function c70000776.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0x2e)
end
-- 自我破坏条件：场上不存在「守墓」怪兽或者不存在「王家长眠之谷」
function c70000776.sdcon(e)
	-- 检查双方怪兽区是否不存在表侧表示的「守墓」怪兽
	return not Duel.IsExistingMatchingCard(c70000776.cfilter1,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 或者场上不存在「王家长眠之谷」
		or not Duel.IsEnvironment(47355498)
end
