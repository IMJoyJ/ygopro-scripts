--魔導冥士 ラモール
-- 效果：
-- 这张卡召唤·特殊召唤成功时才能发动。自己墓地的名字带有「魔导书」的魔法卡种类的以下效果适用。「魔导冥士 拉莫尔」的效果1回合只能使用1次。
-- ●3种类以上：这张卡的攻击力上升600。
-- ●4种类以上：从卡组把1张名字带有「魔导书」的魔法卡加入手卡。
-- ●5种类以上：从卡组把1只魔法师族·暗属性·5星以上的怪兽特殊召唤。
function c9560338.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时才能发动。自己墓地的名字带有「魔导书」的魔法卡种类的以下效果适用。「魔导冥士 拉莫尔」的效果1回合只能使用1次。●3种类以上：这张卡的攻击力上升600。●4种类以上：从卡组把1张名字带有「魔导书」的魔法卡加入手卡。●5种类以上：从卡组把1只魔法师族·暗属性·5星以上的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9560338,0))  --"多种类效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,9560338)
	e1:SetTarget(c9560338.efftg)
	e1:SetOperation(c9560338.effop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地的名字带有「魔导书」的魔法卡
function c9560338.cfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL)
end
-- 过滤条件：卡组中名字带有「魔导书」且可以加入手牌的魔法卡
function c9560338.filter1(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 过滤条件：卡组中5星以上、暗属性、魔法师族且可以特殊召唤的怪兽
function c9560338.filter2(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标确认与操作信息设置：检查墓地「魔导书」魔法卡种类是否在3种以上，并根据种类数量（4种或5种以上）设置对应的检索或特殊召唤操作信息
function c9560338.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中所有名字带有「魔导书」的魔法卡
	local g=Duel.GetMatchingGroup(c9560338.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
	local ct=g:GetClassCount(Card.GetCode)
	if ct>=4 then
		-- 设置操作信息：从卡组将1张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	if ct>=5 then
		-- 设置操作信息：从卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理：根据自己墓地「魔导书」魔法卡的种类数量，依次适用攻击力上升、检索「魔导书」魔法卡、特殊召唤魔法师族·暗属性·5星以上怪兽的效果
function c9560338.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己墓地中所有名字带有「魔导书」的魔法卡
	local g=Duel.GetMatchingGroup(c9560338.cfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if ct>=3 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- ●3种类以上：这张卡的攻击力上升600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	if ct>=4 then
		-- 中断当前效果处理，使后续效果不与前一个效果同时处理（用于区分时点）
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足条件的「魔导书」魔法卡
		local g=Duel.SelectMatchingCard(tp,c9560338.filter1,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡因效果加入玩家手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 判断墓地「魔导书」魔法卡种类是否在5种以上，且自己场上有可用的怪兽区域
	if ct>=5 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 中断当前效果处理，使后续效果不与前一个效果同时处理（用于区分时点）
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只满足条件的魔法师族·暗属性·5星以上的怪兽
		local g=Duel.SelectMatchingCard(tp,c9560338.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
