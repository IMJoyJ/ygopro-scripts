--ブラック・ノーブル
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：魔法·陷阱卡发动时，把自己场上1个黑羽指示物取除才能发动。那个发动无效并破坏。
-- ②：自己场上有「黑翼龙」存在的场合才能发动。墓地的这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c96367119.initial_effect(c)
	-- 在卡片中注册记载有「黑翼龙」卡名
	aux.AddCodeList(c,9012916)
	-- ①：魔法·陷阱卡发动时，把自己场上1个黑羽指示物取除才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96367119,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,96367119)
	e1:SetCondition(c96367119.discon)
	e1:SetCost(c96367119.discost)
	e1:SetTarget(c96367119.distg)
	e1:SetOperation(c96367119.disop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「黑翼龙」存在的场合才能发动。墓地的这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96367119,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,96367119)
	e2:SetCondition(c96367119.setcon)
	e2:SetTarget(c96367119.settg)
	e2:SetOperation(c96367119.setop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定
function c96367119.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁中发动的是否是魔法·陷阱卡，且该发动是否可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果①的发动代价处理
function c96367119.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否可以移去1个黑羽指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x10,1,REASON_COST) end
	-- 移去自己场上1个黑羽指示物
	Duel.RemoveCounter(tp,1,0,0x10,1,REASON_COST)
end
-- 效果①的效果目标处理
function c96367119.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果包含使发动无效的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示该效果包含破坏的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的效果处理
function c96367119.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动无效的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤场上表侧表示的「黑翼龙」
function c96367119.setfilter(c)
	return c:IsCode(9012916) and c:IsFaceup()
end
-- 效果②的发动条件判定
function c96367119.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「黑翼龙」
	return Duel.IsExistingMatchingCard(c96367119.setfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果②的效果目标处理
function c96367119.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息，表示该效果包含涉及墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理
function c96367119.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡仍存在于墓地，且成功在自己场上盖放
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
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
