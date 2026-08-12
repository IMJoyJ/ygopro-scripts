--ナンバーズ・プロテクト
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「No.」超量怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「No.」超量怪兽被战斗·效果破坏的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c68630939.initial_effect(c)
	-- ①：自己场上有「No.」超量怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68630939,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,68630939)
	e1:SetCondition(c68630939.condition)
	e1:SetTarget(c68630939.target)
	e1:SetOperation(c68630939.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「No.」超量怪兽被战斗·效果破坏的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68630939,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,68630939)
	e2:SetCondition(c68630939.setcon)
	e2:SetTarget(c68630939.settg)
	e2:SetOperation(c68630939.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「No.」超量怪兽
function c68630939.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)
end
-- 效果①的发动条件：自己场上有「No.」超量怪兽存在，且有可以被无效的怪兽效果或魔法·陷阱卡的发动
function c68630939.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「No.」超量怪兽，若不存在则不能发动
	if not Duel.IsExistingMatchingCard(c68630939.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查被连锁的效果发动是否可以被无效，若不能则不能发动
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果①的靶向与发动准备：设置无效发动与破坏的操作信息
function c68630939.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置当前连锁的操作信息为：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的处理：使发动无效并破坏
function c68630939.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡在连锁中仍有关联，则执行破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动无效的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上原本由自己控制的「No.」超量怪兽因战斗或效果被破坏
function c68630939.setfilter(c,tp)
	return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果②的发动条件：自己场上的表侧表示「No.」超量怪兽被战斗·效果破坏，且被破坏的卡中不包含这张卡自身
function c68630939.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c68630939.setfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果②的靶向与发动准备：检查这张卡是否可以盖放，并设置涉及墓地的操作信息
function c68630939.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置当前连锁的操作信息为：将墓地的这张卡移出墓地（盖放）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将这张卡在自己场上盖放，并添加离场时除外的约束
function c68630939.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于墓地，则将其在自己场上盖放
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
