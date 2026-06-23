--フォーチュン・インハーリット
-- 效果：
-- 自己场上表侧表示存在的名字带有「命运女郎」的怪兽被破坏的回合才能发动。下次的自己的准备阶段时可以从手卡把名字带有「命运女郎」的怪兽最多2只特殊召唤。
function c20057949.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「命运女郎」的怪兽被破坏的回合才能发动。下次的自己的准备阶段时可以从手卡把名字带有「命运女郎」的怪兽最多2只特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c20057949.condition)
	e1:SetOperation(c20057949.activate)
	c:RegisterEffect(e1)
	if not c20057949.global_check then
		c20057949.global_check=true
		c20057949[0]=false
		c20057949[1]=false
		-- 自己场上表侧表示存在的名字带有「命运女郎」的怪兽被破坏的回合才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(c20057949.checkop1)
		-- 注册一个全局的破坏时点效果，用于记录破坏的怪兽是否为命运女郎族
		Duel.RegisterEffect(ge1,0)
		-- 下次的自己的准备阶段时可以从手卡把名字带有「命运女郎」的怪兽最多2只特殊召唤。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c20057949.clear)
		-- 注册一个全局的准备阶段开始时点效果，用于重置记录标志
		Duel.RegisterEffect(ge2,0)
	end
end
-- 当有怪兽被破坏时，检查该怪兽是否为名字带有「命运女郎」的怪兽且在场上正面表示被破坏，则记录该怪兽的控制者为已触发状态
function c20057949.checkop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsPreviousPosition(POS_FACEUP) and tc:IsPreviousSetCard(0x31) then
			c20057949[tc:GetPreviousControler()]=true
		end
		tc=eg:GetNext()
	end
end
-- 准备阶段开始时，将记录标志清空，防止重复触发
function c20057949.clear(e,tp,eg,ep,ev,re,r,rp)
	c20057949[0]=false
	c20057949[1]=false
end
-- 判断是否为已触发状态，即自己场上表侧表示存在的名字带有「命运女郎」的怪兽被破坏的回合
function c20057949.condition(e,tp,eg,ep,ev,re,r,rp)
	return c20057949[tp]
end
-- 创建一个在准备阶段触发的效果，用于特殊召唤名字带有「命运女郎」的怪兽
function c20057949.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的自己的准备阶段时可以从手卡把名字带有「命运女郎」的怪兽最多2只特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	-- 记录当前回合数，用于判断是否为准备阶段触发的回合
	e1:SetLabel(Duel.GetTurnCount())
	-- 如果当前是自己的回合且当前阶段在准备阶段之前，则设置条件为spcon1
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()<PHASE_STANDBY then
		e1:SetCondition(c20057949.spcon1)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	-- 如果当前是自己的回合且当前阶段在准备阶段之后，则设置条件为spcon2
	elseif Duel.GetTurnPlayer()==tp then
		e1:SetCondition(c20057949.spcon2)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetCondition(c20057949.spcon2)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	e1:SetTarget(c20057949.sptg1)
	e1:SetOperation(c20057949.spop1)
	-- 将该效果注册给玩家tp，使其在准备阶段触发
	Duel.RegisterEffect(e1,tp)
end
-- 准备阶段触发时，判断是否为当前回合且为准备阶段开始时
function c20057949.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合且为准备阶段开始时
	return Duel.GetTurnCount()==e:GetLabel() and Duel.GetTurnPlayer()==tp
end
-- 准备阶段触发时，判断是否为非当前回合且为准备阶段开始时
function c20057949.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为非当前回合且为准备阶段开始时
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==tp
end
-- 过滤函数，筛选名字带有「命运女郎」且可以特殊召唤的怪兽
function c20057949.filter(c,e,tp)
	return c:IsSetCard(0x31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤目标，检查是否有满足条件的怪兽
function c20057949.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(c20057949.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作，选择并特殊召唤名字带有「命运女郎」的怪兽
function c20057949.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家tp的怪兽区域空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c20057949.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	-- 将选中的怪兽特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
