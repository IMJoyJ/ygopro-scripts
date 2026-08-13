--閃刀姫－ロゼ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「闪刀姬-露世」以外的「闪刀姬」怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在墓地存在的状态，额外怪兽区域的对方怪兽被战斗破坏的场合或者因自己的卡的效果从场上离开的场合才能发动。这张卡特殊召唤。那之后，可以把对方场上1只表侧表示怪兽的效果直到回合结束时无效。
function c37351133.initial_effect(c)
	-- 「闪刀姬-露世」以外的「闪刀姬」怪兽召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37351133,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,37351133)
	e1:SetCondition(c37351133.spcon1)
	e1:SetTarget(c37351133.sptg)
	e1:SetOperation(c37351133.spop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的状态，额外怪兽区域的对方怪兽被战斗破坏的场合或者因自己的卡的效果从场上离开的场合才能发动。这张卡特殊召唤。那之后，可以把对方场上1只表侧表示怪兽的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37351133,1))  --"这张卡从墓地特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,37351134)
	e3:SetCondition(c37351133.spcon2)
	e3:SetTarget(c37351133.sptg)
	e3:SetOperation(c37351133.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：该怪兽为表侧表示、属于「闪刀姬」字段（0x1115），且不是「闪刀姬-露世」自身（卡号37351133）。
function c37351133.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x1115) and not c:IsCode(37351133)
end
-- 诱发条件：这次召唤/特殊召唤成功的怪兽组中存在至少1只满足cfilter1过滤的「闪刀姬」怪兽（即不是露世本人的表侧「闪刀姬」怪兽）。
function c37351133.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37351133.cfilter1,1,nil)
end
-- 发动准备：效果发动时点检查自身是否在手牌且可以被特殊召唤，并确认自己场上有空位；需要将自身从手牌特殊召唤。
function c37351133.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否有可用的空格，以保证可以特殊召唤手牌的这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次效果的操作信息：包含特殊召唤分类，处理对象为自身（露世），数量1，为后续发动时点检测提供依据。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：若这张卡仍与当前效果关联，则将其以表侧表示从手牌特殊召唤到自己场上。
function c37351133.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到持有者（tp）的场上，不检查召唤条件且不检查苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：离场怪兽之前是对方控制（1-tp）、原先位于额外怪兽区域（序列>4即MZONE的5、6号位）、离场前的区域是主要怪兽区，并且离场原因是战斗破坏，或者是由我方（tp）发动的效果导致离场。
function c37351133.cfilter2(c,tp,rp)
	return c:IsPreviousControler(1-tp) and c:GetPreviousSequence()>4 and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or (rp==tp and c:IsReason(REASON_EFFECT)))
end
-- 诱发条件：存在满足cfilter2的对方额外怪兽区域怪兽因战斗或我方效果离场，且离场组中不包含露世自身（避免露世因同一效果同时离场时错误触发）。
function c37351133.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37351133.cfilter2,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- 效果处理：若这张卡仍在墓地且与效果关联，先将其特殊召唤；若特殊召唤成功且对方场上有可无效的表侧效果怪兽，则询问玩家是否发动无效效果，选择后将该怪兽的效果直到回合结束时无效。
function c37351133.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理条件判断：这张卡仍与效果关联，且特殊召唤成功（返回非0），才继续后续无效效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查对方场上是否存在至少1只满足aux.NegateMonsterFilter（表侧表示、未被无效、效果怪兽）的怪兽，作为可选无效对象。
		and Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		-- 弹出选择框，让玩家决定是否发动追加的无效效果。
		and Duel.SelectYesNo(tp,aux.Stringid(37351133,2)) then  --"是否选对方怪兽效果无效？"
		-- 中断当前连锁的效果处理，使后续的无效处理作为另一个效果处理节点，避免错过时点或造成同一组处理冲突。
		Duel.BreakEffect()
		-- 发送选择提示信息，告知玩家当前需要选择一张要无效的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 由玩家从对方场上选择1只满足aux.NegateMonsterFilter的表侧效果怪兽作为无效对象。
		local g=Duel.SelectMatchingCard(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 显示所选卡片的选中动画，并将其记录为广义的‘被选为对象’状态。
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		-- 使与所选怪兽相关的连锁全部无效化，重置标志设为变里侧时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 把对方场上1只表侧表示怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 把对方场上1只表侧表示怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
