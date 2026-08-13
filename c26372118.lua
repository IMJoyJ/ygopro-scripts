--ALERT！
-- 效果：
-- 这个卡名在规则上也当作「救援ACE队」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地把1只「救援ACE队」怪兽加入手卡。自己场上有「救援ACE队 消防栓」存在的场合，也能作为代替从卡组把1只「救援ACE队」怪兽加入手卡。
local s,id,o=GetID()
-- 初始化效果函数：为这张卡创建并注册①效果的发动效果，设置效果分类为回手牌/检索/涉及墓地移动，类型为魔法卡发动（EFFECT_TYPE_ACTIVATE），自由时点发动，追加同名卡1回合只能发动1次的誓约次数限制，并指定目标判定函数与效果处理函数。
function s.initial_effect(c)
	-- 这个卡名在规则上也当作「救援ACE队」卡使用。这个卡名的卡在1回合只能发动1张。①：从自己墓地把1只「救援ACE队」怪兽加入手卡。自己场上有「救援ACE队 消防栓」存在的场合，也能作为代替从卡组把1只「救援ACE队」怪兽加入手卡。
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
-- 定义“救援ACE队 消防栓”在场判定过滤器：满足卡片编号为37617348且为表侧表示。
function s.checkfilter(c)
	return c:IsCode(37617348) and c:IsFaceup()
end
-- 定义检索目标过滤器：属于「救援ACE队」字段的怪兽、能够加入手牌；当check为真（场上有表侧表示「救援ACE队 消防栓」）时允许选自卡组，否则仅允许选自墓地。
function s.thfilter(c,check)
	return c:IsSetCard(0x18b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and (c:IsLocation(LOCATION_GRAVE) or check)
end
-- 效果的发动目标判定函数：先检查自己场上是否存在表侧表示「救援ACE队 消防栓」，再确认是否存在至少1只可加入手牌的目标怪兽；若满足则效果可发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有表侧表示的「救援ACE队 消防栓」，将结果存入check，作为后续是否允许从卡组检索代替的判定标记。
	local check=Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_ONFIELD,0,1,nil)
	-- 在发动时点确认是否存在合法目标：若存在墓地中的可加入手牌的「救援ACE队」怪兽，或场上有消防栓时存在卡组中的此类怪兽，则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,check) end
end
-- 效果处理函数：再次判定场上是否有「救援ACE队 消防栓」，提示玩家选择要加入手牌的卡，从墓地（场上有消防栓时也可从卡组）选择1只符合条件的「救援ACE队」怪兽加入手牌，并向对方确认该卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查自己场上是否有表侧表示的「救援ACE队 消防栓」，以决定本次检索是否可以使用卡组作为来源。
	local check=Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_ONFIELD,0,1,nil)
	-- 向玩家显示选择提示信息“请选择要加入手牌的卡”，用于Duel.SelectMatchingCard的选择框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 由玩家从自己墓地和卡组（仅当check为真时卡组可选）选择1张满足s.thfilter且不受王家长眠之谷影响的「救援ACE队」怪兽作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,check)
	if g:GetCount()>0 then
		-- 将选中的「救援ACE队」怪兽以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将这次加入手牌的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
