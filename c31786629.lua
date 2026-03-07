--サンダー・ドラゴン
-- 效果：
-- ①：把这张卡从手卡丢弃才能发动。从卡组把最多2只「雷龙」加入手卡。
function c31786629.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把最多2只「雷龙」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31786629,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c31786629.cost)
	e1:SetTarget(c31786629.target)
	e1:SetOperation(c31786629.operation)
	c:RegisterEffect(e1)
	c31786629.discard_effect=e1
end
-- 检查是否可以丢弃此卡作为发动代价
function c31786629.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡丢入墓地作为发动代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于筛选卡组中可加入手牌的「雷龙」
function c31786629.filter(c)
	return c:IsCode(31786629) and c:IsAbleToHand()
end
-- 设置效果发动时的处理信息，确定将从卡组检索「雷龙」加入手牌
function c31786629.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「雷龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c31786629.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，指定将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时执行的操作，选择并加入手牌
function c31786629.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1到2张「雷龙」
	local g=Duel.SelectMatchingCard(tp,c31786629.filter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选中的「雷龙」加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的「雷龙」
		Duel.ConfirmCards(1-tp,g)
	end
end
