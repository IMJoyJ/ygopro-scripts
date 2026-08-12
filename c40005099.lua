--不知火流 転生の陣
-- 效果：
-- 「不知火流 转生之阵」在1回合只能发动1张。
-- ①：1回合1次，自己场上没有怪兽存在的场合，可以把1张手卡送去墓地，从以下效果选择1个发动。
-- ●以自己墓地1只守备力0的不死族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ●以除外的1只自己的守备力0的不死族怪兽为对象才能发动。那只怪兽回到墓地。
function c40005099.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,40005099+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- 创建1个起动效果，限制1回合1次，只能在场地魔法区域发动，具有取对象效果，满足条件时可以发动，需要支付1张手卡送去墓地的代价，选择以下效果之一发动：①特殊召唤1只守备力0的不死族怪兽；②让1只除外的自己的守备力0的不死族怪兽回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c40005099.condition)
	e2:SetCost(c40005099.cost)
	e2:SetTarget(c40005099.target)
	e2:SetOperation(c40005099.operation)
	c:RegisterEffect(e2)
end
-- 效果条件：自己场上没有怪兽存在。
function c40005099.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有怪兽存在。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 支付代价：丢弃1张手卡送去墓地。
function c40005099.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在可以作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡送去墓地的操作。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 过滤器1：用于筛选墓地中的守备力为0的不死族怪兽，且可以被特殊召唤。
function c40005099.filter1(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsDefense(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤器2：用于筛选除外区中守备力为0的不死族怪兽。
function c40005099.filter2(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsDefense(0)
end
-- 选择效果目标：根据选择的效果类型，从墓地或除外区选择符合条件的怪兽作为目标。
function c40005099.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40005099.filter1(chkc,e,tp)
		else
			return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c40005099.filter2(chkc)
		end
	end
	-- 判断是否满足条件1：自己场上存在空位且墓地存在符合条件的怪兽。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c40005099.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	-- 判断是否满足条件2：除外区存在符合条件的怪兽。
	local b2=Duel.IsExistingTarget(c40005099.filter2,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 选择效果类型：从特殊召唤和回到墓地两个选项中选择一个。
		op=Duel.SelectOption(tp,aux.Stringid(40005099,0),aux.Stringid(40005099,1))  --"特殊召唤/回到墓地"
	elseif b1 then
		-- 选择效果类型：从特殊召唤一个选项中选择。
		op=Duel.SelectOption(tp,aux.Stringid(40005099,0))  --"特殊召唤"
	else
		-- 选择效果类型：从回到墓地一个选项中选择。
		op=Duel.SelectOption(tp,aux.Stringid(40005099,1))+1  --"回到墓地"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择特殊召唤的目标怪兽。
		local g=Duel.SelectTarget(tp,c40005099.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 设置操作信息为特殊召唤。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(CATEGORY_TOGRAVE)
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择回到墓地的目标怪兽。
		local g=Duel.SelectTarget(tp,c40005099.filter2,tp,LOCATION_REMOVED,0,1,1,nil)
		-- 设置操作信息为送去墓地。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	end
end
-- 执行效果操作：根据选择的效果类型，将目标怪兽特殊召唤或送回墓地。
function c40005099.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==0 then
		if tc:IsRelateToEffect(e) then
			-- 将目标怪兽特殊召唤到场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		if tc:IsRelateToEffect(e) then
			-- 将目标怪兽送回墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
		end
	end
end
