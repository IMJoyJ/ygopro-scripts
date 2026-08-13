--魔の試着部屋
-- 效果：
-- 支付800基本分。翻开自己卡组最上面4张卡，将其中3星以下的通常怪兽特殊召唤到自己场上，将翻开的其它卡回到卡组。
function c30531525.initial_effect(c)
	-- 支付800基本分。翻开自己卡组最上面4张卡，将其中3星以下的通常怪兽特殊召唤到自己场上，将翻开的其它卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c30531525.cost)
	e1:SetTarget(c30531525.target)
	e1:SetOperation(c30531525.activate)
	c:RegisterEffect(e1)
end
-- 定义该卡的代价函数：支付800基本分。
function c30531525.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为代价检查阶段，则判定玩家是否能支付800基本分。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际支付800基本分。
	Duel.PayLPCost(tp,800)
end
-- 定义筛选函数：选出翻开卡中3星以下的通常怪兽，且该怪兽能够被效果特殊召唤。
function c30531525.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动条件：自己可以进行特殊召唤、主要怪兽区有空位、未受「元素英雄 烈焰侠」效果影响、卡组至少有4张卡。
function c30531525.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己当前是否允许进行特殊召唤。
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp)
		-- 检查自己场上主要怪兽区是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否受63060238（元素英雄 烈焰侠）效果影响（即是否处于只能特殊召唤融合怪兽的自肃状态）。
		and not Duel.IsPlayerAffectedByEffect(tp,63060238)
		-- 检查自己卡组最上方是否至少有4张卡（卡组数量大于3）。
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
end
-- 定义效果处理函数：翻开卡组顶4张，筛选出可特殊召唤的3星以下通常怪兽，根据可用怪兽区域数量进行特殊召唤，剩余符合条件的怪兽送去墓地，最后洗切卡组。
function c30531525.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 翻开自己卡组最上面4张卡，让对方确认。
	Duel.ConfirmDecktop(tp,4)
	-- 获取卡组最上面4张卡，并筛选出其中3星以下、可特殊召唤的通常怪兽。
	local g=Duel.GetDecktopGroup(tp,4):Filter(c30531525.filter,nil,e,tp)
	-- 获取自己场上主要怪兽区的可用空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if g:GetCount()>0 then
		if ft<=0 then
			-- 将因无空位或未被选中而无法特殊召唤的剩余符合条件的怪兽以规则原因送去墓地。
			Duel.SendtoGrave(g,REASON_RULE)
		elseif ft>=g:GetCount() then
			-- 将筛选出的所有符合条件的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,ft,ft,nil)
			-- 将玩家选择出来的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			g:Sub(sg)
			-- 将未被选择特殊召唤的剩余符合条件的怪兽以规则原因送去墓地。
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end
	-- 洗切自己卡组，将翻开的卡返回卡组并洗牌。
	Duel.ShuffleDeck(tp)
end
