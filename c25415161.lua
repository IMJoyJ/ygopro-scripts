--スプリガンズ・インタールーダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把卡的效果发动时才能发动。自己场上1只「护宝炮妖」超量怪兽回到额外卡组。那之后，从以下效果选1个适用。
-- ●那个发动的效果无效。
-- ●从自己墓地把1只8星怪兽特殊召唤。
-- ②：自己场上的表侧表示的超量怪兽因效果从场上离开的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
function c25415161.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：对方把卡的效果发动时才能发动。自己场上1只「护宝炮妖」超量怪兽回到额外卡组。那之后，从以下效果选1个适用。●那个发动的效果无效。●从自己墓地把1只8星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25415161,0))
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,25415161)
	e1:SetCondition(c25415161.condition)
	e1:SetTarget(c25415161.target)
	e1:SetOperation(c25415161.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的表侧表示的超量怪兽因效果从场上离开的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25415161,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,25415162)
	e2:SetCondition(c25415161.atkcon)
	e2:SetTarget(c25415161.atktg)
	e2:SetOperation(c25415161.atkop)
	c:RegisterEffect(e2)
end
-- 判断当前连锁效果的发动者是否为对方玩家（rp==1-tp），以此满足“对方把卡的效果发动时才能发动”的发动条件。
function c25415161.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 该过滤器筛选墓地中1只等级为8且能被当前效果特殊召唤的怪兽（检查苏生限制与召唤条件）。
function c25415161.spfilter(c,e,tp)
	return c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 该函数根据 solve 参数决定是否在过滤器上附加王家长眠之谷的适用检查：solve 为 true 时使用 aux.NecroValleyFilter 包装 spfilter，避免从墓地特殊召唤被王谷无效；solve 为 false 时直接使用 spfilter。
function c25415161.spsfilter(c,e,tp,solve)
	if solve then
		-- 对 spfilter 应用 aux.NecroValleyFilter，额外排除因王家长眠之谷而不能从墓地特殊召唤的卡，并返回该卡的判定结果。
		return aux.NecroValleyFilter(c25415161.spfilter)(c,e,tp)
	else
		return c25415161.spfilter(c,e,tp)
	end
end
-- 该过滤器用于选择自己场上1只表侧表示的「护宝炮妖」超量怪兽（可回额外），并确保回额外后至少有一个后续选项可用（无效对方效果、或空场且墓地有8星可特召），solve1 为 true 时跳过该后续可用性检查。
function c25415161.tefilter(c,e,tp,ev,solve1,solve2)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
		-- 当 solve1 为 false 时，检查后续选项：对方连锁效果能够被无效，或者自己场上存在可用的怪兽区（以便后续特殊召唤）。
		and (solve1 or (Duel.IsChainDisablable(ev) or Duel.GetMZoneCount(tp,c)>0
		-- 检查是否存在满足特召条件的墓地8星怪兽（solve2 为 true 时考虑王家长眠之谷的适用），用于保证“特殊召唤”选项可行。
		and Duel.IsExistingMatchingCard(c25415161.spsfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,solve2)))
end
-- ①效果的发动时处理：检查是否有符合条件的“护宝炮妖”超量怪兽可以返回额外卡组，并设置回额外卡组和特殊召唤的操作信息，以供其他连锁检测。
function c25415161.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查自己场上是否存在满足 tefilter 的怪兽，作为效果发动的合法性前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c25415161.tefilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ev) end
	-- 设置操作信息：本次效果可能将1只自己场上的怪兽返回额外卡组（CATEGORY_TOEXTRA）。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_MZONE)
	-- 设置操作信息：本次效果可能从自己墓地特殊召唤1只怪兽（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果处理时：先让玩家选择1只符合条件的“护宝炮妖”超量怪兽返回额外卡组；返回成功后，根据对方连锁是否可无效、是否有空位/墓地怪兽，选择适用“无效对方效果”或“特殊召唤1只8星怪兽”。
