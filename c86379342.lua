--鉄獣の血盟
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只连接怪兽为对象才能发动。从自己的手卡·墓地把和那只怪兽种族不同的1只兽族·兽战士族·鸟兽族怪兽特殊召唤。
-- ②：自己场上有兽族·兽战士族·鸟兽族怪兽各存在的场合，把墓地的这张卡除外，以对方场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡的效果直到回合结束时无效。
function c86379342.initial_effect(c)
	-- ①：以自己场上1只连接怪兽为对象才能发动。从自己的手卡·墓地把和那只怪兽种族不同的1只兽族·兽战士族·鸟兽族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,86379342)
	e1:SetTarget(c86379342.sptg)
	e1:SetOperation(c86379342.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有兽族·兽战士族·鸟兽族怪兽各存在的场合，把墓地的这张卡除外，以对方场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86379342,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,86379342)
	e2:SetCondition(c86379342.negcon)
	-- 将墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c86379342.negtg)
	e2:SetOperation(c86379342.negop)
	c:RegisterEffect(e2)
end
-- 过滤函数：自己场上表侧表示的连接怪兽，且手卡·墓地存在与其种族不同的可特殊召唤的兽族/兽战士族/鸟兽族怪兽
function c86379342.spfilter1(c,e,tp)
	-- 判断卡片是否为表侧表示的连接怪兽，且手卡或墓地存在与其种族不同的可特殊召唤的兽族/兽战士族/鸟兽族怪兽
	return c:IsFaceup() and c:IsType(TYPE_LINK) and Duel.IsExistingMatchingCard(c86379342.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c:GetRace())
end
-- 过滤函数：手卡·墓地中与目标怪兽种族不同、且可以特殊召唤的兽族/兽战士族/鸟兽族怪兽
function c86379342.spfilter2(c,e,tp,race)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and not c:IsRace(race) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择（Target）
function c86379342.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c86379342.spfilter1(chkc,e,tp) end
	-- 发动步的合法性检测：检查怪兽区域是否有空位，以及场上是否存在符合条件的可作为对象的连接怪兽
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(c86379342.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息：选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的连接怪兽作为效果对象
	Duel.SelectTarget(tp,c86379342.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，表示将从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的处理（Operation）：特殊召唤手卡·墓地的怪兽
function c86379342.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为对象的连接怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查作为对象的怪兽是否仍存在于场上且表侧表示，并确认自己场上仍有可用的怪兽区域
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家发送提示信息：选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡或墓地选择1只与对象怪兽种族不同的兽族/兽战士族/鸟兽族怪兽（受王家之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c86379342.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetRace())
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数：自己场上表侧表示的兽族怪兽，且场上还存在兽战士族和鸟兽族怪兽
function c86379342.cfilter(c,tp)
	return c:IsRace(RACE_BEAST) and c:IsFaceup()
		-- 检查场上是否存在与当前兽族怪兽不同的兽战士族怪兽
		and Duel.IsExistingMatchingCard(c86379342.cfilter1,tp,LOCATION_MZONE,0,1,c,c,tp)
end
-- 过滤函数：自己场上表侧表示的兽战士族怪兽，且场上还存在鸟兽族怪兽
function c86379342.cfilter1(c,c1,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsFaceup()
		-- 检查场上是否存在与已选的兽族、兽战士族怪兽不同的鸟兽族怪兽
		and Duel.IsExistingMatchingCard(c86379342.cfilter2,tp,LOCATION_MZONE,0,1,Group.FromCards(c,c1))
end
-- 过滤函数：自己场上表侧表示的鸟兽族怪兽
function c86379342.cfilter2(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsFaceup()
end
-- 效果②的发动条件：自己场上同时存在兽族、兽战士族、鸟兽族怪兽
function c86379342.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否同时存在兽族、兽战士族、鸟兽族怪兽各1只以上
	return Duel.IsExistingMatchingCard(c86379342.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 过滤函数：对方场上表侧表示且可被无效的魔法·陷阱卡
function c86379342.negfilter(c)
	-- 判断卡片是否为可被无效的魔法或陷阱卡
	return aux.NegateAnyFilter(c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果②的发动准备与目标选择（Target）
function c86379342.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c86379342.negfilter(chkc) end
	-- 发动步的合法性检测：检查对方场上是否存在符合条件的可作为对象的表侧表示魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c86379342.negfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息：选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1张表侧表示的魔法·陷阱卡作为效果对象
	Duel.SelectTarget(tp,c86379342.negfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 效果②的处理（Operation）：使目标魔法·陷阱卡的效果无效
function c86379342.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的作为对象的魔法·陷阱卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与该卡相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e3)
		end
	end
end
