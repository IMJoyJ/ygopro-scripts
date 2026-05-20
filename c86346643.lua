--レインボー・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「究极宝玉神」怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●把自己场上1只怪兽送去墓地才能发动。对方场上的怪兽全部回到持有者卡组。
-- ●把自己场上1张魔法·陷阱卡送去墓地才能发动。对方场上的魔法·陷阱卡全部回到持有者卡组。
-- ●把卡组最上面的卡送去墓地才能发动。对方墓地的卡全部回到卡组。
function c86346643.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「元素英雄 新宇侠」和1只「究极宝玉神」怪兽
	aux.AddFusionProcCodeFun(c,89943723,aux.FilterBoolFunction(Card.IsFusionSetCard,0x2034),1,false,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过融合召唤来特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ●把自己场上1只怪兽送去墓地才能发动。对方场上的怪兽全部回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86346643,1))  --"对方场上怪兽全部回到卡组"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(c86346643.tdcost1)
	e2:SetTarget(c86346643.tdtg1)
	e2:SetOperation(c86346643.tdop1)
	c:RegisterEffect(e2)
	-- ●把自己场上1张魔法·陷阱卡送去墓地才能发动。对方场上的魔法·陷阱卡全部回到持有者卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86346643,2))  --"对方场上的魔法·陷阱卡全部回到卡组"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCost(c86346643.tdcost2)
	e3:SetTarget(c86346643.tdtg2)
	e3:SetOperation(c86346643.tdop2)
	c:RegisterEffect(e3)
	-- ●把卡组最上面的卡送去墓地才能发动。对方墓地的卡全部回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(86346643,3))  --"对方墓地的卡全部回到卡组"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCost(c86346643.tdcost3)
	e4:SetTarget(c86346643.tdtg3)
	e4:SetOperation(c86346643.tdop3)
	c:RegisterEffect(e4)
end
c86346643.material_setcode=0x8
-- 过滤可以作为代价送去墓地的卡片
function c86346643.cfilter1(c)
	return c:IsAbleToGraveAsCost()
end
-- 效果①中“把自己场上1只怪兽送去墓地”代价的检查与处理函数
function c86346643.tdcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可以作为代价送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86346643.cfilter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方玩家提示所选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1只怪兽
	local g=Duel.SelectMatchingCard(tp,c86346643.cfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①中“对方场上的怪兽全部回到持有者卡组”目标的检查与处理函数
function c86346643.tdtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以回到卡组的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可以回到卡组的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,nil)
	-- 设置效果处理信息为将对方场上的怪兽全部送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果①中“对方场上的怪兽全部回到持有者卡组”的实际操作函数
function c86346643.tdop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以回到卡组的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上的这些怪兽全部送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 过滤可以作为代价送去墓地的魔法·陷阱卡
function c86346643.cfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 效果①中“把自己场上1张魔法·陷阱卡送去墓地”代价的检查与处理函数
function c86346643.tdcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张可以作为代价送去墓地的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c86346643.cfilter2,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向对方玩家提示所选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1张魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c86346643.cfilter2,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的魔法·陷阱卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤对方场上可以回到卡组的魔法·陷阱卡
function c86346643.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 效果①中“对方场上的魔法·陷阱卡全部回到持有者卡组”目标的检查与处理函数
function c86346643.tdtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以回到卡组的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c86346643.filter2,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可以回到卡组的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c86346643.filter2,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息为将对方场上的魔法·陷阱卡全部送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果①中“对方场上的魔法·陷阱卡全部回到持有者卡组”的实际操作函数
function c86346643.tdop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以回到卡组的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c86346643.filter2,tp,0,LOCATION_ONFIELD,nil)
	-- 将对方场上的这些魔法·陷阱卡全部送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 效果①中“把卡组最上面的卡送去墓地”代价的检查与处理函数
function c86346643.tdcost3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能将卡组最上方的1张卡作为代价送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	-- 向对方玩家提示所选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将自己卡组最上方的1张卡作为代价送去墓地
	Duel.DiscardDeck(tp,1,REASON_COST)
end
-- 效果①中“对方墓地的卡全部回到卡组”目标的检查与处理函数
function c86346643.tdtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方墓地是否存在可以回到卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	-- 获取对方墓地所有可以回到卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,nil)
	-- 设置效果处理信息为将对方墓地的卡全部送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果①中“对方墓地的卡全部回到卡组”的实际操作函数
function c86346643.tdop3(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方墓地所有可以回到卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,nil)
	-- 检查并应用「王家长眠之谷」对涉及墓地卡片效果的无效化处理
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将对方墓地的这些卡全部送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
