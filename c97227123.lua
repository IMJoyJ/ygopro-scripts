--リターン・オブ・ザ・デュエリスト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：场上或者自己或对方的墓地有超量怪兽存在的场合才能发动。从自己的卡组·墓地把1张装备魔法卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：场上或者自己或对方的墓地有超量怪兽存在的场合才能发动。从自己的卡组·墓地把1张装备魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查场上或双方墓地是否存在超量怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上（表侧表示）或双方墓地是否存在至少1只超量怪兽
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsType),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,TYPE_XYZ)
end
-- 过滤条件：卡组或墓地中可加入手牌的装备魔法卡
function s.thfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果发动的目标确认与操作信息设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组或墓地中是否存在可加入手牌的装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息：将卡组或墓地的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从卡组或墓地选择1张装备魔法卡加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张满足条件的装备魔法卡（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
