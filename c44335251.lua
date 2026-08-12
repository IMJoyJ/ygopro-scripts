--魂喰いオヴィラプター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1只恐龙族怪兽加入手卡或送去墓地。
-- ②：以这张卡以外的场上1只4星以下的恐龙族怪兽为对象才能发动。那只怪兽破坏。那之后，从自己墓地选1只恐龙族怪兽守备表示特殊召唤。
function c44335251.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1只恐龙族怪兽加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44335251,0))  --"恐龙族怪兽加入手卡或送去墓地"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,44335251)
	e1:SetTarget(c44335251.target)
	e1:SetOperation(c44335251.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以这张卡以外的场上1只4星以下的恐龙族怪兽为对象才能发动。那只怪兽破坏。那之后，从自己墓地选1只恐龙族怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44335251,1))  --"破坏并特殊召唤"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,44335252)
	e3:SetTarget(c44335251.destg)
	e3:SetOperation(c44335251.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的恐龙族怪兽（可加入手卡或送去墓地）
function c44335251.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DINOSAUR) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 设置效果处理时的操作信息，包括将卡加入手卡和送去墓地的类别
function c44335251.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：在卡组中存在至少1张符合条件的恐龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44335251.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将1张卡从卡组加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：将1张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择卡组中的恐龙族怪兽并决定加入手卡或送去墓地
function c44335251.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1张符合条件的恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c44335251.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 判断是否可以将卡加入手卡，若可以则选择加入手卡或送去墓地
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将选中的卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于筛选满足条件的场上恐龙族怪兽（4星以下且可破坏）
function c44335251.desfilter(c,tp)
	-- 判断目标怪兽是否为表侧表示、等级4以下、恐龙族且场上存在可用区域
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_DINOSAUR) and Duel.GetMZoneCount(tp,c,tp)>0
end
-- 过滤函数，用于筛选可特殊召唤的恐龙族怪兽
function c44335251.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果处理时的操作信息，包括破坏和特殊召唤的类别
function c44335251.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c44335251.desfilter(chkc,tp) and chkc~=c end
	-- 检查是否满足条件：场上存在至少1只符合条件的恐龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c44335251.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp)
		-- 检查是否满足条件：墓地中存在至少1只符合条件的恐龙族怪兽
		and Duel.IsExistingMatchingCard(c44335251.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上符合条件的1只恐龙族怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c44335251.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,tp)
	-- 设置操作信息：破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：从墓地特殊召唤1只恐龙族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数，破坏目标怪兽并从墓地特殊召唤恐龙族怪兽
function c44335251.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地中选择1只符合条件的恐龙族怪兽
		local g=Duel.SelectMatchingCard(tp,c44335251.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的卡以守备表示特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
