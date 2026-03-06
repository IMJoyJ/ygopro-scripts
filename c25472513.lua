--天輪の双星道士
-- 效果：
-- 调整＋调整以外的怪兽1只
-- 「天轮之双星道士」的效果1回合只能使用1次。
-- ①：这张卡同调召唤成功时才能发动。从自己的手卡·墓地选最多4只调整以外的2星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
function c25472513.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功时才能发动。从自己的手卡·墓地选最多4只调整以外的2星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25472513,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,25472513)
	e1:SetCondition(c25472513.spcon)
	e1:SetTarget(c25472513.sptg)
	e1:SetOperation(c25472513.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：此卡必须是同调召唤成功
function c25472513.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的2星调整以外怪兽
function c25472513.spfilter(c,e,tp)
	return c:IsLevel(2) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果发动时的处理条件：确认场上是否有满足条件的怪兽可特殊召唤
function c25472513.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手牌或墓地是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(c25472513.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理信息：特殊召唤1只以上调整以外的2星怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数：特殊召唤满足条件的怪兽并使其效果无效
function c25472513.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算最多可特殊召唤的怪兽数量，最多为4只
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),4)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25472513.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ft,nil,e,tp)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			while tc do
				-- 特殊召唤一张怪兽到守备表示
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
				-- 使特殊召唤的怪兽效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 使特殊召唤的怪兽效果无效化
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
				tc=g:GetNext()
			end
			-- 完成特殊召唤步骤
			Duel.SpecialSummonComplete()
		end
	end
	-- 设置直到回合结束时自己不能从额外卡组特殊召唤非同调怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c25472513.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非同调怪兽
function c25472513.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
