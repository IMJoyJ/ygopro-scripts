--彼岸の悪鬼 アリキーノ
-- 效果：
-- 「彼岸的恶鬼 阿利基诺」的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
-- ③：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
function c47728740.initial_effect(c)
	-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c47728740.sdcon)
	c:RegisterEffect(e1)
	-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47728740,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,47728740)
	e2:SetCondition(c47728740.sscon)
	e2:SetTarget(c47728740.sstg)
	e2:SetOperation(c47728740.ssop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47728740,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,47728740)
	e3:SetTarget(c47728740.distg)
	e3:SetOperation(c47728740.disop)
	c:RegisterEffect(e3)
end
-- 筛选场上的怪兽，如果怪兽是里侧表示或不是「彼岸」卡组，则返回true。
function c47728740.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- 判断自己场上是否存在非「彼岸」怪兽，若存在则触发效果。
function c47728740.sdcon(e)
	-- 检查自己场上是否存在至少一张非「彼岸」怪兽。
	return Duel.IsExistingMatchingCard(c47728740.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 筛选魔法·陷阱卡类型的卡片。
function c47728740.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断自己场上是否没有魔法·陷阱卡存在，若无则可以发动效果。
function c47728740.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少一张魔法或陷阱卡。
	return not Duel.IsExistingMatchingCard(c47728740.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置特殊召唤的处理目标为自身，并设定处理类别为特殊召唤。
function c47728740.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息，表示将要进行特殊召唤操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将自身从手牌特殊召唤到场上。
function c47728740.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身从手牌特殊召唤到场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 设置效果的目标为场上的任意一只表侧表示怪兽，并设定处理类别为使效果无效。
function c47728740.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 当有目标选择时，判断该目标是否满足被无效化的条件且位于场上。
	if chkc then return aux.NegateMonsterFilter(chkc) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查是否存在至少一个可被无效化的场上怪兽作为目标。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择要无效的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择一个符合条件的场上怪兽作为效果的目标。
	Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 执行效果处理，使目标怪兽的效果在本回合内无效化。
function c47728740.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被指定的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽相关的连锁无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 创建一个永续效果，使目标怪兽的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 创建一个永续效果，使目标怪兽的效果在回合结束时恢复。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
