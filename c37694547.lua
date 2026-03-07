--歯車街
-- 效果：
-- ①：只要这张卡在场地区域存在，双方玩家可以把「古代的机械」怪兽召唤的场合需要的解放减少1只。
-- ②：这张卡被破坏送去墓地时才能发动。从自己的手卡·卡组·墓地把1只「古代的机械」怪兽特殊召唤。
function c37694547.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：只要这张卡在场地区域存在，双方玩家可以把「古代的机械」怪兽召唤的场合需要的解放减少1只。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DECREASE_TRIBUTE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	-- 规则层面操作：设置效果目标为手卡区域的「古代的机械」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x7))
	e2:SetValue(c37694547.decval)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：这张卡被破坏送去墓地时才能发动。从自己的手卡·卡组·墓地把1只「古代的机械」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(37694547,0))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c37694547.spcon)
	e3:SetTarget(c37694547.sptg)
	e3:SetOperation(c37694547.spop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：返回值为0x1（表示减少1只解放）和卡号37694547
function c37694547.decval(e,c)
	return 0x1,37694547
end
-- 规则层面操作：判断此卡是否因破坏而送去墓地
function c37694547.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 规则层面操作：过滤满足「古代的机械」种族且可以特殊召唤的怪兽
function c37694547.filter(c,e,tp)
	return c:IsSetCard(0x7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：检测是否满足特殊召唤条件，包括场地上有空位和手卡·卡组·墓地有符合条件的怪兽
function c37694547.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检测玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：检测玩家手卡·卡组·墓地是否存在符合条件的「古代的机械」怪兽
		and Duel.IsExistingMatchingCard(c37694547.filter,tp,0x13,0,1,nil,e,tp) end
	-- 规则层面操作：设置连锁操作信息，表示将要特殊召唤1只怪兽，来源为手卡·卡组·墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 规则层面操作：执行特殊召唤流程，包括提示选择、选取卡片、特殊召唤并洗切卡组
function c37694547.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：向玩家提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择满足条件的「古代的机械」怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c37694547.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 规则层面操作：将玩家卡组洗切
		Duel.ShuffleDeck(tp)
	end
end
