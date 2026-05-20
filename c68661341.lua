--一点買い
-- 效果：
-- 这张卡以外的手卡有3张以上存在，那之中没有怪兽卡存在的场合，把手卡全部表侧表示从游戏中除外才能发动。从卡组把1只怪兽加入手卡。这个回合，自己不能把加入手卡的同名怪兽以外的怪兽召唤·特殊召唤。
function c68661341.initial_effect(c)
	-- 这张卡以外的手卡有3张以上存在，那之中没有怪兽卡存在的场合，把手卡全部表侧表示从游戏中除外才能发动。从卡组把1只怪兽加入手卡。这个回合，自己不能把加入手卡的同名怪兽以外的怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c68661341.cost)
	e1:SetTarget(c68661341.target)
	e1:SetOperation(c68661341.activate)
	c:RegisterEffect(e1)
end
-- 过滤手牌中是怪兽卡或者不能作为代价除外的卡
function c68661341.cfilter(c)
	return c:IsType(TYPE_MONSTER) or not c:IsAbleToRemoveAsCost()
end
-- 发动代价：检查手牌数量和种类，并将除这张卡以外的所有手牌表侧表示除外
function c68661341.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家的所有手牌
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	g:RemoveCard(e:GetHandler())
	if chk==0 then return g:GetCount()>=3 and not g:IsExists(c68661341.cfilter,1,nil) end
	-- 将手牌全部表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤卡组中可以加入手牌的怪兽卡
function c68661341.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动目标：检查卡组中是否存在可检索的怪兽，并设置检索的操作信息
function c68661341.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可以加入手牌的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c68661341.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果会将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只怪兽加入手牌，并给自身玩家施加本回合不能召唤·特殊召唤同名怪兽以外怪兽的限制
function c68661341.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,c68661341.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 这个回合，自己不能把加入手卡的同名怪兽以外的怪兽召唤·特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c68661341.sumlimit)
		e1:SetLabel(g:GetFirst():GetCode())
		-- 注册不能召唤同名卡以外怪兽的效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		-- 注册不能特殊召唤同名卡以外怪兽的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 召唤·特殊召唤限制的过滤函数，若怪兽卡名与加入手牌的卡不同则不能召唤·特殊召唤
function c68661341.sumlimit(e,c)
	return not c:IsCode(e:GetLabel())
end
