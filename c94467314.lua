--悪鵺死ノ雨
-- 效果：
-- 自己场上有攻击力2000以上的水族怪兽存在的场合：水族以外的场上的怪兽全部送去墓地。
-- 盖放的这张卡被卡的效果破坏的场合：可以把这张卡盖放。
-- 「降青蛙」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①发动的清场送墓效果、②盖放被破坏时的重新盖放效果
function s.initial_effect(c)
	-- ①：自己场上有攻击力2000以上的水族怪兽存在的场合才能发动。水族以外的场上的怪兽全部送去墓地。
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
	-- ②：盖放的这张卡被卡的效果破坏的场合才能发动。这张卡在自己场上盖放。
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
-- 发动条件过滤：自己场上攻击力2000以上表侧表示的水族怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2000) and c:IsRace(RACE_AQUA)
end
-- ①效果发动条件检查：自己场上是否存在攻击力2000以上的水族怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在攻击力2000以上的表侧表示水族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 送墓目标过滤：场上里侧表示或非水族的怪兽，且可送去墓地
function s.tgfilter(c)
	return (c:IsFacedown() or not c:IsRace(RACE_AQUA))
		and c:IsAbleToGrave()
end
-- ①效果发动准备：检查场上是否有满足条件的怪兽，设置送墓操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：双方场上是否存在里侧表示或非水族的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置连锁操作信息：将场上的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- ①效果处理：将水族以外的场上的怪兽全部送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有里侧表示或非水族的怪兽
	local sg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 将选中的怪兽全部送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- ②效果发动条件检查：这张卡因效果被破坏且此前在场上盖放
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- ②效果发动准备：检查自身是否能在场上盖放，若在墓地则设置离开墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 设置连锁操作信息：将墓地的此卡离开墓地（盖放）
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- ②效果处理：将这张卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否关联连锁且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡在自己场上盖放
		Duel.SSet(tp,c)
	end
end
