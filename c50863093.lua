--マシンナーズ・ラディエーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡以外的1只「机甲」怪兽丢弃才能发动。这张卡从手卡特殊召唤。
-- ②：以自己场上1只机械族怪兽为对象才能发动。从自己墓地选和那只怪兽卡名不同并持有那只怪兽的等级以下的等级的1只「机甲」怪兽特殊召唤，作为对象的怪兽破坏。
function c50863093.initial_effect(c)
	-- ①：从手卡把这张卡以外的1只「机甲」怪兽丢弃才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50863093,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,50863093)
	e1:SetCost(c50863093.spcost1)
	e1:SetTarget(c50863093.sptg1)
	e1:SetOperation(c50863093.spop1)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只机械族怪兽为对象才能发动。从自己墓地选和那只怪兽卡名不同并持有那只怪兽的等级以下的等级的1只「机甲」怪兽特殊召唤，作为对象的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50863093,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,50863094)
	e2:SetTarget(c50863093.sptg2)
	e2:SetOperation(c50863093.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手牌中是否包含满足条件的「机甲」怪兽（必须是怪兽卡、可丢弃）
function c50863093.cfilter(c)
	return c:IsSetCard(0x36) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果发动时的费用处理：检查手牌是否存在满足cfilter条件的卡并将其丢弃
function c50863093.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否存在至少1张满足cfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c50863093.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌中丢弃1张满足cfilter条件的卡作为发动费用
	Duel.DiscardHand(tp,c50863093.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 效果发动时的取对象处理：判断是否满足特殊召唤条件
function c50863093.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：将此卡特殊召唤到场上
function c50863093.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以正面表示的形式特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于判断场上的机械族怪兽是否满足特殊召唤条件
function c50863093.desfilter(c,e,tp)
	-- 判断目标怪兽为正面表示且种族为机械，并且墓地存在满足spfilter条件的「机甲」怪兽
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and Duel.IsExistingMatchingCard(c50863093.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode(),c:GetLevel())
end
-- 过滤函数，用于从墓地中选择满足条件的「机甲」怪兽（卡名不同、等级不超过目标怪兽）
function c50863093.spfilter(c,e,tp,code,lv)
	return c:IsSetCard(0x36) and not c:IsCode(code) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的取对象处理：判断是否满足特殊召唤和破坏条件
function c50863093.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50863093.desfilter(chkc,e,tp) end
	-- 判断玩家场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足desfilter条件的场上的机械族怪兽作为对象
		and Duel.IsExistingTarget(c50863093.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c50863093.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，表示将要从墓地特殊召唤「机甲」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 设置连锁操作信息，表示将要破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：执行②效果的处理流程
function c50863093.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断玩家场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地中选择满足条件的「机甲」怪兽作为特殊召唤目标
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50863093.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetCode(),tc:GetLevel())
		-- 如果成功特殊召唤了怪兽，则执行破坏操作
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 将目标怪兽以效果原因进行破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
