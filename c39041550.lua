--騎甲虫スケイル・ボム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有昆虫族怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：对方把场上的怪兽的效果发动时，把自己场上1只昆虫族怪兽解放才能发动。那只怪兽破坏。
function c39041550.initial_effect(c)
	-- ①：自己场上有昆虫族怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39041550,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,39041550)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c39041550.spcon)
	e1:SetTarget(c39041550.sptg)
	e1:SetOperation(c39041550.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方把场上的怪兽的效果发动时，把自己场上1只昆虫族怪兽解放才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,39041551)
	e3:SetCondition(c39041550.condition)
	e3:SetCost(c39041550.cost)
	e3:SetTarget(c39041550.target)
	e3:SetOperation(c39041550.operation)
	c:RegisterEffect(e3)
end
-- 筛选满足表侧表示、昆虫族、控制者为发动玩家tp的怪兽，用于判断召唤·特殊召唤的怪兽是否为己方场上的昆虫族怪兽。
function c39041550.filter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsControler(tp)
end
-- 当这次召唤/特殊召唤成功的怪兽群eg中存在至少1只满足filter条件的昆虫族怪兽时，①效果的发动条件成立。
function c39041550.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39041550.filter,1,nil,tp)
end
-- ①效果发动时的合法性判定：chk==0时，确认自己主怪兽区有空位，且这张卡能够被效果特殊召唤；若满足则允许发动。
function c39041550.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查己方主要怪兽区域是否有可用的空格，以确保能从手卡特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息为“特殊召唤这张卡c”，数量为1，供后续效果检测和相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：确认这张卡仍与该效果关联后，将其从手卡特殊召唤到己方场上。
function c39041550.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动者tp的场上，不检查召唤条件且不解除苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：对方发动了场上的怪兽效果，且发动效果的怪兽仍在场上、与该效果仍有关联，并且是怪兽效果。
function c39041550.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	return tc:IsControler(1-tp) and tc:IsOnField() and tc:IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
end
-- 代价选择用过滤器：选择昆虫族怪兽，且该怪兽由己方控制或处于表侧表示（用于后续选择可解放的昆虫族怪兽）。
function c39041550.cfilter(c,tp)
	return c:IsRace(RACE_INSECT) and (c:IsControler(tp) or c:IsFaceup())
end
-- ②效果发动前支付代价：检查并选择己方场上1只昆虫族怪兽解放，排除发动效果的那只怪兽，解放作为COST。
function c39041550.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时，确认场上存在至少1只符合条件的昆虫族怪兽可解放（排除发动效果的那只怪兽），以判断能否支付代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c39041550.cfilter,1,re:GetHandler(),tp) end
	-- 让玩家tp从符合条件的昆虫族怪兽中选择1只作为解放代价，排除发动效果的那只怪兽。
	local g=Duel.SelectReleaseGroup(tp,c39041550.cfilter,1,1,re:GetHandler(),tp)
	-- 将选择的昆虫族怪兽解放，作为发动②效果所需支付的代价。
	Duel.Release(g,REASON_COST)
end
-- ②效果的目标处理：确认对方发动效果的那只怪兽可被破坏，并设置破坏操作信息；破坏对象由连锁事件确定，不取对象。
function c39041550.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 设置本次连锁的处理信息为“破坏”分类，对象为eg（即对方发动效果的那只怪兽），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- ②效果处理：若发动效果的那只怪兽仍与该效果关联，则将其破坏。
function c39041550.operation(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 以“效果”为破坏原因，破坏eg中的那只怪兽（即对方发动效果的那只怪兽）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
