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
		-- 将该连续效果注册到场上（全局，所有者0），使每次怪兽被破坏时都会执行 checkop1，记录是否有符合条件的命运女郎怪兽被破坏。
		Duel.RegisterEffect(ge1,0)
		-- 自己场上表侧表示存在的名字带有「命运女郎」的怪兽被破坏的回合才能发动。下次的自己的准备阶段时可以从手卡把名字带有「命运女郎」的怪兽最多2只特殊召唤。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c20057949.clear)
		-- 将该连续效果注册到场上（全局，所有者0），使每个抽卡阶段开始时都执行 clear，清空上一回合的“命运女郎被破坏”标记。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 遍历被破坏的怪兽组，若某张怪兽被破坏前位于主要怪兽区、破坏前为表侧表示、且破坏前是名字带有「命运女郎」（0x31）的怪兽，则把其破坏前控制者对应的标记设为 true，表示该玩家本回合有符合条件的命运女郎怪兽被破坏。
function c20057949.checkop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsPreviousPosition(POS_FACEUP) and tc:IsPreviousSetCard(0x31) then
			c20057949[tc:GetPreviousControler()]=true
		end
		tc=eg:GetNext()
	end
end
-- 在抽卡阶段开始时把玩家0和玩家1的标记都重置为 false，使“被破坏的回合”记录只保留到该回合结束，不会延续到之后回合。
function c20057949.clear(e,tp,eg,ep,ev,re,r,rp)
	c20057949[0]=false
	c20057949[1]=false
end
-- 发动条件判断：返回当前发动者 tp 是否被标记为本回合有符合条件的命运女郎怪兽被破坏；是才能发动本卡。
function c20057949.condition(e,tp,eg,ep,ev,re,r,rp)
	return c20057949[tp]
end
-- 发动时处理：为 tp 创建一个在准备阶段触发的延迟选发效果，用于在“自己的准备阶段”从手卡特殊召唤命运女郎怪兽；并根据发动时机的不同设置触发条件和重置次数，保证效果只在那一次准备阶段生效。
function c20057949.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的自己的准备阶段时可以从手卡把名字带有「命运女郎」的怪兽最多2只特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	-- 记录当前的回合数到效果 Label 中，供触发条件判断使用，以区分是同一个准备阶段还是下一次自己的准备阶段。
	e1:SetLabel(Duel.GetTurnCount())
	-- 若当前回合玩家是自己，且当前阶段在准备阶段之前（如抽卡阶段），则之后应在当前回合的准备阶段触发。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()<PHASE_STANDBY then
		e1:SetCondition(c20057949.spcon1)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	-- 否则，若当前回合玩家是自己（即当前不是准备阶段之前，可能正处于准备阶段或之后），则改为等待下一次自己的准备阶段，并设置重置次数以经过需要的结束阶段。
	elseif Duel.GetTurnPlayer()==tp then
		e1:SetCondition(c20057949.spcon2)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetCondition(c20057949.spcon2)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	e1:SetTarget(c20057949.sptg1)
	e1:SetOperation(c20057949.spop1)
	-- 将延迟效果注册到场上，由 tp 作为该效果的控制者；这样在自己的准备阶段时点会检查并触发特殊召唤。
	Duel.RegisterEffect(e1,tp)
end
-- spcon1：触发条件为当前回合数等于效果记录回合数且当前回合玩家是自己；用于在自己回合的准备阶段之前发动时，在当前回合的准备阶段触发。
function c20057949.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 实际判断：当前回合数等于记录回合数，且当前回合玩家等于效果控制者 tp。
	return Duel.GetTurnCount()==e:GetLabel() and Duel.GetTurnPlayer()==tp
end
-- spcon2：触发条件为当前回合数不等于效果记录回合数且当前回合玩家是自己；用于等待下一次自己的准备阶段时触发。
function c20057949.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 实际判断：当前回合数不等于记录回合数，且当前回合玩家等于效果控制者 tp。
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==tp
end
-- 特殊召唤怪兽的过滤条件：手牌中的卡是「命运女郎」怪兽，且能够被当前效果正常特殊召唤（接受召唤条件与苏生限制检查）。
function c20057949.filter(c,e,tp)
	return c:IsSetCard(0x31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤的发动合法性/目标处理：检查是否满足“自己场上有可用主要怪兽区”且“手牌存在至少1只符合条件的命运女郎怪兽”；满足时效果可以发动。
function c20057949.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查第一部分：自己场上存在至少1个可用的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 合法性检查第二部分：手牌中存在至少1张满足 filter 的「命运女郎」怪兽；end 结束合法性检查。
		and Duel.IsExistingMatchingCard(c20057949.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：将本次效果标记为从手卡进行特殊召唤；由于具体数量在处理时才确定，先按至少1只登记，供其他卡进行效果响应和检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤处理：取得可用主要怪兽区数量并限制最多2只；若当前玩家受青眼精灵龙效果影响，则最多只能特殊召唤1只；选择手牌中相应数量的「命运女郎」怪兽，以表侧表示特殊召唤到自己场上。
function c20057949.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得 tp 场上可用的主要怪兽区数量，作为本次最多可特殊召唤的怪兽数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 显示选择框提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让 tp 从手牌中选择1到ft张符合条件的「命运女郎」怪兽；ft 为当前可用特殊召唤数量上限，且被青眼精灵龙效果限制时至多为1。
	local g=Duel.SelectMatchingCard(tp,c20057949.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	-- 将选择到的怪兽以表侧攻击表示特殊召唤到 tp 场上；nocheck/nolimit 为 false，因此会正常检查召唤条件和苏生限制。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
