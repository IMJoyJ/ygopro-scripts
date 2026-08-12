--煉獄の災天
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：丢弃1张手卡才能发动。从卡组把1只恶魔族怪兽送去墓地。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。把最多有从额外卡组特殊召唤的对方场上的怪兽数量的「狱火机」怪兽从手卡·卡组送去墓地（同名卡最多1张）。
function c7337976.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡才能发动。从卡组把1只恶魔族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7337976,0))  --"丢弃1张手卡"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,7337976)
	e2:SetCost(c7337976.tgcost1)
	e2:SetTarget(c7337976.tgtg1)
	e2:SetOperation(c7337976.tgop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(7337976,1))  --"这张卡送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetCost(c7337976.tgcost2)
	e3:SetTarget(c7337976.tgtg2)
	e3:SetOperation(c7337976.tgop2)
	c:RegisterEffect(e3)
end
-- 效果①的发动代价（Cost）函数：丢弃1张手卡。
function c7337976.tgcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方玩家提示发动了“丢弃1张手卡”的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 玩家选择手牌中1张可以丢弃的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡作为代价丢弃送去墓地。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组中的恶魔族怪兽且能送去墓地。
function c7337976.filter1(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToGrave()
end
-- 效果①的发动准备（Target）函数。
function c7337976.tgtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可以送去墓地的恶魔族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c7337976.filter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）函数。
function c7337976.tgop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1只恶魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,c7337976.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的发动代价（Cost）函数：将表侧表示的这张卡送去墓地。
function c7337976.tgcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 向对方玩家提示发动了“这张卡送去墓地”的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将作为源头的这张卡作为代价送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：手牌或卡组中的「狱火机」怪兽且能送去墓地。
function c7337976.filter2(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 过滤条件：从额外卡组特殊召唤的怪兽。
function c7337976.exfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果②的发动准备（Target）函数。
function c7337976.tgtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上从额外卡组特殊召唤的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c7337976.exfilter,tp,0,LOCATION_MZONE,nil)
	-- 获取手牌和卡组中所有可以送去墓地的「狱火机」怪兽。
	local g=Duel.GetMatchingGroup(c7337976.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if chk==0 then return ct>0 and g:GetCount()>0 end
	-- 设置效果处理信息：从手牌或卡组将卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的效果处理（Operation）函数。
function c7337976.tgop2(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取对方场上从额外卡组特殊召唤的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c7337976.exfilter,tp,0,LOCATION_MZONE,nil)
	if ct<=0 then return end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 获取手牌和卡组中所有可以送去墓地的「狱火机」怪兽。
	local g=Duel.GetMatchingGroup(c7337976.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 设置卡片组选择的附加检查条件：所选卡片的卡名必须各不相同。
	aux.GCheckAdditional=aux.dncheck
	-- 玩家选择1到ct张（最多为对方场上额外特召怪兽数量）卡名不同的「狱火机」怪兽。
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,ct)
	-- 重置卡片组选择的附加检查条件。
	aux.GCheckAdditional=nil
	if sg:GetCount()>0 then
		-- 将选择的「狱火机」怪兽因效果送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
