--ステイセイラ・ロマリン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。选那只怪兽以外的自己场上1只植物族怪兽送去墓地，作为对象的怪兽在这个回合只有1次不会被战斗·效果破坏。这个效果在对方回合也能发动。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组·额外卡组把1只5星以下的植物族怪兽送去墓地。
function c49964567.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。选那只怪兽以外的自己场上1只植物族怪兽送去墓地，作为对象的怪兽在这个回合只有1次不会被战斗·效果破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49964567,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,49964567)
	e1:SetTarget(c49964567.indtg)
	e1:SetOperation(c49964567.indop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。从卡组·额外卡组把1只5星以下的植物族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49964567,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,49964568)
	e2:SetCondition(c49964567.tgcon)
	e2:SetTarget(c49964567.tgtg)
	e2:SetOperation(c49964567.tgop)
	c:RegisterEffect(e2)
end
-- 定义①效果取对象的筛选函数：该卡需表侧表示，且自己场上还存在另一只可送去墓地的植物族怪兽（用于作为送墓的卡）。
function c49964567.indfilter(c,tp)
	-- 判断当前候选对象c是否表侧表示，并且场上存在除c以外的、满足cfilter的植物族怪兽。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c49964567.cfilter,tp,LOCATION_MZONE,0,1,c)
end
-- 定义用于选择送去墓地的植物族怪兽的筛选条件：表侧表示、植物族、且可以被效果送去墓地。
function c49964567.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- ①效果发动时的目标处理：检查是否存在合法对象，让玩家选择自己场上1只表侧表示怪兽作为对象，并设置将1张怪兽送去墓地的操作信息。
function c49964567.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c49964567.indfilter(chkc,tp) end
	-- 在发动合法性检查（chk==0）时，确认自己场上是否存在至少1只满足indfilter的怪兽，作为能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(c49964567.indfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向操作玩家发送选择效果对象的UI提示（“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只表侧表示怪兽作为效果对象，并将该卡登记为当前连锁的对象。
	Duel.SelectTarget(tp,c49964567.indfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：本次效果预期会将1张自己场上的卡送去墓地（具体卡片在处理时选择），供其他卡的效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
-- ①效果处理：取出对象，选择对象以外的1只自己场上植物族怪兽送去墓地；若送墓成功且对象仍与效果关联，则为对象赋予本回合1次不会被战斗·效果破坏的效果。
function c49964567.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	local exc=nil
	if tc:IsRelateToEffect(e) then exc=tc end
	-- 提示操作玩家选择要送去墓地的卡（“请选择要送去墓地的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1只满足cfilter（表侧·植物族·可送墓）且不是当前对象的卡，作为送去墓地的卡。
	local g=Duel.SelectMatchingCard(tp,c49964567.cfilter,tp,LOCATION_MZONE,0,1,1,exc)
	local sc=g:GetFirst()
	if sc then
		-- 手动显示被选中卡的动画效果，并将其记录为广义对象。
		Duel.HintSelection(g)
		-- 判断送墓是否成功（返回非0）、该卡是否确实在墓地、且原对象仍与效果关联；满足条件才继续赋予保护效果。
		if Duel.SendtoGrave(sc,REASON_EFFECT)~=0 and sc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e) then
			-- 作为对象的怪兽在这个回合只有1次不会被战斗·效果破坏。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(49964567,2))  --"「支索帆水手·航海迷迭香」效果适用中"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
			e1:SetCountLimit(1)
			e1:SetValue(c49964567.valcon)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
-- 定义保护效果的判定函数：当破坏原因包含战斗或效果时返回真，即该“1次不被破坏”只对战斗·效果破坏生效。
function c49964567.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- ②效果的发动条件：这张卡被效果（而非战斗等）送去墓地的场合才能发动。
function c49964567.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 定义②效果可选择送去墓地的卡的条件：5星以下、植物族、且可以被送去墓地。
function c49964567.tgfilter(c)
	return c:IsLevelBelow(5) and c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- ②效果发动时的目标/处理前检查：若卡组·额外卡组存在符合条件的植物族怪兽，则允许发动，并设置送去墓地的操作信息。
function c49964567.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查（chk==0）时，确认卡组·额外卡组是否存在至少1只满足tgfilter的植物族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c49964567.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：预期会将1张卡组·额外卡组的卡送去墓地，用于时点或联动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果处理：从卡组·额外卡组选择1只满足条件的植物族怪兽，以效果原因送去墓地。
function c49964567.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示操作玩家选择要送去墓地的卡（“请选择要送去墓地的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组·额外卡组选择1只满足tgfilter（5星以下·植物族·可送墓）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c49964567.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
