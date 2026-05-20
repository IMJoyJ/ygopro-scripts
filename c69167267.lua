--薫り貴き薔薇の芽吹き
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地选1只「蔷薇龙」怪兽守备表示特殊召唤。
-- ②：盖放的这张卡被破坏的场合，从自己墓地的怪兽以及除外的自己怪兽之中以1只「黑蔷薇龙」或者1只有那个卡名记述的怪兽为对象才能发动。那只怪兽特殊召唤。
function c69167267.initial_effect(c)
	-- 注册卡片记述了「黑蔷薇龙」卡名的信息
	aux.AddCodeList(c,73580471)
	-- ①：从自己的手卡·墓地选1只「蔷薇龙」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,69167267)
	e1:SetTarget(c69167267.sptg1)
	e1:SetOperation(c69167267.spop1)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被破坏的场合，从自己墓地的怪兽以及除外的自己怪兽之中以1只「黑蔷薇龙」或者1只有那个卡名记述的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,69167268)
	e2:SetCondition(c69167267.spcon2)
	e2:SetTarget(c69167267.sptg2)
	e2:SetOperation(c69167267.spop2)
	c:RegisterEffect(e2)
end
-- 过滤手卡·墓地中可以守备表示特殊召唤的「蔷薇龙」怪兽
function c69167267.spfilter1(c,e,tp)
	return c:IsSetCard(0x1123) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与合法性检测函数
function c69167267.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位，以及手卡或墓地是否存在可以特殊召唤的「蔷薇龙」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c69167267.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示将从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的执行函数
function c69167267.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并让玩家从手卡或墓地选择1只满足条件的「蔷薇龙」怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c69167267.spfilter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动条件函数，检查此卡是否在魔陷区以盖放状态被破坏
function c69167267.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤墓地或除外状态下，可以特殊召唤的「黑蔷薇龙」或记述了该卡名的怪兽
function c69167267.spfilter2(c,e,tp)
	-- 检查卡片是否在墓地或以表侧表示除外、是否是「黑蔷薇龙」或记述了其卡名、且可以特殊召唤
	return c:IsFaceupEx() and aux.IsCodeOrListed(c,73580471) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备、取对象与合法性检测函数
function c69167267.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c69167267.spfilter2(chkc,e,tp) end
	-- 检查怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地或除外的怪兽中是否存在可以作为对象特殊召唤的「黑蔷薇龙」或记述了其卡名的怪兽
		and Duel.IsExistingTarget(c69167267.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地或除外的1只「黑蔷薇龙」或记述了其卡名的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c69167267.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息，表示将特殊召唤选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的执行函数
function c69167267.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
