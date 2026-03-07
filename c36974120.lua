--竜葬主－ヴィブリアル
-- 效果：
-- ①：怪兽在主要阶段从对方场上送去墓地的场合，可以把以这张卡在哪里存在来对应的以下效果发动（这个卡名的以下效果1回合各能使用1次）。
-- ●手卡：这张卡特殊召唤。
-- ●场上：对方场上1只效果怪兽的攻击力下降1500。这个效果让攻击力变成0的场合，可以再把那只怪兽破坏。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 初始化效果函数，注册3个效果：战斗时不会被破坏、手卡时特殊召唤、场上时对方怪兽攻击力下降1500并可破坏
function s.initial_effect(c)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：怪兽在主要阶段从对方场上送去墓地的场合，可以把以这张卡在哪里存在来对应的以下效果发动（这个卡名的以下效果1回合各能使用1次）。●手卡：这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ①：怪兽在主要阶段从对方场上送去墓地的场合，可以把以这张卡在哪里存在来对应的以下效果发动（这个卡名的以下效果1回合各能使用1次）。●场上：对方场上1只效果怪兽的攻击力下降1500。这个效果让攻击力变成0的场合，可以再把那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.adtg)
	e3:SetOperation(s.adop)
	c:RegisterEffect(e3)
end
-- 设置战斗时不会被破坏效果的目标范围，包括自己和自己战斗的怪兽
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 过滤条件：卡片从对方场上送去墓地
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(1-tp)
end
-- 判断是否在主要阶段且有对方怪兽送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and eg:IsExists(s.cfilter,1,nil,tp)
end
-- 设置特殊召唤的处理条件，检查是否有空位和卡片能否特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有空位可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，提示将要特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将手卡特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，将卡片以正面表示形式特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：表侧表示的效果怪兽
function s.adfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 设置场上效果的处理条件，检查对方场上是否有表侧表示的效果怪兽
function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有表侧表示的效果怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.adfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 执行场上效果操作，选择对方场上一只表侧表示的效果怪兽，使其攻击力下降1500，若攻击力变为0则可破坏
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上一只表侧表示的效果怪兽
	local g=Duel.SelectMatchingCard(tp,s.adfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		-- 显示选中怪兽的动画效果
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		local preatk=tc:GetAttack()
		-- 创建攻击力下降1500的效果并注册到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 判断攻击力是否为0且玩家确认是否破坏该怪兽
		if preatk~=0 and tc:IsAttack(0) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把那只怪兽破坏？"
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 以效果原因破坏目标怪兽
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
