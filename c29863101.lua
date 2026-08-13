--バスター・テレポート
-- 效果：
-- 从自己手卡让1只名字带有「/爆裂体」的怪兽回到卡组发动。从自己卡组抽2张卡。
function c29863101.initial_effect(c)
	-- 从自己手卡让1只名字带有「/爆裂体」的怪兽回到卡组发动。从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c29863101.cost)
	e1:SetTarget(c29863101.target)
	e1:SetOperation(c29863101.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器：检查手卡中的卡是否为名字带有「/爆裂体」的怪兽且可以返回卡组。
function c29863101.filter(c)
	return c:IsSetCard(0x104f) and c:IsAbleToDeck()
end
-- 发动代价处理：从手卡选择1只名字带有「/爆裂体」的怪兽返回卡组，并给对方确认，然后洗回卡组。
function c29863101.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：手卡中是否存在至少1只满足条件的「/爆裂体」怪兽可以作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c29863101.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家显示选择提示，提示内容为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让发动玩家从手卡选择1张满足过滤器条件的「/爆裂体」怪兽。
	local g=Duel.SelectMatchingCard(tp,c29863101.filter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 将选择的卡返回持有者卡组并洗切，此次返回卡组的原因为发动代价。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 效果发动时的目标设定：指定发动者为抽卡玩家，设定抽卡数量为2，并登记抽卡效果的操作信息。
function c29863101.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：发动玩家是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设置为发动者，表示由发动者执行抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为2，表示抽卡数量为2。
	Duel.SetTargetParam(2)
	-- 设置操作信息：分类为抽卡效果，目标玩家为发动者，预计抽卡数量为2（用于后续处理及效果发动检测）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：从连锁信息中取出目标玩家和抽卡数量，并让该玩家抽取对应数量的卡。
function c29863101.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和参数（即抽卡玩家与抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
