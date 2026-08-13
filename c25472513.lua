--天輪の双星道士
-- 效果：
-- 调整＋调整以外的怪兽1只
-- 「天轮之双星道士」的效果1回合只能使用1次。
-- ①：这张卡同调召唤成功时才能发动。从自己的手卡·墓地选最多4只调整以外的2星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
function c25472513.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整 + 调整以外的怪兽1只。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- 「天轮之双星道士」的效果1回合只能使用1次。①：这张卡同调召唤成功时才能发动。从自己的手卡·墓地选最多4只调整以外的2星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
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
-- 效果发动条件：这张卡是以同调召唤方式特殊召唤成功的场合才能发动。
function c25472513.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 特殊召唤对象卡片的筛选条件：等级为2、不是调整怪兽、且可以被表侧守备表示特殊召唤。
function c25472513.spfilter(c,e,tp)
	return c:IsLevel(2) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动时的合法性检查：自己主要怪兽区有空位，且手卡·墓地存在至少1只满足条件的2星调整以外怪兽。
function c25472513.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否有空余的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己手卡·墓地中是否存在至少1只满足特殊召唤条件的等级2调整以外怪兽。
		and Duel.IsExistingMatchingCard(c25472513.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 将本效果的操作信息登记为特殊召唤，预定从手卡·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：选择最多4只符合条件的怪兽守备表示特殊召唤；这些怪兽的效果无效化；之后给自己附加“不是同调怪兽不能从额外卡组特殊召唤”的自肃。
function c25472513.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算可特殊召唤数量上限：取自己场上可用主要怪兽区域数与4的较小值。
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),4)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft>0 then
		-- 弹出选择提示，让玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己手卡·墓地选择1~ft只满足条件的怪兽（选择墓地卡时需排除王家长眠之谷的影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25472513.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ft,nil,e,tp)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			while tc do
				-- 将选择的怪兽以表侧守备表示特殊召唤（作为连锁处理中的一步）。
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
				-- 这个效果特殊召唤的怪兽的效果无效化。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 这个效果特殊召唤的怪兽的效果无效化。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
				tc=g:GetNext()
			end
			-- 完成这一连锁中的特殊召唤处理。
			Duel.SpecialSummonComplete()
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c25472513.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述自肃效果注册到当前玩家，持续到回合结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的判定条件：要特殊召唤的卡不是同调怪兽，并且是从额外卡组特殊召唤。
function c25472513.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
