--マシンナーズ・ピースキーパー
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只机械族怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ②：场上的这张卡被破坏送去墓地时才能发动。从卡组把1只同盟怪兽加入手卡。
function c78349103.initial_effect(c)
	-- 赋予该卡同盟怪兽的标准机制（装备、代破、特召等效果）。
	aux.EnableUnionAttribute(c,c78349103.filter)
	-- ②：场上的这张卡被破坏送去墓地时才能发动。从卡组把1只同盟怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(78349103,2))  --"检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c78349103.scon)
	e5:SetTarget(c78349103.stg)
	e5:SetOperation(c78349103.sop)
	c:RegisterEffect(e5)
end
c78349103.has_text_type=TYPE_UNION
-- 过滤函数：限制只能装备给机械族怪兽。
function c78349103.filter(c)
	return c:IsRace(RACE_MACHINE)
end
-- 过滤函数：检索卡组中可加入手卡的同盟怪兽。
function c78349103.sfilter(c)
	return c:IsType(TYPE_UNION) and c:IsAbleToHand()
end
-- 条件判断：场上的这张卡被破坏送去墓地。
function c78349103.scon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 效果发动的准备：检查卡组中是否存在可检索的同盟怪兽，并设置检索的操作信息。
function c78349103.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可加入手卡的同盟怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c78349103.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组中的1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只同盟怪兽加入手卡并给对方确认。
function c78349103.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的同盟怪兽。
	local g=Duel.SelectMatchingCard(tp,c78349103.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的同盟怪兽因效果加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
