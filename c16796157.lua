--野獣戦士ピューマン
-- 效果：
-- 把这张卡解放才能发动。从自己的卡组·墓地把1只「异次元超能人·星斗罗宾」加入手卡。
function c16796157.initial_effect(c)
	-- 把这张卡解放才能发动。从自己的卡组·墓地把1只「异次元超能人·星斗罗宾」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16796157,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c16796157.thcost)
	e1:SetTarget(c16796157.thtg)
	e1:SetOperation(c16796157.thop)
	c:RegisterEffect(e1)
end
-- 检查是否可以解放这张卡作为发动代价
function c16796157.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选「异次元超能人·星斗罗宾」卡
function c16796157.filter(c)
	return c:IsCode(80208158) and c:IsAbleToHand()
end
-- 设置效果的发动目标，检查场上是否存在满足条件的卡
function c16796157.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以自己为玩家，在墓地和卡组中是否存在至少1张「异次元超能人·星斗罗宾」
	if chk==0 then return Duel.IsExistingMatchingCard(c16796157.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示将要将1张卡从墓地或卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 处理效果的发动，选择并把符合条件的卡加入手牌
function c16796157.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地和卡组中选择1张「异次元超能人·星斗罗宾」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16796157.filter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
