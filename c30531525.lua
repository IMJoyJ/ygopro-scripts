--魔の試着部屋
-- 效果：
-- 支付800基本分。翻开自己卡组最上面4张卡，将其中3星以下的通常怪兽特殊召唤到自己场上，将翻开的其它卡回到卡组。
function c30531525.initial_effect(c)
	-- 创建效果，设置Category为特殊召唤和卡组破坏，类型为发动，代码为自由时点，设置费用、目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c30531525.cost)
	e1:SetTarget(c30531525.target)
	e1:SetOperation(c30531525.activate)
	c:RegisterEffect(e1)
end
-- 支付800基本分
function c30531525.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 让玩家支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 过滤满足条件的通常怪兽（3星以下且可特殊召唤）
function c30531525.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，检查玩家能否特殊召唤、场上是否有空位、是否受63060238效果影响、卡组是否至少有4张牌
function c30531525.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家能否特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp)
		-- 检查玩家场上主怪兽区是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否受63060238效果影响
		and not Duel.IsPlayerAffectedByEffect(tp,63060238)
		-- 检查玩家卡组是否至少有4张牌
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
end
-- 效果处理函数，翻开卡组最上方4张卡，筛选出符合条件的怪兽并特殊召唤
function c30531525.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 确认玩家卡组最上方4张卡
	Duel.ConfirmDecktop(tp,4)
	-- 获取卡组最上方4张卡并筛选出符合条件的怪兽
	local g=Duel.GetDecktopGroup(tp,4):Filter(c30531525.filter,nil,e,tp)
	-- 获取玩家场上主怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if g:GetCount()>0 then
		if ft<=0 then
			-- 将所有符合条件的怪兽送去墓地
			Duel.SendtoGrave(g,REASON_RULE)
		elseif ft>=g:GetCount() then
			-- 将符合条件的怪兽全部特殊召唤到玩家场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,ft,ft,nil)
			-- 将玩家选择的怪兽特殊召唤到玩家场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			g:Sub(sg)
			-- 将剩余未被特殊召唤的怪兽送去墓地
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end
	-- 洗切玩家卡组
	Duel.ShuffleDeck(tp)
end
