--破械童子ラキア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张卡为对象才能发动。那张卡破坏。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。这个效果在对方回合也能发动。
-- ②：场上的这张卡被战斗或者「破械童子 罗鬼刹」以外的卡的效果破坏的场合才能发动。从手卡·卡组把「破械童子 罗鬼刹」以外的1只「破械」怪兽特殊召唤。
function c53624265.initial_effect(c)
	-- ①：自己·对方回合，以自己场上1张卡为对象才能发动。那张卡破坏。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
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
-- ①效果的发动阶段：检查能否以自己场上1张卡为对象，选择1张自己场上的卡作为对象，并登记破坏效果的操作信息。
function c53624265.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) end
	-- 发动条件判定：确认自己场上是否存在至少1张可以作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 让玩家选择要破坏的卡，显示‘请选择要破坏的卡’的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1张卡作为效果对象，并自动与当前连锁建立联系。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 向系统登记本次操作属于破坏效果，处理时对选择的1张卡进行破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：破坏仍与效果关联的对象卡，然后给发动玩家附加直到回合结束时只能特殊召唤恶魔族怪兽的自肃。
function c53624265.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时仍关联的对象卡（即发动时选择的1张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
	-- ①：这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。②：场上的这张卡被战斗或者「破械童子 罗鬼刹」以外的卡的效果破坏的场合才能发动。从手卡·卡组把「破械童子 罗鬼刹」以外的1只「破械」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c53624265.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到当前玩家，使该玩家在本回合结束前不能特殊召唤非恶魔族怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的限制条件：只要怪兽不是恶魔族，就禁止特殊召唤。
function c53624265.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- ②效果的发动条件：这张卡因战斗破坏，或因「破械童子 罗鬼刹」以外的卡的效果破坏，且破坏前位于场上。
function c53624265.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(53624265))) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果可特殊召唤的怪兽条件：卡名包含「破械」字段、不是「破械童子 罗鬼刹」本身，并且可以被正常特殊召唤。
function c53624265.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(53624265) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动判定：自己场上有可用的主要怪兽区空位，并且手卡·卡组中存在符合条件的「破械」怪兽。
function c53624265.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否有可用的主要怪兽区空位，没有空位则无法特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定手卡·卡组中是否存在至少1只满足特殊召唤条件的「破械」怪兽。
		and Duel.IsExistingMatchingCard(c53624265.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次操作信息：将从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：在仍有可用怪兽区空位时，从手卡·卡组选择1只符合条件的「破械」怪兽表侧表示特殊召唤。
function c53624265.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时若自己场上没有可用的主要怪兽区空位，则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 让玩家选择要特殊召唤的卡，显示‘请选择要特殊召唤的卡’的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选出1只满足条件的「破械」怪兽。
	local g=Duel.SelectMatchingCard(tp,c53624265.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
