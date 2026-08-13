--アーマード・ビットロン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从卡组把「铠装比特机灵」以外的1只电子界族怪兽效果无效特殊召唤。这个回合，自己不是电子界族怪兽不能特殊召唤。
-- ②：这张卡在墓地存在，自己场上的连接3以上的连接怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c29374928.initial_effect(c)
	-- ①：把这张卡解放才能发动。从卡组把「铠装比特机灵」以外的1只电子界族怪兽效果无效特殊召唤。这个回合，自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29374928,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,29374928)
	e1:SetCost(c29374928.spcost)
	e1:SetTarget(c29374928.sptg)
	e1:SetOperation(c29374928.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上的连接3以上的连接怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29374928,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,29374929)
	e2:SetCondition(c29374928.spcon2)
	e2:SetTarget(c29374928.sptg2)
	e2:SetOperation(c29374928.spop2)
	c:RegisterEffect(e2)
end
-- 发动①的代价处理：检查这张卡是否满足可解放条件，若满足则将其解放作为发动代价。
function c29374928.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 以解放为代价将这张卡解放，送入墓地。
	Duel.Release(c,REASON_COST)
end
-- 定义①特殊召唤的筛选条件：选择卡组中种族为电子界、卡名不是「铠装比特机灵」且能被特殊召唤的怪兽。
function c29374928.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and not c:IsCode(29374928) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①发动时的目标设定：确认解放后我方怪兽区有空位、卡组存在符合条件的怪兽，并向系统登记本次特殊召唤的操作信息。
function c29374928.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果发动时（chk==0）检查：解放后是否仍有可用怪兽区，且卡组是否存在符合条件的电子界族怪兽。
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c29374928.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理时的操作信息：从卡组特殊召唤1只怪兽，用于后续效果检测与处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：如果场上还有空位，则从卡组选择1只符合条件的电子界族怪兽进行表侧表示特殊召唤，并使其效果无效化；最后给控制者附加本回合只能特殊召唤电子界族怪兽的自肃效果。
function c29374928.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认自己场上是否有可用的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出选择提示，让玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中筛选并选择1只满足spfilter条件的电子界族怪兽。
		local g=Duel.SelectMatchingCard(tp,c29374928.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 若选出了怪兽，则以表侧表示执行特殊召唤步骤（由系统检查召唤条件与苏生限制）。
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 从卡组把「铠装比特机灵」以外的1只电子界族怪兽效果无效特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 这个回合，自己不是电子界族怪兽不能特殊召唤。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
		-- 完成上述特殊召唤步骤，使特殊召唤的怪兽正式上场。
		Duel.SpecialSummonComplete()
	end
	-- 这个回合，自己不是电子界族怪兽不能特殊召唤。②：这张卡在墓地存在，自己场上的连接3以上的连接怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c29374928.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果（本回合只能特殊召唤电子界族怪兽）注册到场上，影响效果发动者。
	Duel.RegisterEffect(e3,tp)
end
-- 自肃的判定函数：当将要特殊召唤的怪兽不是电子界族时，禁止该特殊召唤。
function c29374928.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- ②的触发条件过滤：判断被破坏的怪兽是否为我方场上表侧表示的连接3以上的连接怪兽，且破坏原因是战斗破坏或由对方的效果破坏。
function c29374928.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0 and c:IsLinkAbove(3)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- ②的发动条件：破坏怪兽集合中存在满足cfilter条件的怪兽，且本卡不在被破坏的集合中（即不是这张卡自身被破坏）。
function c29374928.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29374928.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②发动时的目标确认：检查自己怪兽区有空位，且这张卡可以被特殊召唤。
function c29374928.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁的操作信息：将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则将其特殊召唤；特殊召唤成功时，给这张卡附加‘从场上离开的场合除外’的效果。
function c29374928.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤；若成功（返回非0）则继续设置离场除外效果。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
