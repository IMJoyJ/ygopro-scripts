--影霊衣の反魂術
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放，从自己的手卡·墓地把1只「影灵衣」仪式怪兽仪式召唤。
-- ②：自己场上没有怪兽存在的场合，从自己墓地把1只「影灵衣」怪兽和这张卡除外才能发动。从卡组把1张「影灵衣」魔法卡加入手卡。
function c97211663.initial_effect(c)
	-- 添加仪式召唤效果，可从手卡·墓地仪式召唤，且解放怪兽的等级合计必须等于仪式怪兽的等级
	local e1=aux.AddRitualProcEqual2(c,c97211663.filter,LOCATION_HAND+LOCATION_GRAVE,nil,nil,true)
	e1:SetCountLimit(1,97211663)
	c:RegisterEffect(e1)
	-- ②：自己场上没有怪兽存在的场合，从自己墓地把1只「影灵衣」怪兽和这张卡除外才能发动。从卡组把1张「影灵衣」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c97211663.thcon)
	e2:SetCost(c97211663.thcost)
	e2:SetTarget(c97211663.thtg)
	e2:SetOperation(c97211663.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：属于「影灵衣」字段的卡
function c97211663.filter(c)
	return c:IsSetCard(0xb4)
end
-- 定义效果②的发动条件函数
function c97211663.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤条件：自己墓地中可以作为代价除外的「影灵衣」怪兽
function c97211663.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 定义效果②的发动代价函数，并检查自身及墓地另1只「影灵衣」怪兽是否能除外
function c97211663.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己墓地是否存在至少1只可以作为代价除外的「影灵衣」怪兽
		and Duel.IsExistingMatchingCard(c97211663.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的「影灵衣」怪兽
	local g=Duel.SelectMatchingCard(tp,c97211663.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选中的怪兽和墓地的这张卡表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中可以加入手卡的「影灵衣」魔法卡
function c97211663.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 定义效果②的靶向/发动准备函数，检查卡组中是否存在可检索的卡并设置操作信息
function c97211663.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以加入手卡的「影灵衣」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c97211663.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果②的效果处理函数
function c97211663.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「影灵衣」魔法卡
	local g=Duel.SelectMatchingCard(tp,c97211663.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
