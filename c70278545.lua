--謙虚な壺
-- 效果：
-- ①：选自己2张手卡回到卡组。
function c70278545.initial_effect(c)
	-- ①：选自己2张手卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c70278545.target)
	e1:SetOperation(c70278545.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的阶段：检查自己手卡中是否有2张以上可回到卡组的卡，并设置目标玩家与操作信息
function c70278545.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡中是否存在至少2张可以回到卡组的卡（不包括此卡自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 将当前连锁的对象玩家设定为自己
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息为：将自己手卡的2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
end
-- 效果处理的阶段：从手卡选择2张卡回到卡组并洗牌
function c70278545.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取该玩家手卡中所有可以回到卡组的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
	if g:GetCount()>=2 then
		-- 向玩家发送提示信息，要求选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(p,2,2,nil)
		-- 将选择的卡送回卡组并洗牌
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
