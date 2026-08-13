--古代の機械工場
-- 效果：
-- 选择手卡1张名字带有「古代的机械」的怪兽卡。把墓地中合计为选择的卡2倍等级数量的名字带有「古代的机械」的卡从游戏中除外。选择的卡在这个回合召唤时不需要祭品。
function c30435145.initial_effect(c)
	-- 选择手卡1张名字带有「古代的机械」的怪兽卡。把墓地中合计为选择的卡2倍等级数量的名字带有「古代的机械」的卡从游戏中除外。选择的卡在这个回合召唤时不需要祭品。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c30435145.target)
	e1:SetOperation(c30435145.operation)
	c:RegisterEffect(e1)
end
-- 筛选手卡中可作为对象的「古代的机械」怪兽：等级5以上、属于「古代的机械」字段，且墓地中存在合计等级等于其2倍的可除外「古代的机械」卡组。
function c30435145.filter(c,g)
	return c:IsLevelAbove(5) and c:IsSetCard(0x7) and g:CheckWithSumEqual(Card.GetLevel,c:GetLevel()*2,1,99)
end
-- 筛选墓地中可作为除外代价的候选卡：等级大于0、属于「古代的机械」字段且能够被除外。
function c30435145.rfilter(c)
	return c:GetLevel()>0 and c:IsSetCard(0x7) and c:IsAbleToRemove()
end
-- 发动时的合法判定：检查手卡是否存在满足条件的「古代的机械」怪兽，同时墓地存在足够的可除外材料；若可以则登记除外墓地卡的操作信息。
function c30435145.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得自己墓地中所有满足rfilter条件（等级大于0、字段「古代的机械」且可除外）的卡，作为除外材料候选集合。
		local rg=Duel.GetMatchingGroup(c30435145.rfilter,tp,LOCATION_GRAVE,0,nil)
		-- 检查自己手卡中是否存在至少1张满足filter条件的「古代的机械」怪兽，其中墓地集合rg用于验证除外材料是否足够。
		return Duel.IsExistingMatchingCard(c30435145.filter,tp,LOCATION_HAND,0,1,nil,rg)
	end
	-- 将本次效果的处理信息登记为除外墓地卡（数量1），用于连锁判定等系统检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：从手卡选择1张符合条件的「古代的机械」怪兽，向对手确认并洗切手卡；然后从墓地选择合计等级为该怪兽2倍的「古代的机械」卡除外；最后给该怪兽附加本回合无需解放召唤的效果。
function c30435145.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新取得自己墓地中所有可除外的「古代的机械」卡集合，作为后续选择除外的候选。
	local rg=Duel.GetMatchingGroup(c30435145.rfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家显示“请选择一张名字带有「古代的机械」的怪兽卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(30435145,1))  --"请选择一张名字带有「古代的机械」的怪兽卡"
	-- 让玩家从自己的手卡中选择1张满足filter条件的「古代的机械」怪兽（等级5以上且墓地有足够除外材料）。
	local g=Duel.SelectMatchingCard(tp,c30435145.filter,tp,LOCATION_HAND,0,1,1,nil,rg)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的手卡怪兽展示给对手确认。
		Duel.ConfirmCards(1-tp,tc)
		-- 手卡被确认后，洗切自己的手卡。
		Duel.ShuffleHand(tp)
		-- 显示“请选择要除外的卡”的提示，让玩家选择墓地中要除外的「古代的机械」卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=rg:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel()*2,1,99)
		-- 将选择的一组墓地中的「古代的机械」卡以表侧表示除外，是因为效果处理而除外。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		-- 选择的卡在这个回合召唤时不需要祭品。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(30435145,0))  --"不使用解放召唤"
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(c30435145.ntcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 为选中的怪兽赋予本回合无需解放召唤的召唤规则效果：当该怪兽进行通常召唤时，满足条件则可以不解放怪兽直接召唤，直到回合结束。
function c30435145.ntcon(e,c,minc)
	if c==nil then return true end
	-- 无解放召唤的具体条件：通常召唤所需解放数为0、该怪兽等级5以上，且自己主要怪兽区存在空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
