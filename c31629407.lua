--魔弾の射手 スター
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
-- ②：和这张卡相同纵列有魔法·陷阱卡发动的场合才能发动。除「魔弹射手 斯塔尔」外的1只4星以下的「魔弹」怪兽从卡组守备表示特殊召唤。
function c31629407.initial_effect(c)
	-- 效果原文内容：①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31629407,1))  --"适用「魔弹射手 斯塔尔」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	-- 规则层面作用：设置效果目标为持有「魔弹」属性的魔法·陷阱卡。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetValue(32841045)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：和这张卡相同纵列有魔法·陷阱卡发动的场合才能发动。除「魔弹射手 斯塔尔」外的1只4星以下的「魔弹」怪兽从卡组守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31629407,0))  --"从卡组特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,31629407)
	e3:SetCondition(c31629407.spcon)
	e3:SetTarget(c31629407.sptg)
	e3:SetOperation(c31629407.spop)
	c:RegisterEffect(e3)
end
-- 规则层面作用：判断连锁发动的魔法·陷阱卡是否与该卡在同一纵列。
function c31629407.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():GetColumnGroup():IsContains(re:GetHandler())
end
-- 规则层面作用：过滤满足条件的「魔弹」怪兽（4星以下、非斯塔尔、可特殊召唤）。
function c31629407.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x108) and not c:IsCode(31629407) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 规则层面作用：判断是否满足发动条件（场上有空位且卡组存在符合条件的怪兽）。
function c31629407.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查卡组是否存在符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c31629407.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面作用：设置连锁操作信息为特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：执行特殊召唤操作。
function c31629407.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查场上是否有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：从卡组选择符合条件的怪兽。
	local tg=Duel.SelectMatchingCard(tp,c31629407.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tg then
		-- 规则层面作用：将选中的怪兽以守备表示特殊召唤到场上。
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
