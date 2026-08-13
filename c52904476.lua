--ネフティスの悟り手
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「奈芙提斯之悟道者」以外的自己墓地1只4星以下的「奈芙提斯」怪兽为对象才能发动。选1张手卡破坏，作为对象的怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。这张卡从墓地特殊召唤。
function c52904476.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以「奈芙提斯之悟道者」以外的自己墓地1只4星以下的「奈芙提斯」怪兽为对象才能发动。选1张手卡破坏，作为对象的怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52904476,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,52904476)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c52904476.sptg)
	e1:SetOperation(c52904476.spop)
	c:RegisterEffect(e1)
	-- 这张卡被效果破坏送去墓地的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c52904476.spr)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52904476,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,52904477)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c52904476.spcon2)
	e3:SetTarget(c52904476.sptg2)
	e3:SetOperation(c52904476.spop2)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 定义①效果可选择的对象：自己墓地中卡名属于「奈芙提斯」字段、等级4以下、不是「奈芙提斯之悟道者」本身，且能够以表侧守备表示用该效果特殊召唤的怪兽。
function c52904476.filter(c,e,tp)
	return c:IsSetCard(0x11f) and c:IsLevelBelow(4) and not c:IsCode(52904476)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果发动条件的判定：若为效果对象检查，则确认所选对象位于自己墓地且满足过滤条件；若为发动合法性检查，则确认墓地存在符合条件的对象、场上主要怪兽区有空位、手牌有可破坏的卡。
function c52904476.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52904476.filter(chkc,e,tp) end
	-- 在效果发动前检查自己墓地是否存在至少1只满足 c52904476.filter 条件的「奈芙提斯」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c52904476.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 并且我方主要怪兽区存在空位，手牌存在至少1张卡可作为破坏对象。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家显示提示信息，要求选择要特殊召唤的怪兽（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足过滤条件的「奈芙提斯」怪兽作为卡牌效果对象，并自动记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c52904476.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果将在效果处理时破坏手牌中的1张卡（破坏目标不确定，故 targets 为 nil，位置为手牌）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	-- 登记操作信息：本次效果将把作为对象选择的怪兽 g 特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：先选择手牌1张卡并破坏，若破坏成功且对象仍与效果相关，则将对象怪兽表侧守备表示特殊召唤，并对其施加“效果无效化”状态，最后完成特殊召唤。
function c52904476.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示提示信息，要求选择要破坏的手牌（HINTMSG_DESTROY）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从手牌中选择1张卡（不限定条件，用于破坏）。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	if #g==0 then return end
	-- 获取发动时选择的墓地怪兽（即效果对象）。
	local tc=Duel.GetFirstTarget()
	-- 若手牌中的那张卡被效果成功破坏，且对象怪兽与当前效果仍有关联（未失去联系），则继续特殊召唤处理。
	if Duel.Destroy(g,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e)
		-- 将对象怪兽以表侧守备表示进行特殊召唤（作为特殊召唤处理的一步）。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
	end
	-- 完成整个特殊召唤处理，将在 SpecialSummonStep 中暂存的怪兽正式特殊召唤上场。
	Duel.SpecialSummonComplete()
end
-- 当这张卡被送去墓地时，检查其破坏原因是否为“效果破坏”；若是，则记录当前回合信息，并设置一个用于下次准备阶段发动②效果的标记；若破坏时正处于自己的准备阶段，则额外调整标记使发动时点正确。
function c52904476.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 判断这张卡被效果破坏送去墓地的时机是否恰好是自己的准备阶段（用于区分被破坏的当回合准备阶段和下一个准备阶段）。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 记录当前回合数到效果的标签中，作为判断“下次自己准备阶段”的基准。
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(52904476,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(52904476,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- ②效果的发动条件判定：此卡之前被效果破坏送去墓地时记录的回合不是当前回合，且当前是持有者的准备阶段，并且卡片带有 52904476 的发动标记。
function c52904476.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断已记录回合不等于当前回合、当前玩家为这张卡的持有者，并且存在已登记的 52904476 标记，满足时②效果才能发动。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(52904476)>0
end
-- ②效果发动前检查：这张卡自身能否被特殊召唤，以及我方主要怪兽区是否有空位。
function c52904476.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且我方主要怪兽区存在可用的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 登记操作信息：本次效果将把这张卡从墓地特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(52904476)
end
-- ②效果处理：若这张卡仍与当前效果有关联，则将其从墓地以表侧攻击表示特殊召唤。
function c52904476.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
