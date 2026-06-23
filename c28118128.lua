--子狸たんたん
-- 效果：
-- 反转：从卡组把「子狸 当当」以外的1只兽族·2星怪兽特殊召唤。
function c28118128.initial_effect(c)
	-- 反转效果：从卡组把「子狸 当当」以外的1只兽族·2星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28118128,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c28118128.target)
	e1:SetOperation(c28118128.operation)
	c:RegisterEffect(e1)
end
-- 设置效果处理时的连锁操作信息，指定将要特殊召唤1只怪兽
function c28118128.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为特殊召唤类别，目标为玩家tp卡组中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：筛选出不是「子狸 当当」、等级为2、种族为兽族且可以被特殊召唤的怪兽
function c28118128.filter(c,e,tp)
	return not c:IsCode(28118128) and c:IsLevel(2) and c:IsRace(RACE_BEAST)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：检查场上是否有空位，若有则提示选择并特殊召唤符合条件的怪兽
function c28118128.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有空位，若无则直接返回不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家卡组中选择满足条件的1只怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,c28118128.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
