--ブンボーグ003
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把「文具电子人003」以外的1只「文具电子人」怪兽特殊召唤。
-- ②：1回合1次，以自己场上1只「文具电子人」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升自己场上的「文具电子人」卡数量×500。这个效果在对方回合也能发动。
function c75944053.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把「文具电子人003」以外的1只「文具电子人」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c75944053.sptg)
	e1:SetOperation(c75944053.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只「文具电子人」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升自己场上的「文具电子人」卡数量×500。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	-- 设置效果在伤害步骤中，若已进行伤害计算则不能发动（限制在伤害计算前发动）。
	e2:SetCondition(aux.dscon)
	e2:SetTarget(c75944053.target)
	e2:SetOperation(c75944053.operation)
	c:RegisterEffect(e2)
end
-- 过滤卡组中除「文具电子人003」以外且可以特殊召唤的「文具电子人」怪兽。
function c75944053.spfilter(c,e,tp)
	return c:IsSetCard(0xab) and not c:IsCode(75944053) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测函数。
function c75944053.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「文具电子人」怪兽。
		and Duel.IsExistingMatchingCard(c75944053.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息，表示该效果包含从卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数，执行特殊召唤。
function c75944053.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无空余的怪兽区域，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「文具电子人」怪兽。
	local g=Duel.SelectMatchingCard(tp,c75944053.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上表侧表示的「文具电子人」卡片。
function c75944053.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xab)
end
-- 效果②的发动准备与对象选择函数。
function c75944053.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c75944053.filter(chkc) end
	-- 检查自己场上是否存在至少1只表侧表示的「文具电子人」怪兽作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c75944053.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只表侧表示的「文具电子人」怪兽作为效果对象并进行锁定。
	Duel.SelectTarget(tp,c75944053.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理函数，提升目标怪兽的攻击力和守备力。
function c75944053.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上表侧表示的「文具电子人」卡片数量，并乘以500作为攻击力/守备力上升的数值。
	local val=Duel.GetMatchingGroupCount(c75944053.filter,tp,LOCATION_ONFIELD,0,nil)*500
	-- 获取在发动时选择的第一个效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力·守备力直到回合结束时上升自己场上的「文具电子人」卡数量×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
