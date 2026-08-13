--サイコ・フィール・ゾーン
-- 效果：
-- 让从游戏中除外的自己1只念动力族的调整和1只调整以外的念动力族怪兽回到墓地，和那个等级合计相同等级的1只念动力族的同调怪兽从额外卡组表侧守备表示特殊召唤。
function c11047543.initial_effect(c)
	-- 让从游戏中除外的自己1只念动力族的调整和1只调整以外的念动力族怪兽回到墓地，和那个等级合计相同等级的1只念动力族的同调怪兽从额外卡组表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11047543,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c11047543.target)
	e1:SetOperation(c11047543.operation)
	c:RegisterEffect(e1)
end
-- 筛选可作为对象的除外区念动力族调整怪兽：需表侧表示、念动力族、调整，且除外区存在另一只满足条件的非调整念动力族怪兽（由filter2判定）。
function c11047543.filter1(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_TUNER)
		-- 且存在另一只除外的念动力族非调整怪兽，能与该调整的等级合计后作为同调怪兽的等级依据。
		and Duel.IsExistingTarget(c11047543.filter2,tp,LOCATION_REMOVED,0,1,nil,e,tp,c:GetLevel())
end
-- 筛选可作为对象的除外区念动力族非调整怪兽：需等级大于0、表侧表示、念动力族、非调整，且额外卡组存在等级等于该怪兽等级与已选调整等级之和的念动力同调怪兽可特殊召唤。
function c11047543.filter2(c,e,tp,lv)
	local clv=c:GetLevel()
	return clv>0 and c:IsFaceup() and c:IsRace(RACE_PSYCHO) and not c:IsType(TYPE_TUNER)
		-- 且额外卡组存在等级等于该非调整怪兽等级与已选调整等级合计值的念动力同调怪兽可特殊召唤。
		and Duel.IsExistingMatchingCard(c11047543.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv+clv)
end
-- 筛选可特殊召唤的额外卡组念动力族同调怪兽：需等级等于指定等级、满足特殊召唤条件（表侧守备表示），且存在可用的额外怪兽区域。
function c11047543.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv)
		-- 且该同调怪兽能以表侧守备表示被特殊召唤，同时自己场上存在可用的额外怪兽区域。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 发动时：确认存在符合条件的对象；让玩家选择1只除外区的念动力族调整，再选择1只除外区的念动力族非调整，并将其设为效果对象；同时设置将两张卡送去墓地以及从额外卡组特殊召唤1只同调怪兽的操作信息。
function c11047543.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：若为效果发动确认（chk=0），则检查除外区是否存在至少1只满足filter1的念动力族调整怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c11047543.filter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从除外区选择1只满足filter1的念动力族调整怪兽，并将其设为效果对象。
	local g1=Duel.SelectTarget(tp,c11047543.filter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从除外区选择1只满足filter2的念动力族非调整怪兽（其等级与已选调整的等级合计作为后续同调怪兽的等级），并将其设为效果对象。
	local g2=Duel.SelectTarget(tp,c11047543.filter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,g1:GetFirst():GetLevel())
	g1:Merge(g2)
	-- 设置操作信息：将选择的两只怪兽送去墓地（数量为2）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,2,0,0)
	-- 设置操作信息：从额外卡组特殊召唤1只念动力族同调怪兽（数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：取得效果对象的两只怪兽，将它们送去墓地（若都成功），然后根据两只怪兽等级合计，从额外卡组选择1只等级相同的念动力同调怪兽以表侧守备表示特殊召唤。
function c11047543.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中与本效果相关联的对象卡（即发动时选择的两只怪兽）。
	local g=Duel.GetTargetsRelateToChain()
	-- 若对象数量不为2，或未成功将两张卡送去墓地，则效果不处理。
	if g:GetCount()~=2 or Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)~=2 then return end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	-- 从额外卡组获取所有满足spfilter的念动力族同调怪兽，其等级为两只对象怪兽的等级合计。
	local sg=Duel.GetMatchingGroup(c11047543.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,tc1:GetLevel()+tc2:GetLevel())
	if sg:GetCount()==0 then return end
	-- 中断效果处理，使之后处理的特殊召唤不视为与前面的送墓同时处理（防止错过时点）。
	Duel.BreakEffect()
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local ssg=sg:Select(tp,1,1,nil)
	-- 将选择的同调怪兽以表侧守备表示特殊召唤到自己的场上。
	Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
