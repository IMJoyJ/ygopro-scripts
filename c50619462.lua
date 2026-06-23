--烏合無象
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己场上把1只原本种族是兽族·兽战士族·鸟兽族的表侧表示怪兽送去墓地才能发动。原本种族和送去墓地的那只怪兽相同的1只怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能攻击，效果无效化，结束阶段破坏。
function c50619462.initial_effect(c)
	-- 创建效果，设置为发动时点，只能发动一次，需要支付费用，目标为特殊召唤，效果处理为spop
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,50619462+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c50619462.spcost)
	e1:SetTarget(c50619462.sptg)
	e1:SetOperation(c50619462.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查场上是否有满足条件的怪兽（正面表示、可送入墓地、种族为鸟兽/兽/兽战士族）且额外卡组有相同种族可特殊召唤的怪兽
function c50619462.cfilter(c,e,tp)
	local race=c:GetOriginalRace()
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
		and (race==RACE_WINDBEAST or race==RACE_BEAST or race==RACE_BEASTWARRIOR)
		-- 检查额外卡组是否存在与送去墓地怪兽种族相同的怪兽
		and Duel.IsExistingMatchingCard(c50619462.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,race,c)
end
-- 特殊召唤过滤函数，检查额外卡组中是否有满足条件的怪兽（种族相同、可特殊召唤、场上空位足够）
function c50619462.spfilter(c,e,tp,race,mc)
	-- 检查额外卡组中是否有满足条件的怪兽（种族相同、可特殊召唤、场上空位足够）
	return c:GetOriginalRace()==race and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置发动费用，将标签设为100表示已支付费用
function c50619462.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 设置发动时点处理，检查是否满足发动条件并选择送去墓地的怪兽
function c50619462.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在满足条件的怪兽
		return Duel.IsExistingMatchingCard(c50619462.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c50619462.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽送去墓地作为费用
	Duel.SendtoGrave(tc,REASON_COST)
	e:SetLabelObject(tc)
	-- 设置操作信息，表示将特殊召唤一张来自额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果发动后的操作，选择并特殊召唤怪兽，并附加效果
function c50619462.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race=e:GetLabelObject():GetOriginalRace()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c50619462.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,race,nil)
	local tc=g:GetFirst()
	-- 尝试特殊召唤选中的怪兽
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:RegisterFlagEffect(50619462,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽不能发动效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 设置结束阶段破坏效果，使特殊召唤的怪兽在结束阶段被破坏
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabelObject(tc)
		e3:SetCondition(c50619462.descon)
		e3:SetOperation(c50619462.desop)
		-- 注册结束阶段破坏效果
		Duel.RegisterEffect(e3,tp)
		-- 使特殊召唤的怪兽不能攻击
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CANNOT_ATTACK)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断是否需要破坏特殊召唤的怪兽
function c50619462.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(50619462)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 执行破坏操作
function c50619462.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽以效果原因破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
