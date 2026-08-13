--魂喰いオヴィラプター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1只恐龙族怪兽加入手卡或送去墓地。
-- ②：以这张卡以外的场上1只4星以下的恐龙族怪兽为对象才能发动。那只怪兽破坏。那之后，从自己墓地选1只恐龙族怪兽守备表示特殊召唤。
function c44335251.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1只恐龙族怪兽加入手卡或送去墓地。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：以这张卡以外的场上1只4星以下的恐龙族怪兽为对象才能发动。那只怪兽破坏。那之后，从自己墓地选1只恐龙族怪兽守备表示特殊召唤。
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
-- 定义①效果的卡组筛选条件：卡组中的卡必须为怪兽卡、恐龙族，并且能够加入手卡或能够送去墓地，满足任一即可成为可选对象。
function c44335251.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DINOSAUR) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ①效果的发动目标判定与操作信息设置：检查卡组是否存在符合条件的恐龙族怪兽，若存在则同时登记“加入手卡”和“送去墓地”两种可能效果分类。
function c44335251.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查卡组是否存在至少1只满足cfilter条件的恐龙族怪兽，作为①效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c44335251.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果可能涉及将卡组中的卡加入手卡，预定处理数量为1，对象范围为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本次效果可能涉及将卡组中的卡送去墓地，预定处理数量为1，对象范围为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时：提示玩家选择一张符合条件的恐龙族怪兽，若该卡既能加入手卡又能送去墓地，则由玩家选择处理方式；最终执行加入手卡或送去墓地，加入手卡时还需向对方确认。
function c44335251.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择一张要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1张满足cfilter条件的恐龙族怪兽（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c44335251.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 判断所选卡的处理分支：若该卡能够加入手卡，并且（不能送去墓地或玩家选择了加入手卡选项），则执行加入手卡；否则执行送去墓地。
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将选中的恐龙族怪兽加入其持有者的手卡，原因是效果。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将该卡展示给对方玩家确认，以证明是通过效果加入手卡的卡。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的恐龙族怪兽送去其持有者的墓地，原因是效果。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- 定义②效果的对象筛选条件：场上的表侧表示怪兽、4星以下、恐龙族，并且该卡被破坏后自己场上仍有可用怪兽区，才能作为对象。
function c44335251.desfilter(c,tp)
	-- 对象必须满足表侧表示、等级4以下、恐龙族，且若该对象离开场上后自己仍有怪兽区空格（用于后续特殊召唤）。
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_DINOSAUR) and Duel.GetMZoneCount(tp,c,tp)>0
end
-- 定义墓地的特殊召唤筛选条件：墓地中的恐龙族怪兽能够被本次效果以表侧守备表示特殊召唤（检查召唤条件与苏生限制）。
function c44335251.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动目标判定与操作信息设置：选择这张卡以外的场上1只4星以下恐龙族怪兽作为破坏对象，同时确认墓地存在可特殊召唤的恐龙族怪兽。
function c44335251.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c44335251.desfilter(chkc,tp) and chkc~=c end
	-- 发动条件检查：场上是否存在满足条件的恐龙族对象（排除这张卡自身）。
	if chk==0 then return Duel.IsExistingTarget(c44335251.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp)
		-- 同时检查墓地是否存在可特殊召唤的恐龙族怪兽，作为②效果的另一个发动条件。
		and Duel.IsExistingMatchingCard(c44335251.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1只满足desfilter条件的恐龙族怪兽作为效果对象，并记录为本次连锁的对象。
	local g=Duel.SelectTarget(tp,c44335251.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,tp)
	-- 设置操作信息：本次效果将破坏所选择的对象，预定破坏数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本次效果在破坏后可能从墓地特殊召唤1只怪兽，对象范围为墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理时：先取得对象，若对象仍与效果相关且被成功破坏，则从自己墓地选择1只恐龙族怪兽以表侧守备表示特殊召唤。
function c44335251.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果相关（未被移离或失效），然后将其破坏；只有破坏成功才继续后续的特殊召唤处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地选择1只满足spfilter条件的恐龙族怪兽。
		local g=Duel.SelectMatchingCard(tp,c44335251.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 中断当前效果的处理，使后续的特殊召唤视为另一次效果处理，避免因同一连锁处理而错过时点。
			Duel.BreakEffect()
			-- 将选中的恐龙族怪兽以表侧守备表示特殊召唤到自己的场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
