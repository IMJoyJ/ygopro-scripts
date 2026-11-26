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
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
-- 过滤卡名带有「魔导书」的魔法卡，用于统计墓地种类数
function c9560338.cfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL)
end
-- 过滤卡组中卡名带有「魔导书」且可加入手卡的魔法卡
function c9560338.filter1(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 过滤卡组中魔法师族·暗属性·5星以上且可特殊召唤的怪兽
function c9560338.filter2(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动前确认己方墓地「魔导书」魔法卡至少有3种，并根据当前种类数是否达到4或5分别登记检索与特召操作信息
function c9560338.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方墓地中所有「魔导书」魔法卡
	local g=Duel.GetMatchingGroup(c9560338.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
	local ct=g:GetClassCount(Card.GetCode)
	if ct>=4 then
		-- 当墓地「魔导书」魔法卡达到4种类以上时，登记从卡组加入手卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	if ct>=5 then
		-- 当墓地「魔导书」魔法卡达到5种类以上时，登记从卡组特殊召唤怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理：按效果处理时己方墓地「魔导书」魔法卡的种类数，依次适用3种以上自身加攻600、4种以上检索「魔导书」魔法、5种以上卡组特召5星以上暗属性魔法师族怪兽
function c9560338.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时重新获取己方墓地中所有「魔导书」魔法卡以计算最新种类数
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
		-- 插入效果处理间断，使加攻与后续检索「魔导书」魔法卡视为不同时处理
		Duel.BreakEffect()
		-- 向己方发送从卡组选择要加入手卡的「魔导书」魔法卡的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让己方从卡组选择1张「魔导书」魔法卡
		local g=Duel.SelectMatchingCard(tp,c9560338.filter1,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的「魔导书」魔法卡以效果加入己方手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的「魔导书」魔法卡进行确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 若墓地「魔导书」魔法卡种类达到5种以上且己方怪兽区有空位，则执行特殊召唤分支
	if ct>=5 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 插入效果处理间断，使前序处理与后续卡组特殊召唤视为不同时处理
		Duel.BreakEffect()
		-- 向己方发送从卡组选择要特殊召唤的怪兽的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从卡组选择1只魔法师族·暗属性·5星以上的怪兽
		local g=Duel.SelectMatchingCard(tp,c9560338.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
