--Stake Your Soul！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡1只怪兽给对方观看才能发动。和给人观看的怪兽是卡名不同并是属性相同的1只「征服斗魂」怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
function c54562327.initial_effect(c)
	-- ①：把手卡1只怪兽给对方观看才能发动。和给人观看的怪兽是卡名不同并是属性相同的1只「征服斗魂」怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,54562327+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c54562327.cost)
	e1:SetTarget(c54562327.target)
	e1:SetOperation(c54562327.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡中未公开的怪兽，且卡组中存在可特殊召唤的对应「征服斗魂」怪兽
function c54562327.filter(c,e,tp)
	return not c:IsPublic() and c:IsType(TYPE_MONSTER)
		-- 检查卡组中是否存在可特殊召唤的、与展示怪兽属性相同且卡名不同的「征服斗魂」怪兽
		and Duel.IsExistingMatchingCard(c54562327.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 过滤卡组中与展示怪兽属性相同、卡名不同且可以特殊召唤的「征服斗魂」怪兽
function c54562327.spfilter(c,e,tp,pc)
	return c:IsSetCard(0x195) and c:IsAttribute(pc:GetAttribute()) and not c:IsCode(pc:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动代价的条件判断：检查自身怪兽区域是否有空位，以及手卡中是否存在可展示的怪兽
function c54562327.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足展示条件的怪兽
		and Duel.IsExistingMatchingCard(c54562327.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c54562327.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	e:SetLabelObject(g:GetFirst())
	-- 将选中的手卡怪兽给对方确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切玩家的手卡
	Duel.ShuffleHand(tp)
end
-- 效果的目标处理：检查是否已支付发动代价，并设置特殊召唤的操作信息
function c54562327.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组特殊召唤满足条件的「征服斗魂」怪兽，并注册结束阶段回到手卡的效果
function c54562327.activate(e,tp,eg,ep,ev,re,r,rp)
	local pc=e:GetLabelObject()
	-- 若怪兽区域无空位或展示的怪兽不存在，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or pc==nil then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只与展示怪兽属性相同、卡名不同的「征服斗魂」怪兽
	local tc=Duel.SelectMatchingCard(tp,c54562327.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,pc):GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(54562327,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段回到手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c54562327.thcon)
		e1:SetOperation(c54562327.thop)
		-- 注册在结束阶段将特殊召唤的怪兽送回手卡的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查特殊召唤的怪兽是否仍存在于场上且标记一致，若不一致则重置该效果
function c54562327.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(54562327)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行将特殊召唤的怪兽送回手卡的操作
function c54562327.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将特殊召唤的怪兽送回持有者的手卡
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
