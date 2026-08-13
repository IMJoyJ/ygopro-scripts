--ドラゴンメイド・ハスキー
-- 效果：
-- 「半龙女仆」怪兽＋龙族怪兽
-- ①：自己·对方的准备阶段，以自己场上1只其他的「半龙女仆」怪兽为对象才能发动。比那只怪兽等级高1星或低1星的1只「半龙女仆」怪兽从自己的手卡·墓地守备表示特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，自己场上的表侧表示的龙族怪兽回到自己手卡时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c41232647.initial_effect(c)
	-- 为这张卡添加融合召唤手续，素材为1只「半龙女仆」怪兽和1只龙族怪兽，使其能作为融合素材怪兽进行融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x133),aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),true)
	c:EnableReviveLimit()
	-- 对应效果原文：①：自己·对方的准备阶段，以自己场上1只其他的「半龙女仆」怪兽为对象才能发动。比那只怪兽等级高1星或低1星的1只「半龙女仆」怪兽从自己的手卡·墓地守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41232647,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c41232647.sptg)
	e1:SetOperation(c41232647.spop)
	c:RegisterEffect(e1)
	-- 对应效果原文：②：这张卡在怪兽区域存在的状态，自己场上的表侧表示的龙族怪兽回到自己手卡时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41232647,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c41232647.descon)
	e3:SetTarget(c41232647.destg)
	e3:SetOperation(c41232647.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数：我方场上可作为对象的「半龙女仆」怪兽必须表侧表示、等级大于0，且在手卡·墓地存在等级与之相差1且可特殊召唤的「半龙女仆」怪兽。
function c41232647.spfilter1(c,e,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsFaceup() and c:IsSetCard(0x133)
		-- 额外筛选：确认手卡·墓地中是否存在与对象怪兽等级差为1且满足特殊召唤条件的「半龙女仆」怪兽。
		and Duel.IsExistingMatchingCard(c41232647.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,lv)
end
-- 过滤函数：手卡·墓地的「半龙女仆」怪兽必须等级大于0、与指定等级相差1，并且能够以表侧守备表示特殊召唤。
function c41232647.spfilter2(c,e,tp,clv)
	local lv=c:GetLevel()
	return lv>0 and c:IsSetCard(0x133) and math.abs(clv-lv)==1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的发动条件和取对象处理：先校验非连锁时可用怪兽区域和目标怪兽存在，再在连锁处理时校验指定对象必须是自己场上表侧表示的其他「半龙女仆」怪兽。
function c41232647.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c41232647.spfilter1(chkc,e,tp) and chkc~=c end
	-- 非连锁发动时，检查自己场上是否仍有可用的怪兽区域，若无则无法发动特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且场上必须存在能作为对象的本方表侧「半龙女仆」怪兽（且不是此卡自身），否则不能发动。
		and Duel.IsExistingTarget(c41232647.spfilter1,tp,LOCATION_MZONE,0,1,c,e,tp) end
	-- 发起选择表侧表示卡片的提示，让玩家知道接下来要选择的对象种类。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只其他符合条件的「半龙女仆」怪兽，将其设为效果对象。
	Duel.SelectTarget(tp,c41232647.spfilter1,tp,LOCATION_MZONE,0,1,1,c,e,tp)
	-- 设置本次效果处理时将进行从手卡·墓地特殊召唤1只怪兽的操作信息，用于后续连锁相关的检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：若对象怪兽仍与效果关联且表侧表示，则从手卡·墓地选择1只等级差1的「半龙女仆」怪兽守备表示特殊召唤到己方场上。
function c41232647.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上仍有可用怪兽区域，否则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取出发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 发起选择特殊召唤卡片的提示，让玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己手卡·墓地选出1只等级比对象高1或低1、可表侧守备特殊召唤的「半龙女仆」怪兽；过滤时考虑王家长眠之谷的影响。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41232647.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetLevel())
		if g:GetCount()>0 then
			-- 将选出的「半龙女仆」怪兽以表侧守备表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
-- 过滤函数：判定返回手卡的卡是否曾在我方场上表侧表示，且原控制者为我方、原来位置为怪兽区域、原种族为龙族。
function c41232647.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousRaceOnField(),RACE_DRAGON)~=0 and c:IsControler(tp)
end
-- 触发条件：回到手卡的卡中只要存在1张满足上述条件的我方龙族怪兽，就满足本效果的发动条件。
function c41232647.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c41232647.cfilter,1,nil,tp)
end
-- 破坏效果的发动条件与取对象处理：需要选择对方场上1只怪兽为对象；非连锁时检查对方场上有怪兽可指定，连锁处理时校验指定对象为对方场上怪兽。
function c41232647.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 非连锁发动时，检查对方场上是否存在至少1只可被选为对象的怪兽，若没有则无法发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 发起选择要破坏的卡片的提示，让玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次效果将破坏1只对象怪兽的操作信息，供其他卡片的诱发检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：若目标怪兽仍与效果关联，则将其破坏。
function c41232647.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果发动时选择的对方怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
