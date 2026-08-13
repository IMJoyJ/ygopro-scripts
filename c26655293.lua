--マグナヴァレット・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，场上1只怪兽送去墓地。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「马格努姆弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
function c26655293.initial_effect(c)
	-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，场上1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26655293,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,26655293)
	e1:SetCondition(c26655293.descon)
	e1:SetTarget(c26655293.destg)
	e1:SetOperation(c26655293.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c26655293.regop)
	c:RegisterEffect(e2)
end
-- 判断诱发条件：只有场上这张卡成为取对象的连接怪兽效果的对象时，该效果发动才能满足；非取对象效果或非连接怪兽效果不满足。
function c26655293.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得当前连锁中发动效果所取的对象卡组，用于确认是否包含这张卡。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- 发动时点检查：确认这张卡可以被破坏且场上存在其他怪兽可作为送墓对象；并设置破坏自身和送墓1只怪兽的操作信息。
function c26655293.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取场上除这张卡以外的双方全部怪兽，作为“那之后，场上1只怪兽送去墓地”的候选集合。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	if chk==0 then return c:IsDestructable() and g:GetCount()>0 end
	-- 设置操作信息：本连锁包含破坏效果，破坏对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置操作信息：本连锁包含送去墓地效果，候选对象为场上除自身外的怪兽，实际处理时选择1只送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果处理：若这张卡仍关联且被成功破坏，则在那之后从场上双方怪兽中选择1只送去墓地。
function c26655293.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断这张卡是否仍与该效果关联（未被无效或离场），并执行破坏；若破坏成功则继续后续送墓处理。
	if e:GetHandler():IsRelateToEffect(e) and Duel.Destroy(e:GetHandler(),REASON_EFFECT)>0 then
		-- 取得场上全部怪兽（此时自身已不在场上），用于后续选择1只送去墓地。
		local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
		if g:GetCount()==0 then return end
		-- 中断当前效果处理，使‘这张卡破坏’与‘那之后送墓’分成两个时点处理，以符合‘那之后’的顺序。
		Duel.BreakEffect()
		-- 向操作玩家显示选择提示消息，要求选择1只要送去墓地的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽以效果原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 连续效果处理：当这张卡从场上被战斗或效果破坏并送去墓地时，在墓地注册一个可在当回合结束阶段发动的②效果。
function c26655293.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- 从卡组把「马格努姆弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(26655293,1))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,26655294)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c26655293.sptg)
		e1:SetOperation(c26655293.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤的筛选条件：必须是「弹丸」怪兽、卡名不是「马格努姆弹丸龙」、且可以通过该效果特殊召唤。
function c26655293.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(26655293) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动②效果的条件检查：自己场上有可用的怪兽区空格，并且卡组中存在符合条件的「弹丸」怪兽；通过后设置特殊召唤操作信息。
function c26655293.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足spfilter条件的「弹丸」怪兽。
		and Duel.IsExistingMatchingCard(c26655293.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁包含从卡组特殊召唤1只怪兽（对象在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：在自己场上有空位时，从卡组选择1只符合条件的「弹丸」怪兽，以表侧表示特殊召唤。
function c26655293.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有可用的主要怪兽区空格，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择提示消息，要求选择1只要特殊召唤的「弹丸」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足spfilter条件的「弹丸」怪兽。
	local g=Duel.SelectMatchingCard(tp,c26655293.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
