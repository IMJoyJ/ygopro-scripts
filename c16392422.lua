--トゥーン・仮面魔道士
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤的回合不能攻击。场上的「卡通世界」被破坏时这张卡也破坏。自己场上有「卡通世界」且对方不控制卡通的场合，这张卡可以直接攻击对方玩家。这张卡造成对方伤害时，这张卡的持有者抽1张卡。
function c16392422.initial_effect(c)
	-- 记录本卡文本中记载了卡名「卡通世界」（卡号15259703），使涉及“记载了特定卡名”的判别可用。
	aux.AddCodeList(c,15259703)
	-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。（此处对应通常召唤成功时附加不能攻击的处理，反转召唤·特殊召唤由后续克隆效果实现。）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c16392422.atklimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ④：场上的「卡通世界」被破坏时这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c16392422.sdescon)
	e4:SetOperation(c16392422.sdesop)
	c:RegisterEffect(e4)
	-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(c16392422.dircon)
	c:RegisterEffect(e5)
	-- ③：这张卡给与对方战斗伤害的场合发动。自己抽1张。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(16392422,0))  --"抽卡"
	e6:SetCategory(CATEGORY_DRAW)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_BATTLE_DAMAGE)
	e6:SetCondition(c16392422.condition)
	e6:SetTarget(c16392422.target)
	e6:SetOperation(c16392422.operation)
	c:RegisterEffect(e6)
end
-- 处理召唤成功后的限制：为这张卡注册一个“不能攻击”的永续效果，该效果持续到结束阶段或这张卡离场等标准重置时。
function c16392422.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 筛选离场事件中的卡是否为「卡通世界」：要求该卡是被破坏离场、离场前表侧表示、离场前位于场上且离场前的卡号为15259703。
function c16392422.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 自坏效果的诱发条件：本次离场事件组中存在满足sfilter的卡，即场上表侧表示的「卡通世界」被破坏时条件成立。
function c16392422.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16392422.sfilter,1,nil)
end
-- 自坏效果的处理：将这张卡通怪兽自身以效果原因破坏。
function c16392422.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏理由将效果持有者（这张卡通怪兽）破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 判断一张卡是否为表侧表示且卡号是15259703（即表侧表示的「卡通世界」）。
function c16392422.dirfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 判断一张卡是否为表侧表示的卡通怪兽（类型包含TYPE_TOON）。
function c16392422.dirfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击的允许条件：自己场上有表侧表示「卡通世界」，并且对方怪兽区没有表侧表示的卡通怪兽。
function c16392422.dircon(e)
	-- 检查自己场上是否存在至少1张表侧表示且卡名为「卡通世界」的卡。
	return Duel.IsExistingMatchingCard(c16392422.dirfilter1,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
		-- 并且对方怪兽区不存在表侧表示且类型为卡通的怪兽。
		and not Duel.IsExistingMatchingCard(c16392422.dirfilter2,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 抽卡效果的诱发条件：受到战斗伤害的玩家不是这张卡的控制者，即这张卡给与对方战斗伤害。
function c16392422.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 发动时的目标处理：无取对象，设置抽卡的玩家为这张卡的控制者tp，抽卡张数参数为1，并登记抽卡类别的操作信息。
function c16392422.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的对象玩家设置为这张卡的控制者，表示由该玩家抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁的对象参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记抽卡效果的操作信息：类别为抽卡，无指定对象，对象玩家为tp，抽卡参数为1，供其他卡进行对应或无效判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 实际处理：从连锁信息中取出对象玩家和抽卡张数，让该玩家以效果原因抽取对应数量的卡。
function c16392422.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象玩家和对象参数，分别赋值给p（抽卡玩家）和d（抽卡张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
