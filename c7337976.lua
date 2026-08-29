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
-- 丢弃1张手卡的发动代价
function c7337976.tgcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方提示选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 从手卡选择1张要丢弃的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡作为代价丢弃去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤可送去墓地的恶魔族怪兽
function c7337976.filter1(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToGrave()
end
-- 堆墓效果的发动目标判定与操作信息注册
function c7337976.tgtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在可以送去墓地的恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7337976.filter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 从卡组把1只恶魔族怪兽送去墓地效果处理
function c7337976.tgop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,c7337976.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的恶魔族怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 将魔陷区表侧表示的这张卡送去墓地的发动代价
function c7337976.tgcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 向对方提示选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 把自身作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤可送去墓地的「狱火机」怪兽
function c7337976.filter2(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 过滤从额外卡组特殊召唤的怪兽
function c7337976.exfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 狱火机堆墓效果的发动目标判定与操作信息注册
function c7337976.tgtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上从额外卡组特殊召唤的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c7337976.exfilter,tp,0,LOCATION_MZONE,nil)
	-- 获取手卡·卡组中可以送去墓地的「狱火机」怪兽
	local g=Duel.GetMatchingGroup(c7337976.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if chk==0 then return ct>0 and g:GetCount()>0 end
	-- 设置从手卡·卡组送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 把「狱火机」怪兽从手卡·卡组送去墓地效果处理
function c7337976.tgop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上从额外卡组特殊召唤的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c7337976.exfilter,tp,0,LOCATION_MZONE,nil)
	if ct<=0 then return end
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 获取手卡·卡组中可以送去墓地的「狱火机」怪兽
	local g=Duel.GetMatchingGroup(c7337976.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 设置同名卡最多1张的检查函数
	aux.GCheckAdditional=aux.dncheck
	-- 从手卡·卡组选择最多为该数量的不同名「狱火机」怪兽
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,ct)
	-- 重置卡片组检查函数
	aux.GCheckAdditional=nil
	if sg then
		-- 将选中的「狱火机」怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
