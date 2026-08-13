--魔界台本「オープニング・セレモニー」
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己回复自己场上的「魔界剧团」怪兽数量×500基本分。
-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。自己直到手卡变成5张为止从卡组抽卡。
function c23784496.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己回复自己场上的「魔界剧团」怪兽数量×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,23784496)
	e1:SetTarget(c23784496.target)
	e1:SetOperation(c23784496.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。自己直到手卡变成5张为止从卡组抽卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,23784497)
	e2:SetCondition(c23784496.drcon)
	e2:SetTarget(c23784496.drtg)
	e2:SetOperation(c23784496.drop)
	c:RegisterEffect(e2)
end
-- 过滤出自己场上表侧表示且属于「魔界剧团」的怪兽。
function c23784496.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec)
end
-- ①效果的发动条件/目标处理：若自己场上有表侧表示「魔界剧团」怪兽则计算回复量（数量×500）作为参数；设定回复玩家为发动者，并登记回复效果的操作信息。
function c23784496.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算回复量为自己场上表侧表示「魔界剧团」怪兽数量×500。
	local rec=Duel.GetMatchingGroupCount(c23784496.filter1,tp,LOCATION_MZONE,0,nil)*500
	if chk==0 then return rec>0 end
	-- 设定本次连锁的对象玩家为发动者自己，即回复LP的玩家。
	Duel.SetTargetPlayer(tp)
	-- 设定本次连锁的对象参数为回复量rec，供效果处理时使用。
	Duel.SetTargetParam(rec)
	-- 登记本次连锁的操作为回复效果（CATEGORY_RECOVER），对象玩家为tp，回复量为rec，使其他卡能检测该操作。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- ①效果处理：重新计算回复量，取得之前设定的回复对象玩家，并让该玩家回复对应数值的基本分。
function c23784496.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新计算自己场上表侧表示「魔界剧团」怪兽数量×500的回复量。
	local rec=Duel.GetMatchingGroupCount(c23784496.filter1,tp,LOCATION_MZONE,0,nil)*500
	-- 从当前连锁信息中获取之前设定的回复对象玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 使玩家p回复rec点基本分，回复原因为效果。
	Duel.Recover(p,rec,REASON_EFFECT)
end
-- 过滤出表侧表示、属于「魔界剧团」且为灵摆怪兽的卡，用于检查额外卡组是否有符合条件的存在。
function c23784496.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x10ec)
end
-- ②效果发动条件：这张卡被对方的效果破坏，且破坏前由自己控制、位于场上且为里侧表示，同时自己额外卡组存在表侧表示的「魔界剧团」灵摆怪兽。
function c23784496.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 检查自己额外卡组是否存在至少1张表侧表示的「魔界剧团」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c23784496.filter2,tp,LOCATION_EXTRA,0,1,nil)
end
-- ②效果的发动目标处理：计算需要抽的牌数（补到手卡5张），若抽牌数大于0且玩家可以抽牌则允许发动，并将抽卡玩家和抽卡数登记为连锁对象。
function c23784496.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算需要抽的卡数为5减去当前手卡数量（手卡不足5张时的差值）。
	local ct=5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 发动合法性检查：必须需要抽卡（ct>0）且该玩家可以抽ct张卡才能发动。
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设定本次连锁的对象玩家为发动者自己，即抽卡玩家。
	Duel.SetTargetPlayer(tp)
	-- 设定本次连锁的对象参数为抽卡数ct。
	Duel.SetTargetParam(ct)
	-- 登记本次连锁的操作为抽卡效果（CATEGORY_DRAW），对象玩家为tp，抽卡数为ct。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- ②效果处理：重新计算需要抽的卡数（以当前手牌数为准），若仍需要抽卡则让对象玩家从卡组抽相应数量的卡。
function c23784496.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设定的抽卡玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果处理时重新计算手卡补到5张所需的抽卡数。
	local ct=5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ct>0 then
		-- 让玩家p从卡组抽ct张卡，抽卡原因为效果。
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
