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
	-- 表侧表示的这张卡因对方的效果从场上离开的场合发动。自己从卡组抽1张。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_BATTLED)
	e0:SetOperation(c43583400.regop)
	c:RegisterEffect(e0)
	-- 怪兽召唤
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
-- 记录战斗标志位，用于判断是否在战斗阶段中与怪兽战斗过
function c43583400.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:GetBattleTarget() then return end
	c:RegisterFlagEffect(43583400,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 判断当前是否处于战斗阶段且已与怪兽战斗过
function c43583400.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于战斗阶段且已与怪兽战斗过
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE and e:GetHandler():GetFlagEffect(43583400)>0
end
-- 过滤函数，用于筛选手牌中可通常召唤的电子界族怪兽
function c43583400.sumfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsSummonable(true,nil)
end
-- 设置连锁处理信息，确定将要召唤的怪兽
function c43583400.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的电子界族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c43583400.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置召唤怪兽的连锁处理信息
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 执行召唤操作，选择并召唤符合条件的怪兽
function c43583400.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌中选择一只电子界族怪兽
	local g=Duel.SelectMatchingCard(tp,c43583400.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行通常召唤操作
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 判断是否因对方效果离场且满足触发条件
function c43583400.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- 设置抽卡效果的连锁处理信息
function c43583400.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置抽卡效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的抽卡数量
	Duel.SetTargetParam(1)
	-- 设置抽卡效果的连锁处理信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡操作
function c43583400.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
