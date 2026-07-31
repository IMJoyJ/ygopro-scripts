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
-- 过滤手牌中满足条件的「光道」怪兽（怪兽类型、光道系列、可送入墓地）
function c52665542.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x38) and c:IsAbleToGraveAsCost()
end
-- 发动效果时的费用处理：检查手牌是否存在符合条件的「光道」怪兽，若有则选择1只送入墓地作为费用
function c52665542.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张满足costfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c52665542.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 获取玩家手牌组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:FilterSelect(tp,c52665542.costfilter,1,1,nil)
	e:SetLabelObject(sg:GetFirst())
	-- 将选中的卡送入墓地作为费用
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 过滤墓地中满足条件的「光道」怪兽（怪兽类型、光道系列、可加入手牌）
function c52665542.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x38) and c:IsAbleToHand()
end
-- 效果处理时的目标选择：检查墓地是否存在符合条件的「光道」怪兽，若有则选择1只作为目标
function c52665542.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cc=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52665542.tgfilter(chkc) and chkc~=cc end
	-- 检查墓地中是否存在至少1张满足tgfilter条件的卡
	if chk==0 then return Duel.IsExistingTarget(c52665542.tgfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1只符合条件的「光道」怪兽作为效果对象
	local sg=Duel.SelectTarget(tp,c52665542.tgfilter,tp,LOCATION_GRAVE,0,1,1,cc)
	-- 设置效果操作信息，指定将目标怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- 效果处理：将选中的目标怪兽送入手牌
function c52665542.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤被送去墓地的卡（来自自己卡组）
function c52665542.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
end
-- 判断是否有卡从自己卡组送去墓地
function c52665542.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52665542.cfilter,1,nil,tp)
end
-- 为该卡添加1个光指示物
function c52665542.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x5,1)
end
-- 过滤场上被效果破坏的「光道」卡（表侧表示、在场、光道系列、因效果破坏且非代替破坏）
function c52665542.dfilter(c,tp)
	return c:IsFaceup() and c:IsOnField()
		and c:IsSetCard(0x38) and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否可以发动代替破坏效果：统计满足条件的破坏卡数量，并检查是否能移除相应数量的光指示物
function c52665542.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=eg:FilterCount(c52665542.dfilter,nil,tp)
		e:SetLabel(count)
		-- 判断是否能移除指定数量的光指示物
		return count>0 and Duel.IsCanRemoveCounter(tp,1,0,0x5,count*2,REASON_EFFECT)
	end
	-- 提示玩家选择是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 判断目标卡是否为场上的「光道」怪兽且因效果破坏
function c52665542.value(e,c)
	return c:IsFaceup() and c:IsOnField()
		and c:IsSetCard(0x38) and c:IsControler(e:GetHandlerPlayer()) and c:IsReason(REASON_EFFECT)
end
-- 执行代替破坏效果：移除指定数量的光指示物
function c52665542.desop(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()
	-- 移除指定数量的光指示物
	Duel.RemoveCounter(tp,1,0,0x5,count*2,REASON_EFFECT)
end