function c25415161.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要返回额外卡组的卡（HINTMSG_TODECK）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己场上选择1只满足 tefilter 的“护宝炮妖”超量怪兽（严格检查后续选项可用；solve2=true 表示墓地特召检查需考虑王家长眠之谷）。取第一张作为返回对象。
	local tc=Duel.SelectMatchingCard(tp,c25415161.tefilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ev,false,true):GetFirst()
	if not tc then
		-- 若严格选择未选到，再次提示玩家选择要返回额外卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 放宽条件后再次让玩家从自己场上选择1只满足 tefilter 的“护宝炮妖”超量怪兽（solve1=true 不再强制后续选项可用），取第一张作为返回对象。
		tc=Duel.SelectMatchingCard(tp,c25415161.tefilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ev,true,true):GetFirst()
	end
	-- 将选中的怪兽返回额外卡组（洗牌），并确认返回成功且该卡位于额外卡组；成功后才继续处理二选一效果。
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		-- 如果对方连锁效果不能无效，并且（没有空余怪兽区）……时，则因后续选项不可用而中止处理；这里先检查“没有空余怪兽区”这一条件。
		if not Duel.IsChainDisablable(ev) and not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 结合上一行：如果对方连锁效果不能无效，且（没有空余怪兽区 或 墓地没有可特召的8星怪兽），则效果处理直接返回，不执行任何后续选项。
			and Duel.IsExistingMatchingCard(c25415161.spsfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,true)) then
			return
		end
		-- 中断当前效果处理，使“返回额外”与后续“无效/特召”的处理分开，避免造成错误时点。
		Duel.BreakEffect()
		-- 判断是否强制进入“无效”分支：若对方连锁效果可无效，且自己场上没有空余怪兽区（无法特召），则只能选择无效。
		if Duel.IsChainDisablable(ev) and (Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
			-- 或墓地不存在可特召的8星怪兽，则同样只能选择“无效”分支。
			or not Duel.IsExistingMatchingCard(c25415161.spsfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,true)
			-- 若既能无效又不缺特召条件，则让玩家二选一；选择第一个选项（“那个发动的效果无效”）时进入无效处理。
			or Duel.SelectOption(tp,aux.Stringid(25415161,2),1152)==0) then  --"效果无效"
			-- 将处于连锁 ev 的那个对方发动的效果无效化。
			Duel.NegateEffect(ev)
		else
			-- 弹出选择提示，让玩家选择要特殊召唤的卡（HINTMSG_SPSUMMON）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从自己墓地选择1只满足 spsfilter 的8星怪兽作为特殊召唤对象。
			local sg=Duel.SelectMatchingCard(tp,c25415161.spsfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,true)
			-- 将选择的那只怪兽以表侧表示特殊召唤到自己的场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 该过滤器用于判定离场怪兽是否为“自己场上的表侧表示超量怪兽因效果离场”：检查其之前控制者是自己、之前位置在怪兽区、之前为表侧表示、离场前场上类型为超量怪兽，且离开原因为效果。
function c25415161.atkfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&TYPE_XYZ~=0
		and c:IsReason(REASON_EFFECT)
end
-- ②效果的发动条件：本组离场事件中至少存在1只满足 atkfilter 的怪兽，即“自己场上的表侧表示的超量怪兽因效果从场上离开”。
function c25415161.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25415161.atkfilter,1,nil,tp)
end
-- ②效果的发动时合法性检查：对方场上有表侧表示怪兽存在，才能发动（因为需要让它们攻击力下降）。
function c25415161.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查对方场上是否存在表侧表示怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- ②效果处理时：获取对方场上全部表侧表示怪兽，为每只怪兽赋予“攻击力下降1000直到回合结束”的效果。
function c25415161.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上（玩家 tp 的对方，即 tp,0）所有表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部怪兽的攻击力直到回合结束时下降1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-1000)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
