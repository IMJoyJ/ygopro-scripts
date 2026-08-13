--TG－クローズ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有机械族「科技属」怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：这张卡在墓地存在的状态，同调怪兽被除外的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 创建并注册此卡的①②两个效果：①为反击陷阱型效果（魔法卡发动时连锁无效并破坏），②为墓地·场合型诱发效果（同调怪兽被除外时在场上盖放，并附加离场除外）。
function s.initial_effect(c)
	-- 对应①效果：自己场上有机械族「科技属」怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 对应②效果：这张卡在墓地存在的状态，同调怪兽被除外的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检索自己场上表侧表示且机械族、卡名含有「科技属」的怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsSetCard(0x27)
end
-- ①的发动条件：自己场上存在符合条件的「科技属」机械族怪兽，且被连锁的效果是怪兽效果或魔法·陷阱卡的发动，且该连锁的发动可以被无效。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在1张以上表侧表示的机械族「科技属」怪兽。
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) and (re:IsActiveType(TYPE_MONSTER)
		-- 检查被连锁的效果是否为怪兽效果（TYPE_MONSTER）或魔法·陷阱卡发动（具有EFFECT_TYPE_ACTIVATE），且该连锁能够被无效。
		or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 发动时无取对象；设置使发动无效（CATEGORY_NEGATE）和破坏（CATEGORY_DESTROY）的操作信息，若被连锁的效果卡仍与效果关联则同时设置破坏的对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将使连锁「eg」的发动无效，对象为连锁的发动卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 若被连锁的效果的卡仍与效果关联，则额外设置破坏该卡的操作信息。
	if re:GetHandler():IsRelateToEffect(re) then Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0) end
end
-- 效果处理：若连锁发动被成功无效且被连锁的效果卡仍与该效果关联，则将该卡破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 成功无效连锁后，破坏被无效的效果的发动卡。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then Duel.Destroy(eg,REASON_EFFECT) end
end
-- 过滤函数：判断被除外的卡是否为表侧表示的同调怪兽；若之前从怪兽区离场，则要求离场前场上表示形式为表侧表示且为同调怪兽。
function s.cfilter(c)
	if c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousTypeOnField()&TYPE_SYNCHRO==0 then return false end
	return c:IsFaceup() and c:IsPreviousPosition(POS_FACEUP) and c:IsType(TYPE_SYNCHRO)
end
-- ②的发动条件：除外事件组中存在至少1张满足s.cfilter的卡，即表侧表示的同调怪兽被除外。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- ②发动时：确认自己（这张卡）在墓地且可以盖放；设置这张卡离开墓地的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息：这张卡将从墓地离开，用于检测涉及墓地的效果（如王家长眠之谷）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联且成功盖放到自己场上，则给它附加一个「离场时除外」的永续效果（效果不可被无效）。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与效果关联，并能成功盖放到场上，则执行后续的离场除外效果附加。
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)>0 then
		-- 对应②的最后一句话：这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
