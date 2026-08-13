--アンチエイリアン
-- 效果：
-- ①：1回合1次，这张卡和怪兽进行过战斗的自己·对方的战斗阶段才能发动。从手卡把1只电子界族怪兽召唤。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合发动。自己从卡组抽1张。
function c43583400.initial_effect(c)
	-- ①：1回合1次，这张卡和怪兽进行过战斗的自己·对方的战斗阶段才能发动。从手卡把1只电子界族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43583400,0))  --"怪兽召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c43583400.sumcon)
	e1:SetTarget(c43583400.sumtg)
	e1:SetOperation(c43583400.sumop)
	c:RegisterEffect(e1)
	-- ①：这张卡和怪兽进行过战斗。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_BATTLED)
	e0:SetOperation(c43583400.regop)
	c:RegisterEffect(e0)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43583400,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c43583400.drcon)
	e2:SetTarget(c43583400.drtg)
	e2:SetOperation(c43583400.drop)
	c:RegisterEffect(e2)
end
-- 若这张卡存在战斗对象，则为这张卡设置一个标记，记录其在本回合战斗阶段已与怪兽进行过战斗；该标记会在阶段结束时重置。
function c43583400.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:GetBattleTarget() then return end
	c:RegisterFlagEffect(43583400,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 判断当前是否为战斗阶段（战斗阶段开始至结束），且这张卡带有已进行过战斗的标记，作为效果①的发动条件。
function c43583400.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段处于战斗阶段范围内，并且这张卡带有已进行过战斗的标记。
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE and e:GetHandler():GetFlagEffect(43583400)>0
end
-- 筛选手卡中种族为电子界且可以在当前状态下通常召唤（忽略召唤次数限制）的怪兽。
function c43583400.sumfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsSummonable(true,nil)
end
-- 效果①发动时的目标检测：若手卡存在可召唤的电子界族怪兽则合法，并设置本次连锁的召唤操作信息。
function c43583400.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在至少1只满足条件的电子界族怪兽（可通常召唤），据此判定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c43583400.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将当前连锁的操作信息设置为CATEGORY_SUMMON，表示效果处理时将进行1次通常召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果①处理时，从手卡选择1只电子界族怪兽进行通常召唤，且不占用每回合的通常召唤次数。
function c43583400.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家从手卡选择要召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手卡中选择1只满足sumfilter条件的电子界族怪兽。
	local g=Duel.SelectMatchingCard(tp,c43583400.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以通常召唤的方式特殊处理（无视通常召唤次数限制）召唤上场。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 判断②的发动条件：这张卡因对方的效果从场上离开，且离场前是表侧表示、原本控制者为自己。
function c43583400.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- 效果②发动时的目标设定：设置抽卡玩家为自己、抽卡数量为1，并登记抽卡操作信息。
function c43583400.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为自己，即抽卡玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，即抽卡数量。
	Duel.SetTargetParam(1)
	-- 设置本次连锁的操作信息为抽卡1张，便于效果处理时确定抽卡行为。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②处理时，根据链上记录的目标玩家和抽卡数量，让该玩家执行抽卡。
function c43583400.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设置的目标玩家和抽卡参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果原因抽取对应数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
