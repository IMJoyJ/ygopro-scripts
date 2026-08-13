--氷結界の龍 トリシューラ
-- 效果：
-- 调整＋调整以外的怪兽2只以上
-- ①：这张卡同调召唤时才能发动。可以把对方的手卡·场上·墓地的卡各最多1张除外（从手卡是随机选）。
function c52687916.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要调整（可为任意调整）＋调整以外的怪兽2只以上作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时才能发动。可以把对方的手卡·场上·墓地的卡各最多1张除外（从手卡是随机选）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52687916,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c52687916.remcon)
	e1:SetTarget(c52687916.remtg)
	e1:SetOperation(c52687916.remop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡以同调召唤方式特殊召唤成功（即召唤类型为同调召唤）时才能发动。
function c52687916.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果发动时进行合法性检查和操作信息设定：确认对方手卡·场上·墓地存在至少1张可以除外的卡，并设置本次除外效果的处理信息。
function c52687916.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前的确认阶段（chk==0），检查对方手卡·场上·墓地是否存在至少1张可以除外的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 设置本次效果处理的操作信息：效果分类为除外，预定除外数量为1，涉及对方玩家的手卡、场上、墓地。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理的整体流程：分别筛选出对方场上、墓地、手卡中可除外的卡，依次让玩家确认是否除外对应区域，各最多选1张（手卡为随机选），最后将选择或随机到的卡全部除外。
function c52687916.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 筛选出对方场上所有可以除外的卡。
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	-- 筛选出对方墓地所有可以除外的卡。
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	-- 筛选出对方手卡所有可以除外的卡。
	local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	local sg=Group.CreateGroup()
	-- 若对方场上有可除外的卡，且（墓地、手卡都无卡可选，或玩家确认要除外场上的卡），则执行场上卡的除外选择。
	if g1:GetCount()>0 and ((g2:GetCount()==0 and g3:GetCount()==0) or Duel.SelectYesNo(tp,aux.Stringid(52687916,1))) then  --"是否要除外场上的卡？"
		-- 向玩家显示选择提示：请选择要除外的卡（用于接下来选择场上卡）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 将已选择的场上卡显示选择动画，并记录其为该效果关联的对象。
		Duel.HintSelection(sg1)
		sg:Merge(sg1)
	end
	-- 若对方墓地上有可除外的卡，且（当前尚未选择任何卡且手卡无卡可选，或玩家确认要除外墓地的卡），则执行墓地卡的除外选择。
	if g2:GetCount()>0 and ((sg:GetCount()==0 and g3:GetCount()==0) or Duel.SelectYesNo(tp,aux.Stringid(52687916,2))) then  --"是否要除外墓地的卡？"
		-- 向玩家显示选择提示：请选择要除外的卡（用于接下来选择墓地卡）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg2=g2:Select(tp,1,1,nil)
		-- 将已选择的墓地卡显示选择动画，并记录其为该效果关联的对象。
		Duel.HintSelection(sg2)
		sg:Merge(sg2)
	end
	-- 若对方手卡有可除外的卡，且（当前尚未选择任何卡，或玩家确认要除外手卡的卡），则执行手卡的随机选择。
	if g3:GetCount()>0 and (sg:GetCount()==0 or Duel.SelectYesNo(tp,aux.Stringid(52687916,3))) then  --"是否要除外手卡？"
		-- 显示选择提示：请选择要除外的卡（手卡通过随机方式选择）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg3=g3:RandomSelect(tp,1)
		sg:Merge(sg3)
	end
	-- 将所有被选中的卡以表侧表示除外，除外原因为卡片效果。
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
