--ドラゴンメイド・ハスキー
-- 效果：
-- 「半龙女仆」怪兽＋龙族怪兽
-- ①：自己·对方的准备阶段，以自己场上1只其他的「半龙女仆」怪兽为对象才能发动。比那只怪兽等级高1星或低1星的1只「半龙女仆」怪兽从自己的手卡·墓地守备表示特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，自己场上的表侧表示的龙族怪兽回到自己手卡时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c41232647.initial_effect(c)
	-- 为卡片添加融合召唤手续，要求一只满足「半龙女仆」系列的怪兽和一只龙族怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x133),aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),true)
	c:EnableReviveLimit()
	-- ①：自己·对方的准备阶段，以自己场上1只其他的「半龙女仆」怪兽为对象才能发动。比那只怪兽等级高1星或低1星的1只「半龙女仆」怪兽从自己的手卡·墓地守备表示特殊召唤。
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
	-- ②：这张卡在怪兽区域存在的状态，自己场上的表侧表示的龙族怪兽回到自己手卡时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
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
-- 过滤函数，用于判断是否满足条件：该怪兽为表侧表示、等级大于0、属于「半龙女仆」系列，并且存在满足条件的特殊召唤目标
function c41232647.spfilter1(c,e,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsFaceup() and c:IsSetCard(0x133)
		-- 检查是否存在满足条件的「半龙女仆」怪兽（等级相差1）从手牌或墓地特殊召唤
		and Duel.IsExistingMatchingCard(c41232647.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,lv)
end
-- 过滤函数，用于判断是否满足条件：该怪兽为表侧表示、等级大于0、属于「半龙女仆」系列、等级与目标怪兽等级相差1、可以特殊召唤到场上
function c41232647.spfilter2(c,e,tp,clv)
	local lv=c:GetLevel()
	return lv>0 and c:IsSetCard(0x133) and math.abs(clv-lv)==1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果目标函数，检查是否满足条件：选择自己场上的表侧表示的「半龙女仆」怪兽作为目标
function c41232647.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c41232647.spfilter1(chkc,e,tp) and chkc~=c end
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的「半龙女仆」怪兽作为目标
		and Duel.IsExistingTarget(c41232647.spfilter1,tp,LOCATION_MZONE,0,1,c,e,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的「半龙女仆」怪兽作为目标
	Duel.SelectTarget(tp,c41232647.spfilter1,tp,LOCATION_MZONE,0,1,1,c,e,tp)
	-- 设置效果操作信息，表示将要特殊召唤1张来自手牌或墓地的「半龙女仆」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 设置效果处理函数，检查是否有足够的召唤位置并执行特殊召唤操作
function c41232647.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的「半龙女仆」怪兽从手牌或墓地特殊召唤
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41232647.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetLevel())
		if g:GetCount()>0 then
			-- 将选中的怪兽以守备表示特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
-- 过滤函数，用于判断是否满足条件：该怪兽从场上回到手牌时为表侧表示、在场上位置、控制者为玩家、种族包含龙族
function c41232647.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousRaceOnField(),RACE_DRAGON)~=0 and c:IsControler(tp)
end
-- 设置效果发动条件，检查是否有满足条件的怪兽回到手牌
function c41232647.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c41232647.cfilter,1,nil,tp)
end
-- 设置效果目标函数，检查是否满足条件：选择对方场上的任意怪兽作为目标
function c41232647.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查是否存在满足条件的对方怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的对方怪兽作为目标
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，表示将要破坏1张对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 设置效果处理函数，检查目标怪兽是否仍然在场并执行破坏操作
function c41232647.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
