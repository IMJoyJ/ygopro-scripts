--影霊衣の降魔鏡
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把自己墓地的「影灵衣」怪兽除外，从手卡把1只「影灵衣」仪式怪兽仪式召唤。
-- ②：自己场上没有怪兽存在的场合，从自己墓地把1只「影灵衣」怪兽和这张卡除外才能发动。从卡组把1张「影灵衣」魔法卡加入手卡。
function c14735698.initial_effect(c)
	-- 为卡片添加等级合计等于仪式怪兽等级的仪式召唤效果
	local e1=aux.AddRitualProcEqual2(c,c14735698.filter,nil,c14735698.filter,nil,true)
	e1:SetCountLimit(1,14735698)
	c:RegisterEffect(e1)
	-- ②：自己场上没有怪兽存在的场合，从自己墓地把1只「影灵衣」怪兽和这张卡除外才能发动。从卡组把1张「影灵衣」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c14735698.thcon)
	e2:SetCost(c14735698.thcost)
	e2:SetTarget(c14735698.thtg)
	e2:SetOperation(c14735698.thop)
	c:RegisterEffect(e2)
end
-- 判断怪兽是否为「影灵衣」系列
function c14735698.filter(c)
	return c:IsSetCard(0xb4)
end
-- 判断自己场上是否没有怪兽
function c14735698.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否没有怪兽存在
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 判断墓地的怪兽是否为「影灵衣」系列且为怪兽类型
function c14735698.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 设置效果的发动费用处理函数
function c14735698.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己墓地是否存在至少1张「影灵衣」怪兽
		and Duel.IsExistingMatchingCard(c14735698.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择1张满足条件的墓地怪兽
	local g=Duel.SelectMatchingCard(tp,c14735698.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选中的卡片除外作为发动费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 判断卡组中是否存在「影灵衣」魔法卡
function c14735698.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置效果的发动目标处理函数
function c14735698.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「影灵衣」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c14735698.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果发动后将要处理的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果的发动处理函数
function c14735698.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择1张满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c14735698.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
