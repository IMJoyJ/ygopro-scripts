--チェーン・ヒーリング
-- 效果：
-- 自己回复500基本分。这张卡在连锁2或者连锁3发动的场合，这张卡加入卡组洗切。这张卡在连锁4以后发动的场合，这张卡回到手卡。
function c25050038.initial_effect(c)
	-- 效果发动时的初始化设置，包括类型、分类、属性、触发条件、目标函数和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c25050038.rectg)
	e1:SetOperation(c25050038.recop)
	c:RegisterEffect(e1)
end
-- 效果处理时的判断函数，用于设置目标玩家和参数
function c25050038.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前处理效果的目标玩家设置为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 将当前处理效果的目标参数设置为500
	Duel.SetTargetParam(500)
	-- 设置当前处理效果的操作信息为回复500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果处理函数，执行回复基本分并根据连锁序号决定卡的去向
function c25050038.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前正在处理的连锁序号
	local ct=Duel.GetCurrentChain()
	if ct>3 then
		c:CancelToGrave()
		-- 将此卡送回手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	elseif ct>1 then
		c:CancelToGrave()
		-- 将此卡加入卡组并洗切
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
