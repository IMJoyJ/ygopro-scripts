--チェーン・ブラスト
-- 效果：
-- 给与对方基本分500分伤害。这张卡在连锁2或者连锁3发动的场合，这张卡加入卡组洗切。这张卡在连锁4以后发动的场合，这张卡回到手卡。
function c51449743.initial_effect(c)
	-- 给与对方基本分500分伤害。这张卡在连锁2或者连锁3发动的场合，这张卡加入卡组洗切。这张卡在连锁4以后发动的场合，这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c51449743.damtg)
	e1:SetOperation(c51449743.damop)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标确认函数：无条件允许发动，并将对方玩家设为对象、伤害值设为500，同时登记本次操作信息。
function c51449743.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方（1-tp），表示伤害的对象为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为500，作为之后要造成的伤害数值。
	Duel.SetTargetParam(500)
	-- 登记效果操作信息：分类为伤害，对象为对方玩家，伤害数值为500，供后续处理或效果侦测使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理函数：先取得记录的目标玩家和伤害值并对对方造成伤害；之后若此卡仍与效果关联，则根据当前连锁数，连锁4以上回到手卡，连锁2或3回到卡组洗切。
function c51449743.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家和伤害参数，分别赋值给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对p玩家造成d点伤害（即500伤害）。
	Duel.Damage(p,d,REASON_EFFECT)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前正在处理的连锁序号，用于判断此卡是在连锁几发动的。
	local ct=Duel.GetCurrentChain()
	if ct>3 then
		c:CancelToGrave()
		-- 将此卡送回持有者的手卡（对应连锁4以后发动时的处理）。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	elseif ct>1 then
		c:CancelToGrave()
		-- 将此卡送回持有者的卡组并要求洗切（对应连锁2或3发动时的处理）。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
