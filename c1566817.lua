--テイ・キューピット
-- 效果：
-- 这个卡名的②的效果1回合只能有1次。
-- ①：这张卡只要在怪兽区域存在，不受除持有这张卡的等级以下的等级的怪兽以外的全部怪兽发动的效果影响。
-- ②：把自己墓地最多3张卡除外才能发动。直到回合结束时，这张卡的等级上升除外数量的数值。
function c1566817.initial_effect(c)
	-- ①：这张卡只要在怪兽区域存在，不受除持有这张卡的等级以下的等级的怪兽以外的全部怪兽发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c1566817.immval)
	c:RegisterEffect(e1)
	-- ②：把自己墓地最多3张卡除外才能发动。直到回合结束时，这张卡的等级上升除外数量的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1566817,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1566817)
	e2:SetCost(c1566817.lvcost)
	e2:SetOperation(c1566817.lvop)
	c:RegisterEffect(e2)
end
-- 效果值函数，用于判断是否免疫某个效果，当对方怪兽效果发动且其等级高于自身时则不免疫
function c1566817.immval(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:IsActivated() and (not (e:GetHandler():GetLevel()>=te:GetOwner():GetLevel()) or te:GetOwner():GetLevel()==0)
end
-- 效果的发动费用处理函数，检查玩家墓地是否有可除外的卡并选择1~3张除外
function c1566817.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家墓地是否存在至少1张可作为除外代价的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 获取玩家墓地中所有可除外的卡组成的组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,nil)
	local sg=g:Select(tp,1,3,nil)
	-- 将选择的卡组除外，并将除外数量记录到效果标签中
	e:SetLabel(Duel.Remove(sg,POS_FACEUP,REASON_COST))
end
-- 效果的发动处理函数，使自身等级上升除外卡数量的数值
function c1566817.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 为自身等级增加效果，数值等于除外卡数量，并在回合结束时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
