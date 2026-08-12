--未熟な密偵
-- 效果：
-- 指定对方的1张手卡进行观看。
function c81820689.initial_effect(c)
	-- 指定对方的1张手卡进行观看。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c81820689.cftg)
	e1:SetOperation(c81820689.cfop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件检查与目标玩家设置
function c81820689.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查对方手牌数量是否至少有1张
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 将当前连锁的对象玩家设置为发动效果的玩家
	Duel.SetTargetPlayer(tp)
end
-- 效果处理，让玩家选择对方的1张手牌进行观看并洗牌
function c81820689.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为对象的玩家（即发动效果的玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要确认的卡片
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从对方手牌中选择1张卡
	local g=Duel.SelectMatchingCard(p,nil,p,0,LOCATION_HAND,1,1,nil)
	if g:GetCount()>0 then
		-- 向该玩家展示所选择的对方手牌（进行观看）
		Duel.ConfirmCards(p,g)
		-- 洗切对方的手牌
		Duel.ShuffleHand(1-p)
	end
end
