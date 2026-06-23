--氷結界の龍 トリシューラ
-- 效果：
-- 调整＋调整以外的怪兽2只以上
-- ①：这张卡同调召唤时才能发动。可以把对方的手卡·场上·墓地的卡各最多1张除外（从手卡是随机选）。
function c52687916.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和2只以上调整以外的怪兽参与同调
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
-- 效果发动条件：确认此卡为同调召唤成功
function c52687916.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果处理准备：检查对方手牌、场上、墓地是否存在可除外的卡
function c52687916.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足除外条件：对方手牌、场上、墓地至少存在1张可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 设置效果处理信息：将要除外的卡的目标位置设为对方手牌、场上、墓地
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理流程：选择并除外对方手牌、场上、墓地各最多1张卡
function c52687916.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的可除外卡组
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	-- 获取对方墓地的可除外卡组
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	-- 获取对方手牌的可除外卡组
	local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	local sg=Group.CreateGroup()
	-- 判断是否选择除外场上卡：场上存在可除外卡且墓地与手牌均无可除外卡或玩家选择除外场上卡
	if g1:GetCount()>0 and ((g2:GetCount()==0 and g3:GetCount()==0) or Duel.SelectYesNo(tp,aux.Stringid(52687916,1))) then  --"是否要除外场上的卡？"
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 显示被选为对象的卡
		Duel.HintSelection(sg1)
		sg:Merge(sg1)
	end
	-- 判断是否选择除外墓地卡：墓地存在可除外卡且手上与场上均无可除外卡或玩家选择除外墓地卡
	if g2:GetCount()>0 and ((sg:GetCount()==0 and g3:GetCount()==0) or Duel.SelectYesNo(tp,aux.Stringid(52687916,2))) then  --"是否要除外墓地的卡？"
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg2=g2:Select(tp,1,1,nil)
		-- 显示被选为对象的卡
		Duel.HintSelection(sg2)
		sg:Merge(sg2)
	end
	-- 判断是否选择除外手卡：手牌存在可除外卡且场上与墓地均无可除外卡或玩家选择除外手卡
	if g3:GetCount()>0 and (sg:GetCount()==0 or Duel.SelectYesNo(tp,aux.Stringid(52687916,3))) then  --"是否要除外手卡？"
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg3=g3:RandomSelect(tp,1)
		sg:Merge(sg3)
	end
	-- 执行除外操作：将选定的卡以正面表示形式除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
