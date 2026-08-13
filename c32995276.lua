--リンク・ディサイプル
-- 效果：
-- 4星以下的电子界族怪兽1只
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡所连接区1只怪兽解放才能发动。自己从卡组抽1张，那之后选1张手卡回到卡组最下面。
function c32995276.initial_effect(c)
	c:EnableReviveLimit()
	-- 为连接弟子添加连接召唤手续：使用1只4星以下的电子界族怪兽作为连接素材。
	aux.AddLinkProcedure(c,c32995276.matfilter,1,1)
	-- 这个卡名的效果1回合只能使用1次。①：把这张卡所连接区1只怪兽解放才能发动。自己从卡组抽1张，那之后选1张手卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32995276,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,32995276)
	e1:SetCost(c32995276.cost)
	e1:SetTarget(c32995276.target)
	e1:SetOperation(c32995276.operation)
	c:RegisterEffect(e1)
end
-- 定义连接素材过滤条件：等级4以下且为电子界族怪兽。
function c32995276.matfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_CYBERSE)
end
-- 判断怪兽是否属于指定的连接区怪兽组，用于筛选存在于这张卡所连接区的怪兽。
function c32995276.cfilter(c,g)
	return g:IsContains(c)
end
-- 定义发动代价：从这张卡所连接区解放1只怪兽作为发动条件。
function c32995276.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 效果发动合法性检查：确认自己场上是否存在1只位于此卡连接区且可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c32995276.cfilter,1,nil,lg) end
	-- 从自己场上选择1只位于此卡连接区的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c32995276.cfilter,1,1,nil,lg)
	-- 将选择的怪兽解放，解放原因为代价，不触发“不受效果影响”等抗性。
	Duel.Release(g,REASON_COST)
end
-- 定义效果发动时的目标设定：将对象玩家设为自己，抽卡数设定为1，并登记抽卡操作信息。
function c32995276.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将效果的对象玩家设为自己，表示抽卡效果的受益者是自己。
	Duel.SetTargetPlayer(tp)
	-- 将效果对象参数设为1，表示后续要抽卡的数量为1。
	Duel.SetTargetParam(1)
	-- 登记本次连锁的操作信息：效果分类为抽卡，抽卡玩家为自己，预计抽卡数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理流程：抽1张卡，然后选择1张手卡返回卡组最下面；若抽卡没有实际发生则后续不处理。
function c32995276.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和抽卡数量参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家按设定数量抽卡，若实际抽卡数为0则结束效果处理。
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	-- 向玩家显示选择提示，要求选择1张要返回卡组的手卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手卡中选择1张能够返回卡组的卡，作为送回卡组底部的对象。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使后续“手卡回卡组”与之前的“抽卡”视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 将选出的手卡以效果原因送回持有者卡组的最底端。
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
