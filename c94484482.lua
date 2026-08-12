--スリップ・サモン
-- 效果：
-- 对方对怪兽的召唤·反转召唤·特殊召唤成功时才能发动。从手卡把1只4星以下的怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段时回到持有者手卡。
function c94484482.initial_effect(c)
	-- 对方对怪兽的召唤·反转召唤·特殊召唤成功时才能发动。从手卡把1只4星以下的怪兽表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c94484482.condition)
	e1:SetTarget(c94484482.target)
	e1:SetOperation(c94484482.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c94484482.condition2)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 检查召唤怪兽的玩家是否为对方
function c94484482.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤出由对方特殊召唤的怪兽
function c94484482.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 检查特殊召唤的怪兽中是否存在由对方特殊召唤的怪兽
function c94484482.condition2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c94484482.cfilter,1,nil,tp)
end
-- 过滤手卡中等级4以下且可以表侧守备表示特殊召唤的怪兽
function c94484482.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 检查怪兽区域空位数以及手卡中是否存在满足条件的怪兽，并设置特殊召唤的操作信息
function c94484482.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c94484482.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤效果，并在特殊召唤成功时注册结束阶段回到持有者手卡的效果
function c94484482.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c94484482.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功将选中的怪兽以表侧守备表示特殊召唤
	if tc and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(94484482,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段时回到持有者手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c94484482.retcon)
		e1:SetOperation(c94484482.retop)
		-- 注册该全局延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查该怪兽是否仍带有对应的标记，若标记失效则重置该效果
function c94484482.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(94484482)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行将该怪兽送回持有者手卡的操作
function c94484482.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将特殊召唤的怪兽因效果送回持有者的手卡
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
