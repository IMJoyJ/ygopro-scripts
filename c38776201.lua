--三幻魔解放
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把3只卡名不同的「三幻魔」怪兽加入手卡。那之后，选自己2张手卡丢弃。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。把1只不能通常召唤的10星的炎族·雷族·恶魔族怪兽从卡组加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册①检索3张「三幻魔」并丢弃2张手卡、②墓地除外自身检索10星特殊怪兽效果
function s.initial_effect(c)
	-- ①：从卡组把3只卡名不同的「三幻魔」怪兽加入手卡。那之后，选自己2张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。把1只不能通常召唤的10星的炎族·雷族·恶魔族怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置发动代价：将墓地的这张卡自身除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 检索卡片过滤：属于「三幻魔」系列的怪兽且可以加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1144) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果目标确认：卡组存在至少3种「三幻魔」怪兽并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有符合条件的「三幻魔」怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
	-- 设置将3张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,3,tp,LOCATION_DECK)
	-- 设置将自己2张手卡丢弃的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,2)
end
-- ①效果操作：从卡组把3只卡名不同的「三幻魔」怪兽加入手卡，那之后选2张手卡丢弃
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合条件的「三幻魔」怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<3 then return end
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择3只卡名各不相同的「三幻魔」怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	if sg then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,sg)
		-- 从手卡中选择2张可丢弃的卡片
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,2,2,nil,REASON_DISCARD+REASON_EFFECT)
		if dg:GetCount()>0 then
			-- 洗切自身手卡
			Duel.ShuffleHand(tp)
			-- 将选中的2张手卡丢弃送去墓地
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 检索卡片过滤：不能通常召唤的10星炎族·雷族·恶魔族怪兽且可以加入手卡
function s.thfilter2(c)
	return not c:IsSummonableCard() and c:IsRace(RACE_PYRO+RACE_THUNDER+RACE_FIEND)
		and c:IsLevel(10) and c:IsAbleToHand()
end
-- ②效果目标确认：确认卡组存在符合条件的怪兽并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果操作：从卡组把1只符合条件的怪兽加入手卡并展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
