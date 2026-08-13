--黒竜の雛
-- 效果：
-- 把自己场上表侧表示存在的这张卡送去墓地才能发动。从手卡把1只「真红眼黑龙」特殊召唤。
function c36262024.initial_effect(c)
	-- 把自己场上表侧表示存在的这张卡送去墓地才能发动。从手卡把1只「真红眼黑龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36262024,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c36262024.spcost)
	e1:SetTarget(c36262024.sptg)
	e1:SetOperation(c36262024.spop)
	c:RegisterEffect(e1)
end
-- 费用处理函数：在发动时先检查此卡能否作为代价送去墓地；若可以，则将自身送去墓地作为发动代价。
function c36262024.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 实际支付代价：将这张卡从场上送去墓地（REASON_COST表示作为代价）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选函数：用于从手牌中选择卡号为74677422的「真红眼黑龙」，并确认它能否被当前效果特殊召唤。
function c36262024.filter(c,e,tp)
	return c:IsCode(74677422) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标判定函数：在发动阶段确认自己场上是否有可用怪兽区域、手牌是否存在符合条件的「真红眼黑龙」，并设置本次特殊召唤的操作信息。
function c36262024.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域（数量大于-1，即至少存在可特殊召唤的空间）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手牌中是否存在至少1张满足筛选条件的「真红眼黑龙」。
		and Duel.IsExistingMatchingCard(c36262024.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次特殊召唤的处理对象来自手牌，数量为1，持有者为发动玩家。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：在发动被允许后，先确认场上仍有可用区域，然后让玩家选择1张手牌中的「真红眼黑龙」并特殊召唤。
function c36262024.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上怪兽区域没有空位（<=0），则效果处理直接终止，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选出1张符合filter条件（卡号74677422且可特殊召唤）的卡。
	local g=Duel.SelectMatchingCard(tp,c36262024.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的卡以表侧表示形式特殊召唤到其持有者（即当前玩家）的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
