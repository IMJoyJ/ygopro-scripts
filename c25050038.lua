--チェーン・ヒーリング
-- 效果：
-- 自己回复500基本分。这张卡在连锁2或者连锁3发动的场合，这张卡加入卡组洗切。这张卡在连锁4以后发动的场合，这张卡回到手卡。
function c25050038.initial_effect(c)
	-- 自己回复500基本分。这张卡在连锁2或者连锁3发动的场合，这张卡加入卡组洗切。这张卡在连锁4以后发动的场合，这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c25050038.rectg)
	e1:SetOperation(c25050038.recop)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标处理：无发动条件限制；通过SetTargetPlayer和SetTargetParam将回复玩家设为自身控制者、回复数值设为500，并设置操作信息以宣告将进行回复500LP的处理。
function c25050038.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁效果的对象玩家设置为效果发动者tp，即回复基本分的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁效果的对象参数设置为500，即要回复的基本分数值。
	Duel.SetTargetParam(500)
	-- 设置操作信息：本连锁的处理类别为CATEGORY_RECOVER，没有指定对象卡，对象玩家为tp，参数为500，供系统或其他效果进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果处理操作：先取得连锁中记录的目标玩家和数值并执行回复；随后取得效果所属的这张卡，确认其仍与效果关联后，根据当前连锁数决定将其回手卡（连锁4以上）或回卡组洗切（连锁2或3）。
function c25050038.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象玩家p（回复者）和对象参数d（回复数值500）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使玩家p回复d点基本分，回复原因记为效果（REASON_EFFECT）。
	Duel.Recover(p,d,REASON_EFFECT)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前正在处理的连锁序号，用于判断这张卡是在连锁2/3还是连锁4以上发动。
	local ct=Duel.GetCurrentChain()
	if ct>3 then
		c:CancelToGrave()
		-- 将这张卡送回持有者的手卡，原因为效果；此前需用CancelToGrave取消其作为魔陷发动后“送墓确定”的状态。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	elseif ct>1 then
		c:CancelToGrave()
		-- 将这张卡送回持有者的卡组并洗切，原因为效果；使用SEQ_DECKSHUFFLE表示返回卡组后要洗牌，此前需用CancelToGrave取消其送墓确定状态。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
