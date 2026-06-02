--竜の精神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有原本攻击力或者原本守备力是2500的怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：这张卡在墓地存在的场合，支付2500基本分才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化函数，注册卡片的效果①（发动无效并破坏）和效果②（墓地支付基本分盖放并附加离场除外限制）
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
-- 过滤条件：场上表侧表示存在原本攻击力或原本守备力为2500的怪兽
function s.cfilter(c)
	return c:IsFaceup() and (c:GetBaseAttack()==2500 or c:GetBaseDefense()==2500)
end
-- 效果①的发动条件：自己场上有满足条件的怪兽存在，且连锁中的发动可以被无效，并且该发动是怪兽效果或魔陷卡的发动
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在原本攻击力或原本守备力是2500的表侧表示怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查该连锁的发动是否可以被无效，且该发动必须是怪兽效果或魔法·陷阱卡的发动
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 效果①的靶向/操作信息设置函数，设置无效发动和破坏的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的处理函数，使发动无效并破坏该卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡仍与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果②的支付代价函数，检查并支付2500基本分
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2500基本分
	if chk==0 then return Duel.CheckLPCost(tp,2500) end
	-- 支付2500基本分
	Duel.PayLPCost(tp,2500)
end
-- 效果②的靶向/操作信息设置函数，检查此卡是否能盖放并设置涉及墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：此卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的处理函数，将此卡在自己场上盖放，并添加离场时除外的限制
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此卡仍与效果相关联、不受王家长眠之谷影响且成功在自己场上盖放
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
