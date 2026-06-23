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
-- 支付1点费用：将自身解放
function c29374928.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 将自身从场上解放作为费用
	Duel.Release(c,REASON_COST)
end
-- 过滤函数：选择满足种族为电子界、不是自身、可以特殊召唤的卡
function c29374928.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and not c:IsCode(29374928) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理：确认场上是否有空怪兽区且卡组是否存在满足条件的卡
function c29374928.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足发动条件：确认场上是否有空怪兽区且卡组是否存在满足条件的卡
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(c29374928.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择并特殊召唤1只满足条件的电子界族怪兽，使其效果无效并设置不能在本回合特殊召唤非电子界族怪兽
function c29374928.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤条件：确认场上是否有空怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足条件的电子界族怪兽
		local g=Duel.SelectMatchingCard(tp,c29374928.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 判断是否成功特殊召唤：若成功则设置效果无效和效果禁止
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 设置效果：使特殊召唤的怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 设置效果：使特殊召唤的怪兽效果禁止
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
		-- 完成特殊召唤步骤
		Duel.SpecialSummonComplete()
	end
	-- 设置效果：本回合不能特殊召唤非电子界族怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c29374928.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果：使本回合不能特殊召唤非电子界族怪兽
	Duel.RegisterEffect(e3,tp)
end
-- 限制函数：判断是否为电子界族怪兽
function c29374928.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- 过滤函数：判断被破坏的连接怪兽是否满足条件（连接3以上、战斗或对方效果破坏）
function c29374928.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0 and c:IsLinkAbove(3)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 条件函数：判断是否有满足条件的怪兽被破坏且不是自身
function c29374928.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29374928.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果发动时的处理：确认场上是否有空怪兽区且自身可以特殊召唤
function c29374928.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：确认场上是否有空怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：准备特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身特殊召唤并设置其离开场时被除外
function c29374928.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 判断是否成功特殊召唤：若成功则设置其离开场时被除外
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置效果：使特殊召唤的怪兽离开场时被除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
