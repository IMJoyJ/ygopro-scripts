--森の聖獣 キティテール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以自己墓地1只兽族·兽战士族·鸟兽族·昆虫族·植物族怪兽为对象才能发动。原本种族和那只怪兽相同的1只怪兽从卡组送去墓地。
-- ②：这张卡被对方破坏的场合才能发动。从卡组把「森之圣兽 红毛苋小猫」以外的1只兽族·兽战士族·鸟兽族·昆虫族·植物族怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：①召唤·特殊召唤成功时的诱发效果，②被对方破坏时的诱发效果。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，以自己墓地1只兽族·兽战士族·鸟兽族·昆虫族·植物族怪兽为对象才能发动。原本种族和那只怪兽相同的1只怪兽从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被对方破坏的场合才能发动。从卡组把「森之圣兽 红毛苋小猫」以外的1只兽族·兽战士族·鸟兽族·昆虫族·植物族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己墓地的兽族·兽战士族·鸟兽族·昆虫族·植物族怪兽，且卡组中存在与其原本种族相同的怪兽。
function s.cfilter(c,tp)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST+RACE_INSECT+RACE_PLANT)
		-- 检查卡组中是否存在至少1张与该墓地怪兽原本种族相同的怪兽。
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤条件：卡组中与目标怪兽原本种族相同的怪兽。
function s.tgfilter(c,tc)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and c:GetOriginalRace()&tc:GetOriginalRace()~=0
end
-- ①号效果的发动准备与目标选择。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.cfilter(chkc,tp) end
	-- 检查自己墓地是否存在满足条件的怪兽作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置效果处理信息：从卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的实际处理：将与对象怪兽原本种族相同的1只卡组怪兽送去墓地。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的墓地怪兽对象。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1只与对象怪兽原本种族相同的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②号效果的发动条件：这张卡被对方破坏，且原本控制权属于自己。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤条件：卡组中除「森之圣兽 红毛苋小猫」以外的兽族·兽战士族·鸟兽族·昆虫族·植物族怪兽。
function s.thfilter(c)
	return c:IsAbleToHand() and not c:IsCode(id)
		and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST+RACE_INSECT+RACE_PLANT)
end
-- ②号效果的发动准备。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的实际处理：从卡组将1只符合条件的怪兽加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽因效果加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
