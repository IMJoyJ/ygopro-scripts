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
-- 代价函数：发动前检查此卡能否解放，若能则解放自身作为发动代价。
function c16796157.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以解放自身（REASON_COST）来支付发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡名必须为「异次元超能人·星斗罗宾」且能够加入手卡。
function c16796157.filter(c)
	return c:IsCode(80208158) and c:IsAbleToHand()
end
-- 目标函数：确认卡组或墓地存在可检索目标，并设置效果处理的回手牌信息。
function c16796157.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己的卡组·墓地中存在至少1只「异次元超能人·星斗罗宾」且能加入手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c16796157.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次处理将执行把1张卡加入手牌（CATEGORY_TOHAND）的检索效果，来源为卡组·墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果处理函数：从符合条件的卡中选择1张加入手牌，并向对方确认。
function c16796157.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地选择1张符合条件的「异次元超能人·星斗罗宾」（应用王家长眠之谷的过滤规则）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16796157.filter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡（效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
