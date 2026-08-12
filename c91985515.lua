--鋼核初期化
-- 效果：
-- 把自己场上存在的1只名字带有「核成」的怪兽解放发动。从自己的卡组·墓地把1张「核成兽的钢核」加入手卡。
function c91985515.initial_effect(c)
	-- 用于记录该卡片记有「核成兽的钢核」的卡名
	aux.AddCodeList(c,36623431)
	-- 把自己场上存在的1只名字带有「核成」的怪兽解放发动。从自己的卡组·墓地把1张「核成兽的钢核」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c91985515.cost)
	e1:SetTarget(c91985515.target)
	e1:SetOperation(c91985515.activate)
	c:RegisterEffect(e1)
end
-- 发动代价：解放自己场上1只「核成」怪兽
function c91985515.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的「核成」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x1d) end
	-- 选择自己场上1只可解放的「核成」怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x1d)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：卡名为「核成兽的钢核」且可以加入手卡
function c91985515.filter(c)
	return c:IsCode(36623431) and c:IsAbleToHand()
end
-- 效果发动目标：检查并设置将卡片加入手卡的操作信息
function c91985515.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在可以加入手卡的「核成兽的钢核」
	if chk==0 then return Duel.IsExistingMatchingCard(c91985515.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：将1张卡从卡组或墓地加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从卡组或墓地将1张「核成兽的钢核」加入手卡
function c91985515.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张「核成兽的钢核」（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c91985515.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示并确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
