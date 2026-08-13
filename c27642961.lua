--SPYRAL MISSION－強襲
-- 效果：
-- 这张卡发动后，第3次的自己结束阶段破坏。
-- ①：1回合1次，自己的「秘旋谍」怪兽战斗破坏怪兽的场合或者自己场上的「秘旋谍」怪兽的效果把场上的卡破坏的场合才能发动。自己从卡组抽1张。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只「秘旋谍」怪兽特殊召唤。
function c27642961.initial_effect(c)
	-- 这张卡发动后，第3次的自己结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27642961.target)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己的「秘旋谍」怪兽战斗破坏怪兽的场合或者自己场上的「秘旋谍」怪兽的效果把场上的卡破坏的场合才能发动。自己从卡组抽1张。
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
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只「秘旋谍」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27642961,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	-- 将墓地的这张卡除外作为发动效果的代价。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c27642961.sptg)
	e3:SetOperation(c27642961.spop)
	c:RegisterEffect(e3)
end
-- 魔法卡发动时检查发动是否合法，并给自身注册一个在结束阶段计数、第3次自己结束阶段破坏的持续效果，同时把自身回合计数器归零。
function c27642961.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 这张卡发动后，第3次的自己结束阶段破坏。
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
-- 作为自毁计数效果的发动条件，仅在持有者自己的结束阶段才进行计数。
function c27642961.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为这张卡的控制者（即是否为持有者自己的结束阶段）。
	return Duel.GetTurnPlayer()==tp
end
-- 每次自己的结束阶段将这张卡上的回合计数器加1，达到3次后以规则效果将这张卡破坏。
function c27642961.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 以规则效果将这张卡破坏（不进入连锁、不受无效，无视免疫和代破）。
		Duel.Destroy(c,REASON_RULE)
	end
end
-- 过滤“被效果破坏”的卡：这些卡之前位于场上且破坏原因为效果。
function c27642961.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
-- 作为抽卡效果的发动条件，检测事件是否符合：己方「秘旋谍」怪兽战斗破坏怪兽，或己方场上的「秘旋谍」怪兽的效果把场上的卡破坏。
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
-- 抽卡效果的目标处理：检查玩家能否抽1张卡，并设定抽卡玩家为自己、抽卡数量为1，登记操作信息。
function c27642961.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：当前玩家是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将效果的目标玩家设为当前玩家（自己）。
	Duel.SetTargetPlayer(tp)
	-- 设定效果的目标参数为1（抽卡数量为1）。
	Duel.SetTargetParam(1)
	-- 登记操作信息：效果处理时将执行从卡组抽1张卡的操作，目标玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从目标玩家的卡组抽对应数量的卡。
function c27642961.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家和抽卡数量参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果原因抽对应数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤手牌中满足特殊召唤条件的「秘旋谍」怪兽。
function c27642961.spfilter(c,e,tp)
	return c:IsSetCard(0xee) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标处理：检查自己怪兽区有空位且手牌存在可特殊召唤的「秘旋谍」怪兽，并登记特殊召唤操作信息。
function c27642961.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在1张满足特殊召唤条件的「秘旋谍」怪兽。
		and Duel.IsExistingMatchingCard(c27642961.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：效果处理时将进行特殊召唤，来源为手牌，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：选择手牌中的1只「秘旋谍」怪兽特殊召唤到自己的怪兽区域。
function c27642961.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己怪兽区有空位，否则处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给当前玩家发送特殊召唤的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让当前玩家从手牌中选择1只满足条件的「秘旋谍」怪兽。
	local g=Duel.SelectMatchingCard(tp,c27642961.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
