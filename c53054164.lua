--わくわくメルフィーズ
-- 效果：
-- 兽族2星怪兽×2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。这个回合，自己的「童话动物」怪兽可以直接攻击。
-- ②：对方回合，以自己场上1只兽族超量怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以把最多有那只怪兽持有的超量素材数量的2星以下的兽族怪兽从自己墓地特殊召唤。
function c53054164.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加XYZ召唤手续，要求满足种族为兽族且等级为2的怪兽至少2只以上进行叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),2,2,nil,nil,99)
	-- ①：把这张卡1个超量素材取除才能发动。这个回合，自己的「童话动物」怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53054164,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c53054164.dacon)
	e1:SetCost(c53054164.dacost)
	e1:SetTarget(c53054164.datg)
	e1:SetOperation(c53054164.daop)
	c:RegisterEffect(e1)
	-- ②：对方回合，以自己场上1只兽族超量怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以把最多有那只怪兽持有的超量素材数量的2星以下的兽族怪兽从自己墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53054164,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,53054164)
	e2:SetCondition(c53054164.tecon)
	e2:SetTarget(c53054164.tetg)
	e2:SetOperation(c53054164.teop)
	c:RegisterEffect(e2)
end
-- 判断是否能进入战斗阶段
function c53054164.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 支付效果的费用，移除1个超量素材
function c53054164.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 判断是否已使用过①的效果
function c53054164.datg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若未使用过①的效果则可以发动
	if chk==0 then return Duel.GetFlagEffect(tp,53054164)==0 end
end
-- 使自己的「童话动物」怪兽在本回合可以直接攻击
function c53054164.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置效果使自己的「童话动物」怪兽在本回合可以直接攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置目标为属于「童话动物」卡组的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x146))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家的场上
	Duel.RegisterEffect(e1,tp)
	-- 记录该玩家已使用过①的效果，直到回合结束
	Duel.RegisterFlagEffect(tp,53054164,RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否为对方回合
function c53054164.tecon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家的对手
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤满足条件的怪兽：表侧表示、种族为兽族、类型为XYZ、可以送回额外卡组
function c53054164.tefilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
end
-- 设置选择目标，选择自己场上满足条件的1只怪兽作为对象
function c53054164.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53054164.tefilter(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c53054164.tefilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的1只怪兽作为对象
	local g=Duel.SelectTarget(tp,c53054164.tefilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示将目标怪兽送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 过滤满足条件的怪兽：等级不超过2、种族为兽族、可以特殊召唤
function c53054164.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果的发动，将目标怪兽送回额外卡组并可能从墓地特殊召唤怪兽
function c53054164.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local ct=tc:GetOverlayCount()
		-- 将目标怪兽送回额外卡组，并确认其在额外卡组
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA)
			-- 确保目标怪兽有超量素材且自己场上存在空位
			and ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查墓地中是否存在满足条件的怪兽
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c53054164.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
			-- 询问玩家是否要特殊召唤怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(53054164,2)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 获取自己场上的可用召唤位置数量
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			ct=math.min(ct,ft)
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的怪兽进行特殊召唤
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53054164.spfilter),tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
