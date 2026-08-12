--ALERT！
-- 效果：
-- 这个卡名在规则上也当作「救援ACE队」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地把1只「救援ACE队」怪兽加入手卡。自己场上有「救援ACE队 消防栓」存在的场合，也能作为代替从卡组把1只「救援ACE队」怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡的效果，设置为发动时点、自由连锁、一回合一发动、包含回手、检索和墓地动作的分类
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在「救援ACE队 消防栓」
function s.checkfilter(c)
	return c:IsCode(37617348) and c:IsFaceup()
end
-- 过滤满足「救援ACE队」卡组、怪兽类型、可加入手牌条件的卡，且必须在墓地或卡组中
function s.thfilter(c,check)
	return c:IsSetCard(0x18b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and (c:IsLocation(LOCATION_GRAVE) or check)
end
-- 判断是否满足发动条件，即场上有「救援ACE队 消防栓」或墓地/卡组中有「救援ACE队」怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在「救援ACE队 消防栓」
	local check=Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_ONFIELD,0,1,nil)
	-- 若未满足发动条件则返回false
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,check) end
end
-- 发动效果，检查场上是否存在「救援ACE队 消防栓」，提示选择加入手牌的卡，选择满足条件的卡并加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「救援ACE队 消防栓」
	local check=Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_ONFIELD,0,1,nil)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡，从墓地或卡组中选择一张「救援ACE队」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,check)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
