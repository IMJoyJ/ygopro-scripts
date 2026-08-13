--共命の翼ガルーラ
-- 效果：
-- 相同种族·属性而卡名不同的怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的战斗发生的对对方的战斗伤害变成2倍。
-- ②：这张卡被送去墓地的场合才能发动。自己抽1张。
function c11765832.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：需要选择2只满足相同种族·属性且卡名不同的怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,c11765832.ffilter,2,true)
	-- ①：这张卡的战斗发生的对对方的战斗伤害变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	-- 设置效果①：将这张卡战斗发生的对对方玩家的战斗伤害变为2倍（1表示对方玩家，DOUBLE_DAMAGE为2倍）。
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被送去墓地的场合才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11765832,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,11765832)
	e2:SetTarget(c11765832.target)
	e2:SetOperation(c11765832.operation)
	c:RegisterEffect(e2)
end
-- 定义一个匹配函数：判断素材c是否满足指定的属性attr和种族race，用于确认“相同种族·属性”条件。
function c11765832.matchfilter(c,attr,race)
	return c:IsFusionAttribute(attr) and c:IsRace(race)
end
-- 融合素材过滤函数：当已选素材组为空时允许当前卡作为素材；否则要求已选素材中除当前卡外的其他卡都与当前卡种族、属性相同，且没有与当前卡卡名相同的卡，从而保证素材满足“相同种族·属性而卡名不同”。
function c11765832.ffilter(c,fc,sub,mg,sg)
	-- 如果当前素材组sg为空（或其中不包含除当前候选择卡c以外的卡），则当前c可以作为第一只素材被选择。
	return not sg or sg:FilterCount(aux.TRUE,c)==0
		or (sg:IsExists(c11765832.matchfilter,#sg-1,c,c:GetFusionAttribute(),c:GetRace())
			and not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
-- 效果②的发动条件与发动时登记：自己可以抽1张卡时才能发动，并将抽卡对象玩家设为自己、抽卡数设为1，登记抽卡操作信息。
function c11765832.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动条件检查阶段（chk==0），确认玩家tp能否抽1张卡，若不能则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁效果的对象玩家设为tp（自己），即抽卡动作的受益玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁效果的对象参数设为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记操作信息：本连锁为抽卡效果（CATEGORY_DRAW），目标玩家为tp，预计抽卡数量为1（不取对象，targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②处理时的执行函数：从连锁信息中取出对象玩家与抽卡数，让该玩家以效果原因抽取对应数量的卡。
function c11765832.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象玩家和参数值，分别赋予p（抽卡玩家）和d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡：让玩家p以效果原因（REASON_EFFECT）抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
