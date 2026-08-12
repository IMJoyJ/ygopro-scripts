--百雷のサンダー・ドラゴン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只雷族怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把那些同名怪兽从自己墓地尽可能特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。只要这个效果特殊召唤的怪兽在怪兽区域存在，自己不是雷族怪兽不能特殊召唤。
function c82045034.initial_effect(c)
	-- ①：以自己墓地1只雷族怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把那些同名怪兽从自己墓地尽可能特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。只要这个效果特殊召唤的怪兽在怪兽区域存在，自己不是雷族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,82045034+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c82045034.target)
	e1:SetOperation(c82045034.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以特殊召唤的雷族怪兽
function c82045034.filter(c,e,tp)
	return c:IsRace(RACE_THUNDER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与对象选择判定
function c82045034.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c82045034.filter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在可以特殊召唤的雷族怪兽
		and Duel.IsExistingTarget(c82045034.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只雷族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c82045034.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤自己墓地中与目标怪兽同名且可以特殊召唤的怪兽
function c82045034.gfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的处理（特殊召唤目标怪兽，并可选择特殊召唤同名怪兽，同时施加离场除外和特殊召唤限制）
function c82045034.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍符合效果，并尝试将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
		-- 只要这个效果特殊召唤的怪兽在怪兽区域存在，自己不是雷族怪兽不能特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetRange(LOCATION_MZONE)
		e2:SetAbsoluteRange(tp,1,0)
		e2:SetTarget(c82045034.splimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成对象怪兽的特殊召唤
		Duel.SpecialSummonComplete()
		ft=ft-1
		-- 获取自己墓地中与已特殊召唤怪兽同名的怪兽组
		local g=Duel.GetMatchingGroup(c82045034.gfilter,tp,LOCATION_GRAVE,0,nil,e,tp,tc:GetCode())
		-- 判定墓地是否有同名怪兽、场上是否有空位，并询问玩家是否继续特殊召唤
		if g:GetCount()>0 and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(82045034,0)) then  --"是否特殊召唤同名怪兽？"
			-- 中断当前效果，使后续的特殊召唤处理与前一次特殊召唤不视为同时处理
			Duel.BreakEffect()
			ft=math.min(ft,g:GetCount())
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			-- 提示玩家选择要特殊召唤的同名怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,ft,ft,nil)
			-- 遍历选中的同名怪兽组
			for tc2 in aux.Next(sg) do
				-- 尝试将同名怪兽以表侧表示特殊召唤
				Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
				-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
				e3:SetValue(LOCATION_REMOVED)
				tc2:RegisterEffect(e3,true)
				-- 只要这个效果特殊召唤的怪兽在怪兽区域存在，自己不是雷族怪兽不能特殊召唤。
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_FIELD)
				e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e4:SetRange(LOCATION_MZONE)
				e4:SetAbsoluteRange(tp,1,0)
				e4:SetTarget(c82045034.splimit)
				e4:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc2:RegisterEffect(e4)
			end
			-- 完成同名怪兽的特殊召唤
			Duel.SpecialSummonComplete()
		end
	end
end
-- 限制自己不能特殊召唤雷族以外的怪兽
function c82045034.splimit(e,c)
	return not c:IsRace(RACE_THUNDER)
end
