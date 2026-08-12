--竜の精神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有原本攻击力或者原本守备力是2500的怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：这张卡在墓地存在的场合，支付2500基本分才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册这张卡的效果。创建并注册效果①（发动无效并破坏）和效果②（墓地支付2500基本分盖放，离场除外）。
function s.initial_effect(c)
	-- ①：自己场上有原本攻击力或者原本守备力是2500的怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，支付2500基本分才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示原本攻击力或原本守备力为2500的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and (c:GetBaseAttack()==2500 or c:GetBaseDefense()==2500)
end
-- 效果①的发动条件：自己场上有原本攻击力或者原本守备力是2500的表侧表示怪兽存在，且被连锁的效果可被无效，并且是怪兽效果发动或魔法·陷阱卡的发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在原本攻击力或者原本守备力是2500的表侧表示怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查连锁的效果发动能否被无效，且该效果属于怪兽效果发动或魔法·陷阱卡的发动。
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 效果①的发动准备（效果靶向与操作信息）：设置发动无效的操作信息，如果发动的卡可以被破坏且与效果相关联，则同时设置破坏的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将该连锁的发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该连锁对应的卡片。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的效果处理：使发动无效，如果该卡与效果相关联则将其破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功将该连锁的发动无效，且该卡仍与效果相关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效发动的卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果②的支付代价：检查并支付2500点基本分。
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查玩家是否能够支付2500点基本分作为代价。
	if chk==0 then return Duel.CheckLPCost(tp,2500) end
	-- 支付2500点基本分作为效果发动的代价。
	Duel.PayLPCost(tp,2500)
end
-- 效果②的发动准备：检查这张卡是否可以在场上盖放，并设置涉及墓地的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：将墓地中的这张卡作为移出墓地操作的对象。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：如果此卡仍存在于墓地且未受王家长眠之谷等卡的影响，则将其在自己场上盖放，并添加离场时除外的效果。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果关联、不受墓地相关无效化卡片的影响，并成功在自己场上盖放。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SSet(tp,c)~=0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
