--ジュラック・メテオ
-- 效果：
-- 「朱罗纪」调整＋调整以外的恐龙族怪兽2只以上
-- ①：这张卡同调召唤的场合发动。场上的卡全部破坏。那之后，可以从自己墓地把1只调整特殊召唤。
function c17548456.initial_effect(c)
	-- 添加同调召唤手续，要求1只满足「朱罗纪」调整，以及2只以上满足恐龙族且非调整的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x22),aux.NonTuner(Card.IsRace,RACE_DINOSAUR),2)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合发动。场上的卡全部破坏。那之后，可以从自己墓地把1只调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17548456,0))  --"破坏并特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c17548456.descon)
	e1:SetTarget(c17548456.destg)
	e1:SetOperation(c17548456.desop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否为同调召唤成功
function c17548456.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果处理时要破坏场上所有卡
function c17548456.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定要破坏的卡数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义墓地特殊召唤的过滤条件，要求是调整且可特殊召唤
function c17548456.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行效果处理，先破坏场上所有卡，再判断是否满足特殊召唤条件并询问玩家是否发动
function c17548456.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 判断破坏成功且墓地存在满足条件的调整，且玩家选择发动特殊召唤
		if Duel.Destroy(g,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c17548456.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(17548456,1)) then  --"是否要特殊召唤一只调整？"
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 获取满足特殊召唤条件的墓地调整集合
			local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c17548456.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sp=sg:Select(tp,1,1,nil)
			-- 将选中的调整特殊召唤到场上
			Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
