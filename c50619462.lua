--烏合無象
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己场上把1只原本种族是兽族·兽战士族·鸟兽族的表侧表示怪兽送去墓地才能发动。原本种族和送去墓地的那只怪兽相同的1只怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能攻击，效果无效化，结束阶段破坏。
function c50619462.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己场上把1只原本种族是兽族·兽战士族·鸟兽族的表侧表示怪兽送去墓地才能发动。原本种族和送去墓地的那只怪兽相同的1只怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能攻击，效果无效化，结束阶段破坏。
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
-- 从自己场上选择作为发动代价的表侧表示怪兽的过滤函数：该怪兽必须表侧表示、原本种族为兽/兽战士/鸟兽、可作为cost送去墓地，且额外卡组存在能特殊召唤的相同原本种族怪兽。
function c50619462.cfilter(c,e,tp)
	local race=c:GetOriginalRace()
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
		and (race==RACE_WINDBEAST or race==RACE_BEAST or race==RACE_BEASTWARRIOR)
		-- 额外卡组检查：存在原本种族与候选cost怪兽相同、可被效果特殊召唤且能空出额外怪兽区的怪兽，确保发动时必有特殊召唤目标。
		and Duel.IsExistingMatchingCard(c50619462.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,race,c)
end
-- 额外卡组特殊召唤目标的过滤函数：检查额外卡组怪兽的原本种族与cost怪兽相同，能够被当前效果特殊召唤，并在cost怪兽离场后仍有额外区空格可用。
function c50619462.spfilter(c,e,tp,race,mc)
	-- 具体条件：原本种族一致、满足特殊召唤限制、有足够额外怪兽区空格。
	return c:GetOriginalRace()==race and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- spcost函数：由于实际送墓cost在target阶段进行，这里仅设置标记100并返回true，表示存在cost（通过sptg检查与支付）。
function c50619462.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- sptg函数：效果发动时先检查场上是否存在符合条件的表侧表示怪兽；若存在，则提示玩家选择1只送去墓地作为cost，将选择的怪兽送入墓地并保存其引用，然后设置特殊召唤操作信息。
function c50619462.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在至少1只满足cfilter条件（可作为cost且能引出额外召唤）的表侧表示怪兽。
		return Duel.IsExistingMatchingCard(c50619462.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	-- 显示选择提示，提示玩家选择要送去墓地的卡（用于发动cost）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己场上选择1只符合cfilter条件的表侧表示怪兽。
	local g=Duel.SelectMatchingCard(tp,c50619462.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的那只怪兽送去墓地，作为发动效果的费用（REASON_COST）。
	Duel.SendtoGrave(tc,REASON_COST)
	e:SetLabelObject(tc)
	-- 设置效果处理信息：本次效果将从额外卡组特殊召唤1只怪兽（类别为特殊召唤，目标区域为额外卡组）。此信息用于各类连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- spop函数：效果处理时，从额外卡组选择1只原本种族与cost怪兽相同的怪兽进行特殊召唤，并为其附加不能攻击、效果无效化、结束阶段破坏三个限制效果。
function c50619462.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race=e:GetLabelObject():GetOriginalRace()
	-- 显示选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只符合spfilter条件的怪兽（原本种族相同且可特殊召唤且有空格）。
	local g=Duel.SelectMatchingCard(tp,c50619462.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,race,nil)
	local tc=g:GetFirst()
	-- 若成功选择了怪兽且SpecialSummonStep特殊召唤步骤成功，则继续给该怪兽施加后续限制；否则跳过限制，随后完成特殊召唤处理。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:RegisterFlagEffect(50619462,RESET_EVENT+RESETS_STANDARD,0,1)
		-- “这个效果特殊召唤的怪兽不能攻击，效果无效化，结束阶段破坏。”中的“效果无效化”（使怪兽效果无效）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- “这个效果特殊召唤的怪兽不能攻击，效果无效化，结束阶段破坏。”中的“效果无效化”（使该怪兽的效果无效化且效果处理时也视为无效果）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- “这个效果特殊召唤的怪兽不能攻击，效果无效化，结束阶段破坏。”中的“不能攻击”和“结束阶段破坏”。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabelObject(tc)
		e3:SetCondition(c50619462.descon)
		e3:SetOperation(c50619462.desop)
		-- 将结束阶段破坏的诱发效果e3注册到当前玩家场上，使该效果在结束阶段时检查并破坏被特殊召唤的怪兽。
		Duel.RegisterEffect(e3,tp)
		-- “这个效果特殊召唤的怪兽不能攻击，效果无效化，结束阶段破坏。”中的“不能攻击”与“结束阶段破坏”。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CANNOT_ATTACK)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4,true)
	end
	-- 结束特殊召唤连锁处理，触发召唤成功时点，并完成整个特殊召唤过程。
	Duel.SpecialSummonComplete()
end
-- descon函数：结束阶段破坏效果的发动条件。若目标怪兽仍带有本次召唤的标记（50619462），则返回true执行破坏；若标记已因离场等原因消失，则重置该效果并返回false，避免错误破坏。
function c50619462.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(50619462)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- desop函数：结束阶段破坏效果的处理操作。获取保存的目标怪兽并将其破坏（效果破坏，且此效果无视免疫）。
function c50619462.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 执行破坏动作：将目标怪兽以效果原因（REASON_EFFECT）破坏。
	Duel.Destroy(tc,REASON_EFFECT)
end
