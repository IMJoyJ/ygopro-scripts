--デス・ラクーダ
-- 效果：
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转召唤成功的场合发动。自己从卡组抽1张。
function c2326738.initial_effect(c)
	-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2326738,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c2326738.target)
	e1:SetOperation(c2326738.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡反转召唤成功的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2326738,1))  --"抽一张卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c2326738.drtg)
	e2:SetOperation(c2326738.drop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定与信息登记：获取本卡，检查它能否变成里侧守备表示且本回合尚未使用过该效果（flag 2326738 计数为0）；满足时注册“已使用”标志以记录1回合1次限制（该标志在离场等重置，结束阶段重置），并设置操作信息为改变表示形式（CATEGORY_POSITION），对象为本卡，数量为1。
function c2326738.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(2326738)==0 end
	c:RegisterFlagEffect(2326738,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置当前连锁的操作信息：效果分类为改变表示形式（CATEGORY_POSITION），对象是本卡，数量为1，供系统进行效果交互检测（如能否被无效、是否受其他卡影响等）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果①的解决处理操作：若本卡仍与效果关联且处于表侧表示，则将其变为里侧守备表示。
function c2326738.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将本卡变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 效果②的发动目标（时点判定）与信息登记：反转召唤成功时必发，无条件可发动；设置对象玩家为自己，抽卡数量为1，并设置操作信息为抽卡效果（CATEGORY_DRAW）。
function c2326738.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为效果发动者自己（tp），用于确定抽卡的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，用于确定抽卡数量。
	Duel.SetTargetParam(1)
	-- 设置操作信息：效果分类为抽卡（CATEGORY_DRAW），目标玩家为tp，预计抽卡数为1；因为抽卡张数在效果处理时早已确定，所以targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的解决处理：从连锁信息中取出之前存储的对象玩家和参数，让该玩家抽取对应数量的卡，抽卡原因为效果。
function c2326738.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数，分别保存到局部变量p（玩家）和d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
