--アメイズメント・プレシャスパーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己可以把1张「游乐设施」陷阱卡在盖放的回合的自己主要阶段发动。
-- ②：自己·对方的结束阶段，把给怪兽装备的自己场上1张「游乐设施」陷阱卡送去墓地，从自己墓地的卡以及除外的自己的卡之中以和送去墓地的卡卡名不同的1张「游乐设施」陷阱卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
function c33773528.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己可以把1张「游乐设施」陷阱卡在盖放的回合的自己主要阶段发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33773528,1))  --"适用「惊乐珍宝园」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetCountLimit(1,33773528)
	e1:SetCondition(c33773528.actcon)
	-- 设置效果适用对象为「游乐设施」陷阱卡
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x15c))
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，把给怪兽装备的自己场上1张「游乐设施」陷阱卡送去墓地，从自己墓地的卡以及除外的自己的卡之中以和送去墓地的卡卡名不同的1张「游乐设施」陷阱卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33773528,0))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,33773529)
	e2:SetCost(c33773528.cost)
	e2:SetTarget(c33773528.target)
	e2:SetOperation(c33773528.activate)
	c:RegisterEffect(e2)
end
-- 判断是否为自己的主要阶段
function c33773528.actcon(e)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断是否为自己的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤满足条件的装备有「游乐设施」陷阱卡
function c33773528.filter(c,tp)
	-- 筛选场上装备的「游乐设施」陷阱卡
	return c:IsFaceup() and c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:GetEquipTarget() and c:IsAbleToGraveAsCost() and Duel.GetSZoneCount(tp,c)>0
		-- 确保墓地或除外区存在不同名的「游乐设施」陷阱卡
		and Duel.IsExistingTarget(c33773528.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c:GetCode())
end
-- 筛选墓地或除外区的「游乐设施」陷阱卡
function c33773528.setfilter(c,code)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and not c:IsCode(code) and c:IsSSetable(true)
end
-- 设置发动费用为无费用
function c33773528.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 处理效果发动时的选择与处理
function c33773528.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c33773528.setfilter(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在满足条件的装备陷阱卡
		return Duel.IsExistingMatchingCard(c33773528.filter,tp,LOCATION_SZONE,0,1,nil,tp)
	end
	e:SetLabel(0)
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择要送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,c33773528.filter,tp,LOCATION_SZONE,0,1,1,nil,tp)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
	local code=g:GetFirst():GetCode()
	e:SetLabel(code)
	-- 提示选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择要盖放的卡
	local sg=Duel.SelectTarget(tp,c33773528.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,code)
	if sg:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息为离开墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
	end
end
-- 执行效果的最终处理
function c33773528.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将卡在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,tc)
	end
end
