--デステニー・デストロイ
-- 效果：
-- 从自己卡组的最上面把3张卡送去墓地。这个效果送去墓地的魔法·陷阱卡每有1张，自己受到1000分伤害。
function c62980542.initial_effect(c)
	-- 从自己卡组的最上面把3张卡送去墓地。这个效果送去墓地的魔法·陷阱卡每有1张，自己受到1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DAMAGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(c62980542.distg)
	e1:SetOperation(c62980542.disop)
	c:RegisterEffect(e1)
end
-- 效果发动的目标与操作信息设置
function c62980542.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以将卡组最上方的3张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为3
	Duel.SetTargetParam(3)
	-- 设置操作信息为将自己卡组最上方的3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 过滤出存在于墓地且是魔法或陷阱卡的卡片
function c62980542.filter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果处理：将卡组顶端的卡送去墓地，并根据送去墓地的魔陷数量给予自己伤害
function c62980542.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和参数（即自己和3张卡）
	local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果将目标玩家卡组最上方的指定数量卡片送去墓地
	Duel.DiscardDeck(p,val,REASON_EFFECT)
	-- 获取上一步实际操作（送去墓地）的卡片组
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c62980542.filter,nil)
	if ct>0 then
		-- 给予自己因效果送去墓地的魔陷数量×1000的伤害
		Duel.Damage(tp,ct*1000,REASON_EFFECT)
	end
end
