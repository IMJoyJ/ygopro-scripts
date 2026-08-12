--ライトロードの神域
-- 效果：
-- ①：1回合1次，把手卡1只「光道」怪兽送去墓地，以那只怪兽以外的自己墓地1只「光道」怪兽为对象才能发动。作为对象的怪兽加入手卡。
-- ②：只要这张卡在魔法与陷阱区域存在，每次从自己卡组有卡被送去墓地，给这张卡放置1个光指示物。
-- ③：自己场上的「光道」卡被效果破坏的场合，可以作为代替把破坏的「光道」卡每1张2个自己场上的光指示物取除。
function c52665542.initial_effect(c)
	c:EnableCounterPermit(0x5)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把手卡1只「光道」怪兽送去墓地，以那只怪兽以外的自己墓地1只「光道」怪兽为对象才能发动。作为对象的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52665542,0))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c52665542.cost)
	e2:SetTarget(c52665542.target)
	e2:SetOperation(c52665542.operation)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，每次从自己卡组有卡被送去墓地，给这张卡放置1个光指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c52665542.accon)
	e3:SetOperation(c52665542.acop)
	c:RegisterEffect(e3)
	-- ③：自己场上的「光道」卡被效果破坏的场合，可以作为代替把破坏的「光道」卡每1张2个自己场上的光指示物取除。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(c52665542.destg)
	e4:SetValue(c52665542.value)
	e4:SetOperation(c52665542.desop)
	c:RegisterEffect(e4)
end
c52665542.mentioned_counter={
	[0x5]=true,
}
-- 代价过滤器：筛选可以作为代价送去墓地的「光道」怪兽。
function c52665542.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x38) and c:IsAbleToGraveAsCost()
end
-- 发动代价处理：确认手卡存在可作为代价的「光道」怪兽，让玩家选择1只送去墓地，并记录该怪兽供后续对象选择排除。
function c52665542.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己手卡存在至少1只可以作为代价送去墓地的「光道」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c52665542.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 取得自己手卡全部的卡。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 向玩家显示「请选择要送去墓地的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:FilterSelect(tp,c52665542.costfilter,1,1,nil)
	e:SetLabelObject(sg:GetFirst())
	-- 把选择的「光道」怪兽作为代价送去墓地。
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 对象过滤器：筛选可以加入手卡的「光道」怪兽。
function c52665542.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x38) and c:IsAbleToHand()
end
-- 对象选择处理：确认墓地存在可作为对象的「光道」怪兽，让玩家以送去墓地的那只怪兽以外的自己墓地1只「光道」怪兽为对象，并设置加入手卡的操作信息。
function c52665542.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cc=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52665542.tgfilter(chkc) and chkc~=cc end
	-- 发动条件检查：确认自己墓地存在至少1只可以取为对象并加入手卡的「光道」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c52665542.tgfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示「请选择要加入手牌的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家以那只怪兽以外的自己墓地1只「光道」怪兽为对象。
	local sg=Duel.SelectTarget(tp,c52665542.tgfilter,tp,LOCATION_GRAVE,0,1,1,cc)
	-- 设置操作信息：将选择的1只怪兽加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- 效果处理：取得作为对象的怪兽，若其仍与本效果关联则加入手卡。
function c52665542.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤器：筛选从自己卡组被送去墓地的卡。
function c52665542.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
end
-- 放置指示物的条件：本次送去墓地的卡中存在从自己卡组被送去墓地的卡。
function c52665542.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52665542.cfilter,1,nil,tp)
end
-- 给这张卡放置1个光指示物。
function c52665542.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x5,1)
end
-- 破坏代替过滤器：筛选自己场上表侧表示的被效果破坏（且非已被代替破坏）的「光道」卡。
function c52665542.dfilter(c,tp)
	return c:IsFaceup() and c:IsOnField()
		and c:IsSetCard(0x38) and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 破坏代替的发动检查与询问：统计被效果破坏的「光道」卡数量，确认有足够的光指示物可以取除（每1张2个），再询问玩家是否适用破坏代替。
function c52665542.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=eg:FilterCount(c52665542.dfilter,nil,tp)
		e:SetLabel(count)
		-- 确认存在被效果破坏的「光道」卡，且自己场上的光指示物数量足够按每1张2个取除。
		return count>0 and Duel.IsCanRemoveCounter(tp,1,0,0x5,count*2,REASON_EFFECT)
	end
	-- 询问玩家是否适用破坏代替效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 破坏代替适用范围：自己场上表侧表示的被效果破坏的「光道」卡。
function c52665542.value(e,c)
	return c:IsFaceup() and c:IsOnField()
		and c:IsSetCard(0x38) and c:IsControler(e:GetHandlerPlayer()) and c:IsReason(REASON_EFFECT)
end
-- 破坏代替的处理：按破坏的「光道」卡每1张取除自己场上2个光指示物。
function c52665542.desop(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()
	-- 从自己场上取除破坏的「光道」卡数量×2个光指示物。
	Duel.RemoveCounter(tp,1,0,0x5,count*2,REASON_EFFECT)
end
