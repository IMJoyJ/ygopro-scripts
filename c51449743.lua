--チェーン・ブラスト
-- 效果：
-- 给与对方基本分500分伤害。这张卡在连锁2或者连锁3发动的场合，这张卡加入卡组洗切。这张卡在连锁4以后发动的场合，这张卡回到手卡。
function c51449743.initial_effect(c)
	-- 效果原文内容：给与对方基本分500分伤害。这张卡在连锁2或者连锁3发动的场合，这张卡加入卡组洗切。这张卡在连锁4以后发动的场合，这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c51449743.damtg)
	e1:SetOperation(c51449743.damop)
	c:RegisterEffect(e1)
end
-- 效果作用：设置伤害目标玩家和伤害值为500
function c51449743.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：将目标玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 效果作用：将目标参数设置为500
	Duel.SetTargetParam(500)
	-- 效果作用：设置操作信息为对对方造成500伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果原文内容：给与对方基本分500分伤害。这张卡在连锁2或者连锁3发动的场合，这张卡加入卡组洗切。这张卡在连锁4以后发动的场合，这张卡回到手卡。
function c51449743.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：对目标玩家造成指定伤害值
	Duel.Damage(p,d,REASON_EFFECT)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 效果作用：获取当前处理的连锁序号
	local ct=Duel.GetCurrentChain()
	if ct>3 then
		c:CancelToGrave()
		-- 效果作用：将此卡送回手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	elseif ct>1 then
		c:CancelToGrave()
		-- 效果作用：将此卡加入卡组并洗切
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
