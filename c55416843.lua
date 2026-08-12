--蛮族の狂宴LV5
-- 效果：
-- ①：从自己的手卡·墓地选最多2只战士族·5星怪兽特殊召唤。这个效果特殊召唤的怪兽效果无效化，这个回合不能攻击。
function c55416843.initial_effect(c)
	-- ①：从自己的手卡·墓地选最多2只战士族·5星怪兽特殊召唤。这个效果特殊召唤的怪兽效果无效化，这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c55416843.target)
	e1:SetOperation(c55416843.operation)
	c:RegisterEffect(e1)
end
-- 过滤出等级为5、战士族且可以特殊召唤的怪兽
function c55416843.filter(c,e,tp)
	return c:IsLevel(5) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检测，判断自己场上是否有空位，且手卡或墓地是否存在至少1只满足条件的怪兽
function c55416843.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己的手卡或墓地是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c55416843.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示该效果包含从手卡或墓地特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理的执行逻辑，计算可召唤数量，选择怪兽并特殊召唤，同时适用效果无效和不能攻击的限制
function c55416843.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算当前可特殊召唤的最大数量（怪兽区域空位数与2的较小值）
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	if ft<=0 then return end
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1到ft张满足条件的怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c55416843.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			-- 将选中的怪兽以表侧表示特殊召唤到场上（分解步骤）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽效果无效化
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果特殊召唤的怪兽效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 这个回合不能攻击
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_ATTACK)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			tc=g:GetNext()
		end
		-- 完成特殊召唤的流程，处理特殊召唤成功的时点
		Duel.SpecialSummonComplete()
	end
end
