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
	-- ①：1回合1次，自己场上没有怪兽存在的场合，可以把1张手卡送去墓地，从以下效果选择1个发动。●以自己墓地1只守备力0的不死族怪兽为对象才能发动。那只怪兽特殊召唤。●以除外的1只自己的守备力0的不死族怪兽为对象才能发动。那只怪兽回到墓地。
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
-- 效果发动条件：检查自己场上没有怪兽存在，只有满足该条件才能发动此效果。
function c40005099.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己场上主要怪兽区（含额外怪兽区）的卡数，并判断是否为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 发动代价处理：从手卡丢弃1张卡去墓地作为发动代价，包括代价检测和实际支付两部分。
function c40005099.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认手卡中是否存在至少1张可以作为代价送去墓地的卡，存在则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：由玩家自己选择1张手卡丢弃去墓地，丢弃原因标记为代价（COST）。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 定义特殊召唤的候选对象：自己墓地中存在、不死族、守备力为0，且能被当前效果特殊召唤（满足苏生限制）的怪兽。
function c40005099.filter1(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsDefense(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义回到墓地的候选对象：除外区存在、表侧表示、不死族、守备力为0的怪兽。
function c40005099.filter2(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsDefense(0)
end
-- 效果发动时的目标选择处理：判断两个子效果是否可选，让玩家选择一个子效果，再按该子效果的要求选择对象并设置对应的操作信息。
function c40005099.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40005099.filter1(chkc,e,tp)
		else
			return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c40005099.filter2(chkc)
		end
	end
	-- 检查特殊召唤子效果是否可选：自己场上有可用怪兽区，且墓地存在1只符合条件的守备力0不死族怪兽。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c40005099.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查回到墓地子效果是否可选：除外区存在1只符合条件的表侧表示守备力0不死族怪兽。
	local b2=Duel.IsExistingTarget(c40005099.filter2,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个子效果都可用时，弹出对话框让玩家选择“特殊召唤”或“回到墓地”，选择的序号存入变量op。
		op=Duel.SelectOption(tp,aux.Stringid(40005099,0),aux.Stringid(40005099,1))  --"特殊召唤/回到墓地"
	elseif b1 then
		-- 当仅特殊召唤子效果可用时，直接选择该选项，op为0。
		op=Duel.SelectOption(tp,aux.Stringid(40005099,0))  --"特殊召唤"
	else
		-- 当仅回到墓地子效果可用时，由于Duel.SelectOption在只有一个选项时返回0，因此加1使op为1，与两选项时的编号保持一致。
		op=Duel.SelectOption(tp,aux.Stringid(40005099,1))+1  --"回到墓地"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 特殊召唤分支：发送选择提示，提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 特殊召唤分支：从自己墓地选择1只满足filter1条件的怪兽，将其设置为效果对象。
		local g=Duel.SelectTarget(tp,c40005099.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 特殊召唤分支：登记操作信息，告知后续检测本次效果将进行1张卡的特殊召唤。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(CATEGORY_TOGRAVE)
		-- 回到墓地分支：发送选择提示，提示玩家选择要送去墓地的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 回到墓地分支：从自己除外区选择1只满足filter2条件的怪兽，将其设置为效果对象。
		local g=Duel.SelectTarget(tp,c40005099.filter2,tp,LOCATION_REMOVED,0,1,1,nil)
		-- 回到墓地分支：登记操作信息，告知后续检测本次效果将把1张卡送去墓地。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	end
end
-- 效果处理阶段：根据发动的子效果（label为0表示特殊召唤，1表示回到墓地）对对象卡执行相应的处理。
function c40005099.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==0 then
		if tc:IsRelateToEffect(e) then
			-- 若对象卡仍与效果关联，则将其以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		if tc:IsRelateToEffect(e) then
			-- 若对象卡仍与效果关联，则将其以效果处理的方式送回墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
		end
	end
end
