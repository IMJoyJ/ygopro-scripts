--対峙するG
-- 效果：
-- ①：对方从额外卡组把怪兽特殊召唤时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡不受以这张卡为对象的怪兽的效果影响。
function c15721123.initial_effect(c)
	-- ①：对方从额外卡组把怪兽特殊召唤时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡不受以这张卡为对象的怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15721123,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c15721123.spcon)
	e1:SetTarget(c15721123.sptg)
	e1:SetOperation(c15721123.spop)
	c:RegisterEffect(e1)
end
-- 筛选函数：判断怪兽是否由指定玩家tp特殊召唤、且特殊召唤前所在位置为额外卡组；在发动条件中tp被传入对方玩家(1-tp)，用于检测对方是否从额外卡组特殊召唤了怪兽。
function c15721123.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 特殊召唤成功时，若这次特殊召唤成功的怪兽群中至少存在1只对方从额外卡组特殊召唤的怪兽，则满足发动条件。
function c15721123.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15721123.cfilter,1,nil,1-tp)
end
-- 发动时检查：自己场上有可用的主要怪兽区空格，且手牌的这张卡能够被特殊召唤。
function c15721123.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上主要怪兽区是否存在空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本次效果将特殊召唤这张卡的操作信息（分类为特殊召唤，对象为这张卡，数量1），供后续时点与相关卡牌判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将其表侧攻击表示特殊召唤到自己场上；特殊召唤成功后再给这张卡赋予“不受以这张卡为对象的怪兽效果影响”的免疫效果。
function c15721123.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到自己场上（不检查召唤条件与苏生限制），并判断是否特殊召唤成功；成功数大于0才继续赋予免疫效果。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡不受以这张卡为对象的怪兽的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c15721123.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 免疫过滤：不是怪兽效果则不免疫；若效果来源怪兽已以这张卡为对象，或者该效果是带有取对象标志的效果且这张卡与效果相关联，则返回true，使这张卡免疫该效果。
function c15721123.efilter(e,te)
	if not te:IsActiveType(TYPE_MONSTER) then return false end
	local c=e:GetHandler()
	local ec=te:GetHandler()
	if ec:IsHasCardTarget(c) then return true end
	return te:IsHasType(EFFECT_TYPE_ACTIONS) and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and c:IsRelateToEffect(te)
end
