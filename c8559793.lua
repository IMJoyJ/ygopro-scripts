--RR－ネスト
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有「急袭猛禽」怪兽2只以上存在的场合才能发动。从自己的卡组·墓地把1只「急袭猛禽」怪兽加入手卡。
function c8559793.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有「急袭猛禽」怪兽2只以上存在的场合才能发动。从自己的卡组·墓地把1只「急袭猛禽」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,8559793)
	e2:SetCondition(c8559793.condition)
	e2:SetTarget(c8559793.target)
	e2:SetOperation(c8559793.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的「急袭猛禽」卡
function c8559793.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xba)
end
-- 发动条件：检查自己场上是否存在2只以上的「急袭猛禽」怪兽
function c8559793.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只表侧表示的「急袭猛禽」怪兽
	return Duel.IsExistingMatchingCard(c8559793.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 过滤条件：卡组或墓地中可以加入手卡的「急袭猛禽」怪兽
function c8559793.filter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动准备：验证卡组或墓地中是否存在可加入手卡的怪兽，并设置操作信息
function c8559793.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组或墓地中是否存在至少1只满足条件的「急袭猛禽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c8559793.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从卡组或墓地选择1只「急袭猛禽」怪兽加入手卡，并进行确认和洗卡
function c8559793.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1只满足条件的「急袭猛禽」怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c8559793.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
	end
end
