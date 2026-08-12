--針虫の巣窟
-- 效果：
-- ①：从自己卡组上面把5张卡送去墓地。
function c84968490.initial_effect(c)
	-- ①：从自己卡组上面把5张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(c84968490.distarget)
	e1:SetOperation(c84968490.disop)
	c:RegisterEffect(e1)
end
-- 效果发动的目标过滤与检测函数，设置效果的对象玩家、参数以及操作信息
function c84968490.distarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，判断自己是否能将卡组顶端的5张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为5
	Duel.SetTargetParam(5)
	-- 设置操作信息，表示此效果包含将玩家卡组顶端的5张卡送去墓地的分类
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,5)
end
-- 效果处理的执行函数，获取设定的参数并执行送去墓地的操作
function c84968490.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和参数值
	local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果将目标玩家卡组顶端指定数量的卡送去墓地
	Duel.DiscardDeck(p,val,REASON_EFFECT)
end
