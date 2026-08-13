--怒気土器
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：从手卡丢弃1只岩石族怪兽才能发动。原本的属性·等级和那只怪兽相同的1只岩石族怪兽从卡组表侧攻击表示或者里侧守备表示特殊召唤。
function c42143067.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：从手卡丢弃1只岩石族怪兽才能发动。原本的属性·等级和那只怪兽相同的1只岩石族怪兽从卡组表侧攻击表示或者里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42143067,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,42143067)
	e1:SetCost(c42143067.spcost)
	e1:SetTarget(c42143067.sptg)
	e1:SetOperation(c42143067.spop)
	c:RegisterEffect(e1)
end
-- 设置标签100表示已执行代价操作，并返回true允许发动；实际丢弃手卡的操作在目标选择时进行。
function c42143067.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤手卡中可作为代价丢弃的岩石族怪兽，并额外确认卡组中存在与该怪兽原本属性·等级相同的岩石族怪兽可特殊召唤。
function c42143067.cfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsDiscardable()
		-- 检查卡组中是否存在与所选手卡怪兽原本属性·等级相同的岩石族怪兽且可特殊召唤。
		and Duel.IsExistingMatchingCard(c42143067.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalAttribute(),c:GetOriginalLevel())
end
-- 过滤卡组中满足条件的怪兽：岩石族、原本属性相同、原本等级相同，并且可以特殊召唤为表侧攻击表示或里侧守备表示。
function c42143067.spfilter(c,e,tp,att,lv)
	return c:IsRace(RACE_ROCK) and c:GetOriginalAttribute()==att and c:GetOriginalLevel()==lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 发动时点的目标处理：检查发动条件，选择要丢弃的手卡岩石族怪兽并送去墓地，同时设置特殊召唤的操作信息。
function c42143067.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己主要怪兽区是否存在可用的空位。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手卡中是否存在可用作代价丢弃的岩石族怪兽，且卡组中存在对应的可特殊召唤目标。
			and Duel.IsExistingMatchingCard(c42143067.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 向玩家提示“请选择要丢弃的手牌”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手卡选择1张满足条件的岩石族怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c42143067.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	e:SetLabelObject(g:GetFirst())
	-- 将选择的卡送去墓地，以代价丢弃的方式处理（REASON_COST+REASON_DISCARD）。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	-- 设置本次连锁的处理信息：将从卡组特殊召唤1只怪兽，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理时：根据之前丢弃的怪兽的原本属性·等级，从卡组选择1只岩石族怪兽特殊召唤；若以里侧守备表示特殊召唤成功，则给对方确认。
function c42143067.spop(e,tp,eg,ep,ev,re,r,rp)
	local gc=e:GetLabelObject()
	-- 效果处理时再次确认自己主要怪兽区是否有空位，若没有则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件（岩石族、原本属性·等级与丢弃怪兽相同）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c42143067.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,gc:GetOriginalAttribute(),gc:GetOriginalLevel())
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧攻击表示或里侧守备表示特殊召唤，并判断是否特殊召唤成功且为里侧表示。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
			-- 将里侧守备表示特殊召唤的怪兽给对方玩家确认。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
