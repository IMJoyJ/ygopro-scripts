--神聖なる魔術師
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡反转的场合，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。那之后，可以从卡组把1只「圣魔术师」或「神圣魔术师」里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 注册该卡反转时将墓地魔法卡加入手卡，并可从卡组里侧特殊召唤「圣魔术师」或「神圣魔术师」的效果
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡反转的场合，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。那之后，可以从卡组把1只「圣魔术师」或「神圣魔术师」里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以加入手牌的魔法卡
function s.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果发动的目标选择与检测，确认墓地是否存在可加入手牌的魔法卡并选择为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 在发动阶段检测自己墓地是否存在可以加入手牌的魔法卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张魔法卡作为效果的对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息，表示该效果包含将选中的1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤卡组中可以里侧守备表示特殊召唤的「圣魔术师」或「神圣魔术师」
function s.spfilter(c,e,tp)
	return c:IsCode(31560081,id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果处理的核心逻辑，将对象卡加入手牌，并根据玩家选择决定是否从卡组里侧守备表示特殊召唤「圣魔术师」或「神圣魔术师」
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的作为对象的魔法卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍与效果相关联，并将其加入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) then
		-- 获取卡组中满足特殊召唤条件的「圣魔术师」或「神圣魔术师」的卡片组
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 判断自己场上是否有空余的怪兽区域，且卡组中存在可特殊召唤的怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0
			-- 询问玩家是否选择进行特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否从卡组特殊召唤？"
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果处理，使后续的特殊召唤处理与加入手牌不视为同时进行
			Duel.BreakEffect()
			-- 将选择的怪兽以里侧守备表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			-- 让对方玩家确认被里侧特殊召唤的怪兽
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
