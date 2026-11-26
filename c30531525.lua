--魔の試着部屋
-- 效果：
-- 支付800基本分。翻开自己卡组最上面4张卡，将其中3星以下的通常怪兽特殊召唤到自己场上，将翻开的其它卡回到卡组。
function c30531525.initial_effect(c)
	-- 支付800基本分。翻开自己卡组最上面4张卡，将其中3星以下的通常怪兽特殊召唤到自己场上，将翻开的其它卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c30531525.cost)
	e1:SetTarget(c30531525.target)
	e1:SetOperation(c30531525.activate)
	c:RegisterEffect(e1)
end
-- 支付发动代价：确认己方基本分不少于800后支付800基本分
function c30531525.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前确认己方基本分是否足够支付800点代价
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 让己方支付800点基本分
	Duel.PayLPCost(tp,800)
end
-- 过滤3星以下且可特殊召唤的通常怪兽
function c30531525.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动前确认己方可以特殊召唤、怪兽区有空位、未受「元素英雄 烈焰侠」非融合特召限制影响且卡组至少有4张卡
function c30531525.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方玩家当前是否可以进行特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp)
		-- 检查己方怪兽区是否至少有1个可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方是否未处于「元素英雄 烈焰侠」限制只能特殊召唤融合怪兽的效果影响下
		and not Duel.IsPlayerAffectedByEffect(tp,63060238)
		-- 检查己方卡组剩余卡片数量是否至少有4张
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
end
-- 效果处理：翻开卡组上方4张卡，根据场上空位与「青眼精灵龙」限制将其中3星以下通常怪兽尽量特殊召唤，无法召唤的符合条件怪兽按规则送墓，其余卡片洗回卡组
function c30531525.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 翻开并向双方确认己方卡组最上面的4张卡
	Duel.ConfirmDecktop(tp,4)
	-- 获取卡组最上面4张卡并筛选出其中可特殊召唤的3星以下通常怪兽
	local g=Duel.GetDecktopGroup(tp,4):Filter(c30531525.filter,nil,e,tp)
	-- 获取己方怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if g:GetCount()>0 then
		if ft<=0 then
			-- 当怪兽区已无空位时，将满足条件的怪兽按规则送去墓地
			Duel.SendtoGrave(g,REASON_RULE)
		elseif ft>=g:GetCount() then
			-- 当空位充足时，将所有符合条件的3星以下通常怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 当可用空位少于可特召怪兽数时，向己方发送选择要特殊召唤的怪兽的提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,ft,ft,nil)
			-- 将玩家选出的等同于空位数量的通常怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			g:Sub(sg)
			-- 将未能因空位不足而特殊召唤的其余符合条件通常怪兽按规则送去墓地
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end
	-- 洗切己方卡组，将翻开的其余卡片回到卡组
	Duel.ShuffleDeck(tp)
end
