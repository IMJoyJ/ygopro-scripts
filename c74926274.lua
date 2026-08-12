--ペンデュラム・アライズ
-- 效果：
-- 「灵摆显现」在1回合只能发动1张。
-- ①：把自己场上1只怪兽送去墓地才能发动。和那只怪兽的原本等级相同等级的1只灵摆怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c74926274.initial_effect(c)
	-- ①：把自己场上1只怪兽送去墓地才能发动。和那只怪兽的原本等级相同等级的1只灵摆怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,74926274+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c74926274.cost)
	e1:SetTarget(c74926274.target)
	e1:SetOperation(c74926274.activate)
	c:RegisterEffect(e1)
end
-- Cost检测与处理函数，由于需要把场上的怪兽送去墓地作为Cost，这里先设置Label为100用于在target中进行检测
function c74926274.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤函数：过滤自己场上可以作为Cost送去墓地，且其原本等级在卡组中有对应等级的灵摆怪兽可以特殊召唤的怪兽
function c74926274.filter(c,e,tp,ft)
	local lv=c:GetOriginalLevel()
	return lv>0 and c:IsAbleToGraveAsCost() and (ft>0 or c:GetSequence()<5)
		-- 检查卡组中是否存在至少1只与该怪兽原本等级相同的可特殊召唤的灵摆怪兽
		and Duel.IsExistingMatchingCard(c74926274.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,lv)
end
-- 过滤函数：过滤卡组中等级为lv且可以特殊召唤的灵摆怪兽
function c74926274.spfilter(c,e,tp,lv)
	return c:IsType(TYPE_PENDULUM) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动准备（Target）函数：验证发动条件，选择作为Cost送去墓地的怪兽并将其送去墓地，保存其原本等级，并声明特殊召唤的操作信息
function c74926274.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在满足送去墓地Cost条件的怪兽（若怪兽区已满，则必须选择前场怪兽区即Sequence < 5的怪兽送去墓地以腾出格子）
		return ft>-1 and Duel.IsExistingMatchingCard(c74926274.filter,tp,LOCATION_MZONE,0,1,nil,e,tp,ft)
	end
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1只自己场上满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c74926274.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ft)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
	-- 将选择的怪兽作为发动代价（Cost）送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	-- 设置当前连锁的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（Activate）函数：从卡组特殊召唤对应等级的灵摆怪兽，并注册结束阶段将其破坏的效果
function c74926274.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足等级条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c74926274.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	local tc=g:GetFirst()
	-- 若成功将该怪兽以表侧表示特殊召唤到自己场上
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(74926274,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c74926274.descon)
		e1:SetOperation(c74926274.desop)
		-- 将该结束阶段破坏的效果注册给全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 破坏效果的触发条件函数：检查被特殊召唤的怪兽是否仍在场上且标记（FieldID）一致，若不一致则重置该效果
function c74926274.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(74926274)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 破坏效果的执行函数：破坏被特殊召唤的怪兽
function c74926274.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将该怪兽破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
