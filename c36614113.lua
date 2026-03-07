--DDアーク
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以对方场上1只灵摆召唤的怪兽为对象才能发动。那只怪兽和这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡被效果破坏的场合才能发动。从自己的额外卡组把「DD 方舟」以外的1只表侧表示的「DD」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c36614113.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：以对方场上1只灵摆召唤的怪兽为对象才能发动。那只怪兽和这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36614113,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,36614113)
	e1:SetTarget(c36614113.destg)
	e1:SetOperation(c36614113.desop)
	c:RegisterEffect(e1)
	-- ①：这张卡被效果破坏的场合才能发动。从自己的额外卡组把「DD 方舟」以外的1只表侧表示的「DD」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36614113,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,36614114)
	e2:SetCondition(c36614113.spcon)
	e2:SetTarget(c36614113.sptg)
	e2:SetOperation(c36614113.spop)
	c:RegisterEffect(e2)
end
-- 设置灵摆效果的目标选择函数，用于筛选对方场上的灵摆召唤怪兽
function c36614113.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsSummonType(SUMMON_TYPE_PENDULUM) end
	-- 检查是否满足灵摆效果的发动条件，即对方场上是否存在灵摆召唤的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsSummonType,tp,0,LOCATION_MZONE,1,nil,SUMMON_TYPE_PENDULUM) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1只灵摆召唤怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsSummonType,tp,0,LOCATION_MZONE,1,1,nil,SUMMON_TYPE_PENDULUM)
	g:AddCard(e:GetHandler())
	-- 设置连锁操作信息，指定将要破坏的2张卡（目标怪兽+DD方舟）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 设置灵摆效果的处理函数，用于执行破坏操作
function c36614113.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽和DD方舟一起破坏
		Duel.Destroy(Group.FromCards(tc,e:GetHandler()),REASON_EFFECT)
	end
end
-- 设置怪兽效果的发动条件，判断DD方舟是否因效果而被破坏
function c36614113.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 设置特殊召唤的过滤函数，筛选满足条件的DD灵摆怪兽
function c36614113.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsType(TYPE_PENDULUM) and not c:IsCode(36614113)
		-- 检查额外卡组中是否存在可特殊召唤的DD灵摆怪兽
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置怪兽效果的目标选择函数，用于从额外卡组选择特殊召唤的怪兽
function c36614113.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足怪兽效果的发动条件，即额外卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36614113.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 设置怪兽效果的处理函数，用于执行特殊召唤并使召唤的怪兽效果无效
function c36614113.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的DD灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c36614113.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤，将选中的怪兽特殊召唤到场上
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 使特殊召唤的怪兽的特殊召唤效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤流程，结束本次特殊召唤操作
	Duel.SpecialSummonComplete()
end
