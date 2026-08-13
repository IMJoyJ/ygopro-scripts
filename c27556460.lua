--原石の反叫
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：除衍生物外的，通常怪兽或者5星以上的「原石」怪兽在自己场上存在，对方把怪兽召唤·特殊召唤之际才能发动。那个无效，那些怪兽除外。
-- ②：自己准备阶段，自己场上有「原石」怪兽存在的场合才能发动。墓地的这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册这张卡的两个效果：①是无效对方怪兽召唤/特殊召唤并除外的效果（分别对应通常召唤和特殊召唤两个时点）；②是在自己准备阶段从墓地盖放的效果。
function s.initial_effect(c)
	-- 对应①效果：对方把怪兽召唤·特殊召唤之际才能发动。那个无效，那些怪兽除外。（此处为通常召唤时点）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)
	-- 对应②效果：自己准备阶段，自己场上有「原石」怪兽存在的场合才能发动。墓地的这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 判断怪兽是否满足①效果的发动条件：表侧表示且不是衍生物，且是5星以上的「原石」怪兽或通常怪兽。
function s.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
		and (c:IsSetCard(0x1b9) and c:IsLevelAbove(5) or c:IsType(TYPE_NORMAL))
end
-- ①效果的发动条件：对方进行召唤/特殊召唤之际（由时点决定），当前连锁为空，且自己场上存在符合条件的怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 条件是此次召唤/特殊召唤由对方进行，且当前不在连锁处理中（保证像反击陷阱一样在召唤之际直接发动）。
	return tp~=ep and Duel.GetCurrentChain()==0
		-- 检查自己场上是否存在至少1只满足s.cfilter的怪兽（表侧通常怪兽或5星以上原石怪兽且非衍生物）。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的目标处理：检查能否除外，并设置操作信息，表示将要无效这次召唤并除外那些怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认玩家tp可以进行除外（防止出现不能除外的限制）。
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	-- 设置操作信息：将正在召唤的怪兽eg标记为将被无效召唤，数量为eg数量。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：将正在召唤的怪兽eg标记为将被除外，数量为eg数量。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
end
-- ①效果处理：无效对方怪兽的召唤，并将其表侧除外。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效正在召唤的怪兽eg的召唤（使其召唤不成功）。
	Duel.NegateSummon(eg)
	-- 将那些怪兽以表侧表示从场上除外（实际从“召唤之际”区域除外）。
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end
-- 判断怪兽是否为表侧表示的「原石」怪兽，用于②效果的发动条件。
function s.rccfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1b9)
end
-- ②效果的发动条件：当前为自己准备阶段，且自己场上有表侧表示「原石」怪兽存在。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是自己，确保在己方准备阶段才能发动。
	return Duel.GetTurnPlayer()==tp
		-- 检查自己场上是否存在至少1只表侧表示的「原石」怪兽。
		and Duel.IsExistingMatchingCard(s.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标处理：确认这张墓地的卡可以被盖放，并设置操作信息为涉及墓地移动。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：墓地的这张卡将作为对象被移动（盖放），用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：将墓地的这张卡在自己场上盖放；若成功，给这张卡附加离场除外效果。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理条件：这张卡仍与效果关联（未被无效或离开墓地）、不受王家长眠之谷影响、且成功盖放到场上。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SSet(tp,c)~=0 then
		-- 对应②效果中的“这个效果盖放的这张卡从场上离开的场合除外。”
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
