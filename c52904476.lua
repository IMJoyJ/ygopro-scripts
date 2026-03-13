--ネフティスの悟り手
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「奈芙提斯之悟道者」以外的自己墓地1只4星以下的「奈芙提斯」怪兽为对象才能发动。选1张手卡破坏，作为对象的怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。这张卡从墓地特殊召唤。
function c52904476.initial_effect(c)
	-- ①：以「奈芙提斯之悟道者」以外的自己墓地1只4星以下的「奈芙提斯」怪兽为对象才能发动。选1张手卡破坏，作为对象的怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
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
	-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c52904476.spr)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。
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
-- 过滤函数，检查以tp来看的墓地是否存在满足条件的「奈芙提斯」怪兽（4星以下且不是自己）并且可以特殊召唤
function c52904476.filter(c,e,tp)
	return c:IsSetCard(0x11f) and c:IsLevelBelow(4) and not c:IsCode(52904476)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果处理时的判断条件：是否满足发动条件（存在目标怪兽、场上空位、手卡存在）
function c52904476.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52904476.filter(chkc,e,tp) end
	-- 检查是否存在满足过滤条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c52904476.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查场上是否有空位以及手卡是否存在
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c52904476.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将要破坏的手卡数量设为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：将要特殊召唤的怪兽设为已选目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行破坏手卡并特殊召唤怪兽的操作，并使该怪兽效果无效化
function c52904476.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从手卡中选择一张卡进行破坏
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	if #g==0 then return end
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断是否成功破坏了手卡且目标怪兽仍在场
	if Duel.Destroy(g,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e)
		-- 执行特殊召唤步骤，以守备表示特殊召唤目标怪兽
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 使该怪兽效果无效化
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使该怪兽的效果无效化（持续到回合结束）
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 当此卡被送去墓地时触发的处理函数，用于记录下次准备阶段是否可以发动效果
function c52904476.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 判断当前是否为自己的准备阶段
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 记录当前回合数作为标签
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(52904476,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(52904476,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 判断是否满足下次准备阶段发动条件：标签不等于当前回合数、是自己回合、且拥有标记
function c52904476.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回标签不等于当前回合数且是自己回合且拥有标记的判断结果
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(52904476)>0
end
-- 效果处理时的判断条件：是否满足发动条件（可以特殊召唤、场上空位）
function c52904476.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置操作信息：将要特殊召唤的卡设为当前卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(52904476)
end
-- 效果处理函数，执行从墓地特殊召唤的操作
function c52904476.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以通常形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
