--SPYRAL MISSION－強襲
-- 效果：
-- 这张卡发动后，第3次的自己结束阶段破坏。
-- ①：1回合1次，自己的「秘旋谍」怪兽战斗破坏怪兽的场合或者自己场上的「秘旋谍」怪兽的效果把场上的卡破坏的场合才能发动。自己从卡组抽1张。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只「秘旋谍」怪兽特殊召唤。
function c27642961.initial_effect(c)
	-- ①：1回合1次，自己的「秘旋谍」怪兽战斗破坏怪兽的场合或者自己场上的「秘旋谍」怪兽的效果把场上的卡破坏的场合才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27642961.target)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只「秘旋谍」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27642961,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c27642961.drcon)
	e2:SetTarget(c27642961.drtg)
	e2:SetOperation(c27642961.drop)
	c:RegisterEffect(e2)
	-- 把墓地的这张卡除外 的过滤条件的简单写法，用在效果注册的 cost 里
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27642961,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	-- 效果作用：注册一个在自己结束阶段触发的持续效果，用于记录回合数并在第3次结束阶段时破坏此卡
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c27642961.sptg)
	e3:SetOperation(c27642961.spop)
	c:RegisterEffect(e3)
end
-- 效果原文内容：这张卡发动后，第3次的自己结束阶段破坏。
function c27642961.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 效果作用：设置一个在自己结束阶段触发的持续效果，用于记录回合数并在第3次结束阶段时破坏此卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c27642961.descon)
	e1:SetOperation(c27642961.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否为自己的结束阶段
function c27642961.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 效果作用：处理结束阶段计数和破坏逻辑
function c27642961.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 效果作用：在第3次结束阶段时以REASON_RULE原因破坏此卡
		Duel.Destroy(c,REASON_RULE)
	end
end
-- 效果作用：过滤函数，用于判断被破坏的卡是否来自场上且为效果破坏
function c27642961.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
-- 效果作用：判断是否满足①效果的发动条件，即自己的「秘旋谍」怪兽战斗破坏或效果破坏
function c27642961.drcon(e,tp,eg,ep,ev,re,r,rp)
	local des=eg:GetFirst()
	if des:IsReason(REASON_BATTLE) then
		local rc=des:GetReasonCard()
		return rc and rc:IsSetCard(0xee) and rc:IsControler(tp) and rc:IsRelateToBattle()
	elseif re then
		local rc=re:GetHandler()
		return eg:IsExists(c27642961.cfilter,1,nil,tp)
			and rc and rc:IsSetCard(0xee) and rc:IsControler(tp) and re:IsActiveType(TYPE_MONSTER)
			and re:GetActivateLocation()==LOCATION_MZONE
	end
	return false
end
-- 效果作用：设置抽卡效果的目标和信息
function c27642961.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 效果作用：设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置效果的目标参数为抽1张卡
	Duel.SetTargetParam(1)
	-- 效果作用：设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果作用：执行抽卡操作
function c27642961.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中设置的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：让目标玩家以REASON_EFFECT原因抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 效果作用：过滤函数，用于筛选手卡中的「秘旋谍」怪兽
function c27642961.spfilter(c,e,tp)
	return c:IsSetCard(0xee) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置特殊召唤效果的发动条件
function c27642961.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查手卡中是否存在满足条件的「秘旋谍」怪兽
		and Duel.IsExistingMatchingCard(c27642961.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息为特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果作用：执行特殊召唤操作
function c27642961.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的「秘旋谍」怪兽
	local g=Duel.SelectMatchingCard(tp,c27642961.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
