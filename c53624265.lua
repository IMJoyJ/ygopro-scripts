--破械童子ラキア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张卡为对象才能发动。那张卡破坏。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。这个效果在对方回合也能发动。
-- ②：场上的这张卡被战斗或者「破械童子 罗鬼刹」以外的卡的效果破坏的场合才能发动。从手卡·卡组把「破械童子 罗鬼刹」以外的1只「破械」怪兽特殊召唤。
function c53624265.initial_effect(c)
	-- ①：以自己场上1张卡为对象才能发动。那张卡破坏。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53624265,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,53624265)
	e1:SetTarget(c53624265.destg)
	e1:SetOperation(c53624265.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗或者「破械童子 罗鬼刹」以外的卡的效果破坏的场合才能发动。从手卡·卡组把「破械童子 罗鬼刹」以外的1只「破械」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53624265,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,53624266)
	e2:SetCondition(c53624265.spcon)
	e2:SetTarget(c53624265.sptg)
	e2:SetOperation(c53624265.spop)
	c:RegisterEffect(e2)
end
-- 选择场上1张卡作为对象
function c53624265.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) end
	-- 检查场上是否存在1张自己控制的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张自己控制的卡作为对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置效果处理信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果的发动，破坏对象卡并设置不能特殊召唤恶魔族以外怪兽的效果
function c53624265.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
	-- 创建一个持续到回合结束的不能特殊召唤非恶魔族怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c53624265.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非恶魔族怪兽
function c53624265.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- 判断此卡是否因战斗或非罗鬼刹的效果被破坏
function c53624265.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(53624265))) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，筛选出「破械」怪兽且不是罗鬼刹的卡
function c53624265.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(53624265) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的处理信息
function c53624265.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在符合条件的「破械」怪兽
		and Duel.IsExistingMatchingCard(c53624265.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，确定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 处理特殊召唤效果，从手卡或卡组选择1只「破械」怪兽特殊召唤
function c53624265.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只符合条件的「破械」怪兽
	local g=Duel.SelectMatchingCard(tp,c53624265.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
