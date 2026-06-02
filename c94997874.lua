--聖占術姫タロットレイ
-- 效果：
-- 「圣占术的仪式」降临。这个卡名的①②的效果1回合只能有1次使用其中任意1个，对方回合也能发动。
-- ①：以场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示。
-- ②：以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ③：自己结束阶段才能发动。从自己的手卡·墓地选1只反转怪兽里侧守备表示特殊召唤。
function c94997874.initial_effect(c)
	-- 在卡片关联代码列表中添加「圣占术的仪式」的卡片密码
	aux.AddCodeList(c,30392583)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，对方回合也能发动。①：以场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94997874,0))  --"变成表侧攻击表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_STANDBY_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,94997874)
	e1:SetTarget(c94997874.postg)
	e1:SetOperation(c94997874.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(94997874,1))  --"变成里侧守备表示"
	e2:SetTarget(c94997874.postg2)
	e2:SetOperation(c94997874.posop2)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段才能发动。从自己的手卡·墓地选1只反转怪兽里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94997874,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c94997874.spcon)
	e3:SetTarget(c94997874.sptg)
	e3:SetOperation(c94997874.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动准备与目标选择（Target）函数
function c94997874.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFacedown() end
	-- 效果发动的可行性检测：检测场上是否存在里侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示发动了“变成表侧攻击表示”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从自己或对方场上选择1只里侧表示怪兽作为效果处理的目标（取对象）
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息：包含改变1个怪兽表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果①的效果处理（Operation）函数
function c94997874.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽的表示形式变更为表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
-- 效果②表示形式变更对象的过滤条件（表侧表示且可以变成里侧的怪兽）
function c94997874.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果②的发动准备与目标选择（Target）函数
function c94997874.postg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c94997874.posfilter(chkc) end
	-- 效果发动的可行性检测：检测场上是否存在符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c94997874.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示发动了“变成里侧守备表示”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择1只符合条件的表侧表示怪兽作为等级/表示形式改变的对象（取对象）
	local g=Duel.SelectTarget(tp,c94997874.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息：包含改变1个怪兽表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 向对方玩家提示发动了“变成里侧守备表示”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果②的效果处理（Operation）函数
function c94997874.posop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽的表示形式变更为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 效果③的发动条件判定函数
function c94997874.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是自己的结束阶段才能发动
	return Duel.GetTurnPlayer()==tp
end
-- 效果③特殊召唤对象的过滤条件（手卡或墓地中的反转怪兽）
function c94997874.spfilter(c,e,tp)
	local proc=c:IsCode(42932862) and e:GetHandler():IsCode(94997874)
	return c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,proc,proc,POS_FACEDOWN_DEFENSE)
end
-- 效果③的发动准备与目标选择（Target）函数
function c94997874.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动的可行性检测：检测自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己手卡或墓地是否存在至少1只满足特殊召唤条件的反转怪兽
		and Duel.IsExistingMatchingCard(c94997874.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了“特殊召唤”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁信息：包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果③的效果处理（Operation）函数
function c94997874.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无可用怪兽区，则效果不予处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地选择1只满足特殊召唤条件的反转怪兽（受王家长眠之谷限制）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c94997874.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		local proc=tc:IsCode(42932862) and e:GetHandler():IsCode(94997874)
		-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,proc,proc,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家确认以里侧特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,tc)
		if proc then tc:CompleteProcedure() end
	end
end
