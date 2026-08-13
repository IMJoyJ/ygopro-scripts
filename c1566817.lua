--テイ・キューピット
-- 效果：
-- 这个卡名的②的效果1回合只能有1次。
-- ①：这张卡只要在怪兽区域存在，不受除持有这张卡的等级以下的等级的怪兽以外的全部怪兽发动的效果影响。
-- ②：把自己墓地最多3张卡除外才能发动。直到回合结束时，这张卡的等级上升除外数量的数值。
function c1566817.initial_effect(c)
	-- 此代码对应①效果：这张卡只要在怪兽区域存在，不受除持有这张卡的等级以下的等级的怪兽以外的全部怪兽发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c1566817.immval)
	c:RegisterEffect(e1)
	-- 此代码对应‘这个卡名的②的效果1回合只能有1次。’以及②效果：把自己墓地最多3张卡除外才能发动。直到回合结束时，这张卡的等级上升除外数量的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1566817,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1566817)
	e2:SetCost(c1566817.lvcost)
	e2:SetOperation(c1566817.lvop)
	c:RegisterEffect(e2)
end
-- 判定免疫条件：若触发免疫判定的是怪兽发动的效果，且发动效果的怪兽的等级高于本卡当前等级（或该怪兽等级为0），则本卡不受该效果影响。
function c1566817.immval(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:IsActivated() and (not (e:GetHandler():GetLevel()>=te:GetOwner():GetLevel()) or te:GetOwner():GetLevel()==0)
end
-- ②效果的代价处理：先确认墓地存在可作为代价除外的卡，然后提示玩家从自己墓地选择1到3张卡除外，并将实际除外的数量记录到效果e的Label中，供效果处理时使用。
function c1566817.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己墓地是否存在至少1张能够作为代价除外的卡，若不存在则②效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，要求玩家选择要作为代价除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 获取自己墓地中所有可以作为代价除外的卡的集合，供玩家进一步选择。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,nil)
	local sg=g:Select(tp,1,3,nil)
	-- 将玩家选择的卡以表侧表示除外作为发动代价，并把实际除外的卡数存入效果e的Label中。
	e:SetLabel(Duel.Remove(sg,POS_FACEUP,REASON_COST))
end
-- ②效果处理：若本卡仍表侧表示且与发动效果时相关联，则为本卡赋予等级上升效果，上升数值为代价除外的卡数，持续到回合结束，并在离场、无效等标准重置条件或结束阶段时重置。
function c1566817.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 此代码对应②效果中的‘直到回合结束时，这张卡的等级上升除外数量的数值。’
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
