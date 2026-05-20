--クロノダイバー・タイムレコーダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方战斗阶段把这张卡解放才能发动。这个回合只有1次，对方怪兽的攻击发生的对自己的战斗伤害由对方代受。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的超量怪兽因效果从场上离开的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c74578720.initial_effect(c)
	-- ①：对方战斗阶段把这张卡解放才能发动。这个回合只有1次，对方怪兽的攻击发生的对自己的战斗伤害由对方代受。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74578720,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_BATTLE_START+TIMING_ATTACK)
	e1:SetCountLimit(1,74578720)
	e1:SetCondition(c74578720.bdcon)
	e1:SetCost(c74578720.bdcost)
	e1:SetOperation(c74578720.bdop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的超量怪兽因效果从场上离开的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74578720,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,74578721)
	e2:SetCondition(c74578720.spcon)
	e2:SetTarget(c74578720.sptg)
	e2:SetOperation(c74578720.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件函数：对方回合的战斗阶段。
function c74578720.bdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为对方回合的战斗阶段（从战斗阶段开始到战斗阶段结束）。
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and Duel.GetTurnPlayer()==1-tp
end
-- 效果①的发动代价函数：解放自身。
function c74578720.bdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果①的效果处理函数：注册一个使本回合自己受到的战斗伤害由对方代受的效果。
function c74578720.bdop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的超量怪兽因效果从场上离开的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL+PHASE_END)
	-- 将伤害转移效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：自己场上表侧表示的超量怪兽因效果离场。
function c74578720.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_XYZ)~=0 and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果②的发动条件函数：自己场上表侧表示的超量怪兽因效果离场，且离场的怪兽中不包含这张卡自身。
function c74578720.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c74578720.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果②的发动准备函数：检查自身是否能特殊召唤并设置操作信息。
function c74578720.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，对象为自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理函数：将这张卡特殊召唤，并添加离场时除外的限制。
function c74578720.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于墓地，则将其以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1)
	end
end
