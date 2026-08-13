--サイバー・ドラゴン・ネクステア
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「电子龙」使用。
-- ②：从手卡丢弃1只其他怪兽才能发动。这张卡从手卡特殊召唤。
-- ③：这张卡召唤·特殊召唤的场合，以攻击力或守备力是2100的自己墓地1只机械族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
function c1142880.initial_effect(c)
	-- 为这张卡注册在场上·墓地时卡名当作「电子龙」（70095154）使用的永续效果，对应①效果。
	aux.EnableChangeCode(c,70095154,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：从手卡丢弃1只其他怪兽才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1142880,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,1142880)
	e2:SetCost(c1142880.cost)
	e2:SetTarget(c1142880.sptg)
	e2:SetOperation(c1142880.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡召唤·特殊召唤的场合，以攻击力或守备力是2100的自己墓地1只机械族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1142880,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,1142881)
	e3:SetTarget(c1142880.sptg2)
	e3:SetOperation(c1142880.spop2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 代价筛选条件：手卡中的怪兽卡且可以被丢弃（用于作为②效果的代价丢弃的“其他怪兽”）。
function c1142880.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- ②效果的代价支付函数：检查手卡是否存在1只可以作为代价丢弃的“其他怪兽”，若存在则丢弃1只（REASON_COST+REASON_DISCARD）作为发动代价。
function c1142880.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查手卡是否存在1只满足条件的“其他怪兽”（不包含效果持有者自身）可以作为代价丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(c1142880.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡丢弃1只其他怪兽（REASON_COST+REASON_DISCARD）作为发动代价。
	Duel.DiscardHand(tp,c1142880.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ②效果发动条件与目标选择：自己主要怪兽区有空位，且这张卡自身可以被特殊召唤，满足条件后登记特殊召唤操作信息。
function c1142880.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有空位，用于判断能否从手卡特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将这次特殊召唤操作信息登记为对这张卡进行的特殊召唤，供其他连锁效果（如召唤反应类效果）判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c1142880.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡从手卡表侧攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 墓地怪兽筛选条件：机械族、攻击力或守备力为2100，且可以被特殊召唤，用于③效果的对象选择。
function c1142880.filter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and (c:IsAttack(2100) or c:IsDefense(2100)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果发动条件与目标选择：自己场上有特殊召唤空位，且墓地存在满足条件的机械族怪兽，从中选择1只作为对象。
function c1142880.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1142880.filter(chkc,e,tp) end
	-- 确认自己场上有可以特殊召唤怪兽的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在1只满足条件的机械族怪兽可以作为③效果的对象。
		and Duel.IsExistingTarget(c1142880.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的机械族怪兽作为③效果的对象（取对象）。
	local g=Duel.SelectTarget(tp,c1142880.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将这次特殊召唤操作信息登记为特殊召唤对象g，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：将对象怪兽特殊召唤，并给自己附加“直到回合结束只能特殊召唤机械族怪兽”的自肃效果。
function c1142880.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得③效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽从墓地特殊召唤到自己的主要怪兽区（表侧表示）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c1142880.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤机械族以外的怪兽”的自肃效果注册到当前玩家，直到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的判定条件：不是机械族怪兽时不允许特殊召唤。
function c1142880.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
