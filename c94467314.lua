--Rain of Frogs
-- 效果：
-- 自己场上有攻击力2000以上的水族怪兽存在的场合：水族以外的场上的怪兽全部送去墓地。
-- 盖放的这张卡被卡的效果破坏的场合：可以把这张卡盖放。
-- 「降青蛙」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册卡片效果：效果1（送去墓地）和效果2（被破坏时盖放）
function s.initial_effect(c)
	-- 自己场上有攻击力2000以上的水族怪兽存在的场合：水族以外的场上的怪兽全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 盖放的这张卡被卡的效果破坏的场合：可以把这张卡盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示、攻击力2000以上的水族怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2000) and c:IsRace(RACE_AQUA)
end
-- 效果1的发动条件：自己场上存在表侧表示且攻击力2000以上的水族怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示且攻击力2000以上的水族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：里侧表示或非水族的怪兽，且可以送去墓地
function s.tgfilter(c)
	return (c:IsFacedown() or not c:IsRace(RACE_AQUA))
		and c:IsAbleToGrave()
end
-- 效果1的发动准备：检查是否存在可送去墓地的非水族怪兽，并设置送去墓地的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在可以送去墓地的非水族怪兽（或里侧怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置送去墓地的操作信息（涉及双方场上的怪兽）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 效果1的处理：将场上所有非水族怪兽（或里侧怪兽）送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有满足送去墓地条件的非水族怪兽（或里侧怪兽）
	local sg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 因卡的效果将目标怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 效果2的发动条件：这张卡在场上盖放的状态下被卡的效果破坏
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 效果2的发动准备：检查自身是否可以盖放，若在墓地则设置移出墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 设置移出墓地的操作信息（用于王家长眠之谷等卡片的检测）
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- 效果2的处理：将自身在场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与该连锁有关联，且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡在自己场上盖放
		Duel.SSet(tp,c)
	end
end
