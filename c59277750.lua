--敵襲警報－イエローアラート－
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方怪兽的攻击宣言时才能发动。从手卡把1只怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，对方不能选择其他怪兽作为攻击对象。这个效果特殊召唤的怪兽在战斗阶段结束时回到持有者手卡。
function c59277750.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。从手卡把1只怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，对方不能选择其他怪兽作为攻击对象。这个效果特殊召唤的怪兽在战斗阶段结束时回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,59277750+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c59277750.condition)
	e1:SetTarget(c59277750.target)
	e1:SetOperation(c59277750.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件是否为对方怪兽发动攻击宣言。
function c59277750.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local a=Duel.GetAttacker()
	return a:IsControler(1-tp)
end
-- 过滤手卡中可以进行特殊召唤的怪兽。
function c59277750.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查怪兽区域空位及手卡中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息。
function c59277750.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在至少1只可以特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c59277750.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的核心逻辑，包括从手卡特殊召唤怪兽、添加攻击限制效果以及注册回合结束时回手卡的效果。
function c59277750.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，若自己场上已无可用怪兽区域，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足特殊召唤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c59277750.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上（分步处理）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，对方不能选择其他怪兽作为攻击对象。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c59277750.atlimit)
		tc:RegisterEffect(e1,true)
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(59277750,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在战斗阶段结束时回到持有者手卡。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabel(fid)
		e2:SetLabelObject(tc)
		e2:SetCondition(c59277750.retcon)
		e2:SetOperation(c59277750.retop)
		-- 注册在战斗阶段结束时将怪兽送回手卡的效果。
		Duel.RegisterEffect(e2,tp)
		-- 完成特殊召唤的后续处理。
		Duel.SpecialSummonComplete()
	end
end
-- 限制对方只能选择该特殊召唤的怪兽作为攻击对象（不能选择其他怪兽）。
function c59277750.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 检查该怪兽是否仍带有特定的标记，若标记不匹配则重置该效果，否则允许执行回手卡操作。
function c59277750.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(59277750)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行将该怪兽送回持有者手卡的操作。
function c59277750.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将该怪兽送回持有者的手卡。
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
