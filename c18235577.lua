--寂々虫
-- 效果：
-- 把这张卡从手卡送去墓地发动。场上存在的1只怪兽的等级直到结束阶段时下降1星。
function c18235577.initial_effect(c)
	-- 把这张卡从手卡送去墓地发动。场上存在的1只怪兽的等级直到结束阶段时下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18235577,0))  --"等级下降"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c18235577.lvcost)
	e1:SetTarget(c18235577.lvtg)
	e1:SetOperation(c18235577.lvop)
	c:RegisterEffect(e1)
end
-- 代价函数：检查此卡是否可作为代价从手卡送去墓地，若是则执行代价，将此卡从手卡送去墓地。
function c18235577.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡（效果持有者）从手卡送去墓地，作为发动效果的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数：筛选场上表侧表示且等级不低于2的怪兽，用于选择下降等级的对象。
function c18235577.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(2)
end
-- 目标选择阶段：确认是否存在合法对象，并提示玩家从双方怪兽区选择1只满足条件的表侧表示怪兽作为对象。
function c18235577.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c18235577.lvfilter(chkc) end
	-- 效果发动合法性检查：确认场上是否存在至少1只表侧表示且满足等级条件的怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c18235577.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 发送操作提示，要求玩家选择一张表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 实际选择：让当前玩家从双方主要怪兽区选择1只满足条件的表侧表示怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,c18235577.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：取得对象怪兽，若其仍与效果相关且为表侧表示，则赋予其直到结束阶段等级下降1星的持续效果。
function c18235577.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 场上存在的1只怪兽的等级直到结束阶段时下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
