--モンスター・アイ
-- 效果：
-- 支付1000基本分发动。自己墓地存在的1张「融合」回到手卡。
function c84133008.initial_effect(c)
	-- 支付1000基本分发动。自己墓地存在的1张「融合」回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84133008,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c84133008.thcost)
	e1:SetTarget(c84133008.thtg)
	e1:SetOperation(c84133008.thop)
	c:RegisterEffect(e1)
end
-- 定义发动代价：支付1000基本分
function c84133008.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000点基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除1000点基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 过滤条件：卡名为「融合」且能加入手牌的卡
function c84133008.filter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 定义效果发动的目标检测与操作信息设置
function c84133008.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可加入手牌的「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c84133008.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：将自己墓地的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 定义效果处理：将自己墓地的1张「融合」加入手牌
function c84133008.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择自己墓地中1张不受「王家长眠之谷」影响的「融合」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c84133008.filter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
