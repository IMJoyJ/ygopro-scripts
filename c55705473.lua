--バオバブーン
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。自己从卡组抽1张，那之后选1张手卡回到卡组最上面或者最下面。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「狒狒面包树」任意数量特殊召唤。
function c55705473.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。自己从卡组抽1张，那之后选1张手卡回到卡组最上面或者最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55705473,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c55705473.drtg)
	e1:SetOperation(c55705473.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「狒狒面包树」任意数量特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55705473,3))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c55705473.spcon)
	e3:SetTarget(c55705473.sptg)
	e3:SetOperation(c55705473.spop)
	c:RegisterEffect(e3)
end
-- 抽卡效果的发动准备（Target）
function c55705473.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家tp从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的实际处理（Operation）
function c55705473.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，若实际抽卡数量小于1张则结束处理
	if Duel.Draw(p,d,REASON_EFFECT)<1 then return end
	-- 提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手卡中选择1张可以送回卡组的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使后续的送回卡组动作与抽卡不视为同时进行
		Duel.BreakEffect()
		-- 让玩家选择将卡片送回卡组最上面还是最下面
		if Duel.SelectOption(tp,aux.Stringid(55705473,1),aux.Stringid(55705473,2))==0 then  --"回到卡组最上面/回到卡组最下面"
			-- 将选中的卡送回卡组最上面
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 将选中的卡送回卡组最下面
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
-- 特殊召唤效果的发动条件：被战斗或效果破坏
function c55705473.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 特殊召唤过滤函数：卡名为「狒狒面包树」且可以特殊召唤
function c55705473.spfilter(c,e,tp)
	return c:IsCode(55705473) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备（Target）
function c55705473.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足特殊召唤条件的「狒狒面包树」
		and Duel.IsExistingMatchingCard(c55705473.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为：从卡组特殊召唤至少1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的实际处理（Operation）
function c55705473.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择任意数量（不超过可用区域数）的「狒狒面包树」
	local g=Duel.SelectMatchingCard(tp,c55705473.spfilter,tp,LOCATION_DECK,0,1,ct,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
