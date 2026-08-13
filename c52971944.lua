--火遁封印式
-- 效果：
-- 1回合1次，可以把自己墓地1只炎属性怪兽从游戏中除外，选择对方墓地1张卡从游戏中除外。
function c52971944.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把自己墓地1只炎属性怪兽从游戏中除外，选择对方墓地1张卡从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52971944,1))  --"除外"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCost(c52971944.cost)
	e2:SetTarget(c52971944.target)
	e2:SetOperation(c52971944.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查自己墓地中的卡是否为炎属性怪兽，且可作为代价被除外。
function c52971944.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：从自己墓地选择1只符合条件的炎属性怪兽除外作为发动代价；若不存在则不能发动。
function c52971944.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：自己墓地存在至少1只符合条件的炎属性怪兽（可作为除外代价）时才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c52971944.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地的符合条件的炎属性怪兽中选择1张（且只能选1张）作为代价。
	local cg=Duel.SelectMatchingCard(tp,c52971944.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以表侧表示除外，作为发动代价（REASON_COST）。
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
end
-- 取对象效果的目标处理：选择对方墓地1张可以被除外的卡作为对象，并设置操作信息。
function c52971944.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 目标合法性检查：对方墓地存在至少1张可以被除外的卡时才可发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1张可以被除外的卡作为效果对象，并同时登记为当前连锁的处理对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：本连锁将以对方墓地的1张卡为对象进行除外处理（CATEGORY_REMOVE，对象为g，数量1，对方为持有者，位置为墓地）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理：取得对象卡，若其仍与本效果相关（未离场或未被替代处理），则将其表侧表示除外。
function c52971944.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时应除外的对象卡（即发动时选择的那张对方墓地卡片）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片以表侧表示除外（REASON_EFFECT，即效果处理导致的除外）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
