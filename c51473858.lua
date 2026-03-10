--百鬼羅刹 爆音クラッタ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以「百鬼罗刹 爆音克拉特」以外的自己墓地1只「哥布林」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，对方主要阶段才能发动。场上1个超量素材取除，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c51473858.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，以「百鬼罗刹 爆音克拉特」以外的自己墓地1只「哥布林」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51473858,0))  --"特殊召唤墓地怪兽"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,51473858)
	e1:SetTarget(c51473858.sptg)
	e1:SetOperation(c51473858.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，对方主要阶段才能发动。场上1个超量素材取除，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51473858,1))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,51473858+1)
	e3:SetCondition(c51473858.spcon2)
	e3:SetTarget(c51473858.sptg2)
	e3:SetOperation(c51473858.spop2)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的墓地哥布林怪兽，用于特殊召唤
function c51473858.filter(c,e,tp)
	return c:IsSetCard(0xac) and not c:IsCode(51473858) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置选择目标时的过滤条件，确保选择的是自己墓地的哥布林怪兽
function c51473858.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51473858.filter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地中是否存在符合条件的哥布林怪兽作为目标
		and Duel.IsExistingTarget(c51473858.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地哥布林怪兽作为特殊召唤的目标
	local g=Duel.SelectTarget(tp,c51473858.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将选中的目标怪兽特殊召唤到场上
function c51473858.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧攻击形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足在对方主要阶段发动效果的条件
function c51473858.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前回合玩家不是自己，并且处于主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 设置第二个效果的目标选择逻辑，检查是否能移除场上一个超量素材并确认自身可特殊召唤
function c51473858.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除场上的一个超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置第二个效果的操作信息，确定将要特殊召唤的卡为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行第二个效果的处理流程，移除超量素材并特殊召唤自身
function c51473858.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否成功移除场上一个超量素材且自身仍存在于场上的状态
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 尝试以特殊召唤方式将自身加入场上
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 设置特殊召唤后的效果，使该卡从场上离开时被送入除外区
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
		end
		-- 完成特殊召唤流程的收尾工作
		Duel.SpecialSummonComplete()
	end
end
