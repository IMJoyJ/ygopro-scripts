--影霊衣の降魔鏡
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把自己墓地的「影灵衣」怪兽除外，从手卡把1只「影灵衣」仪式怪兽仪式召唤。
-- ②：自己场上没有怪兽存在的场合，从自己墓地把1只「影灵衣」怪兽和这张卡除外才能发动。从卡组把1张「影灵衣」魔法卡加入手卡。
function c14735698.initial_effect(c)
	-- 创建并注册①效果的仪式召唤效果：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放，或者作为解放的代替而把自己墓地的「影灵衣」怪兽除外，从手卡把1只「影灵衣」仪式怪兽仪式召唤。
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
-- 筛选函数：判断卡是否为「影灵衣」字段的卡，用于仪式召唤效果中选择符合条件的仪式怪兽。
function c14735698.filter(c)
	return c:IsSetCard(0xb4)
end
-- ②效果的发动条件函数：检查自己场上是否存在怪兽。
function c14735698.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上怪兽区域的数量是否为0，即自己场上没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 代价筛选函数：选择自己墓地中「影灵衣」字段的怪兽，且该怪兽可作为代价被除外。
function c14735698.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ②效果的代价函数：在chk==0时检查能否将墓地的这张卡自身和1只「影灵衣」怪兽除外作为代价。
function c14735698.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 同时检查自己墓地是否存在至少1只满足条件的「影灵衣」怪兽可以作为代价除外。
		and Duel.IsExistingMatchingCard(c14735698.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足条件的「影灵衣」怪兽，作为解放的代替除外素材。
	local g=Duel.SelectMatchingCard(tp,c14735698.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选择的「影灵衣」怪兽和这张卡以表侧表示除外，作为发动②效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 目标筛选函数：选择卡组中「影灵衣」字段的魔法卡，且该卡可以被加入手卡。
function c14735698.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ②效果的发动目标函数：确认卡组中是否存在符合条件的「影灵衣」魔法卡，并登记检索回手牌的操作信息。
function c14735698.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中存在至少1张符合条件的「影灵衣」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c14735698.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次效果处理为从卡组将1张卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张「影灵衣」魔法卡加入手卡，并向对方玩家展示。
function c14735698.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「影灵衣」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c14735698.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「影灵衣」魔法卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
