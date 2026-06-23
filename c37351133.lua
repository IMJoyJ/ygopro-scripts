--閃刀姫－ロゼ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「闪刀姬-露世」以外的「闪刀姬」怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在墓地存在的状态，额外怪兽区域的对方怪兽被战斗破坏的场合或者因自己的卡的效果从场上离开的场合才能发动。这张卡特殊召唤。那之后，可以把对方场上1只表侧表示怪兽的效果直到回合结束时无效。
function c37351133.initial_effect(c)
	-- ①：「闪刀姬-露世」以外的「闪刀姬」怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
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
-- 过滤函数，用于筛选场上正面表示的「闪刀姬」怪兽且不是露世本身
function c37351133.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x1115) and not c:IsCode(37351133)
end
-- 判断是否有满足条件的怪兽被召唤或特殊召唤
function c37351133.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37351133.cfilter1,1,nil)
end
-- 设置特殊召唤的处理目标
function c37351133.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作
function c37351133.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选被破坏或离开场上的对方怪兽（必须在额外怪兽区且为战斗破坏或被自己效果破坏）
function c37351133.cfilter2(c,tp,rp)
	return c:IsPreviousControler(1-tp) and c:GetPreviousSequence()>4 and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or (rp==tp and c:IsReason(REASON_EFFECT)))
end
-- 判断是否有满足条件的怪兽被破坏或离开场上的场合
function c37351133.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37351133.cfilter2,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- 执行墓地特殊召唤并可能无效对方怪兽效果
function c37351133.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否能参与特殊召唤处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断对方场上是否存在可被无效化的怪兽
		and Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否选择对方怪兽效果无效
		and Duel.SelectYesNo(tp,aux.Stringid(37351133,2)) then  --"是否选对方怪兽效果无效？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要无效的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 选择对方场上一只可被无效化的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 显示所选怪兽被选为对象的动画
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		-- 使所选怪兽相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使所选怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使所选怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
