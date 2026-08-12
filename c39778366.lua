--スクランブル・ユニオン
-- 效果：
-- 「同盟紧急出动」在1回合只能发动1张。
-- ①：以除外的自己的机械族·光属性的最多3只通常怪兽或者同盟怪兽为对象才能发动。那些怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以除外的自己的机械族·光属性的1只通常怪兽或者同盟怪兽为对象才能发动。那只怪兽回到手卡。这个效果在这张卡送去墓地的回合不能发动。
function c39778366.initial_effect(c)
	-- ①：以除外的自己的机械族·光属性的最多3只通常怪兽或者同盟怪兽为对象才能发动。那些怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,39778366+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c39778366.target)
	e1:SetOperation(c39778366.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以除外的自己的机械族·光属性的1只通常怪兽或者同盟怪兽为对象才能发动。那只怪兽回到手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果条件为：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置效果的费用为：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c39778366.thtg)
	e2:SetOperation(c39778366.thop)
	c:RegisterEffect(e2)
end
c39778366.has_text_type=TYPE_UNION
-- 过滤满足条件的怪兽（机械族·光属性·通常或同盟·可特殊召唤）
function c39778366.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsType(TYPE_NORMAL+TYPE_UNION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的取对象条件为：除外区的自己机械族·光属性的通常或同盟怪兽
function c39778366.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c39778366.filter(chkc,e,tp) end
	-- 检测场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测除外区是否有满足条件的怪兽
		and Duel.IsExistingTarget(c39778366.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c39778366.filter,tp,LOCATION_REMOVED,0,1,ft,nil,e,tp)
	-- 设置效果操作信息为：特殊召唤指定数量的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 处理效果的发动，根据场上怪兽区域数量决定是否需要舍弃部分怪兽
function c39778366.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁中指定的效果对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()<=ft then
		-- 将满足条件的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将满足条件的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		-- 将未被特殊召唤的怪兽送入墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
-- 过滤满足条件的怪兽（机械族·光属性·通常或同盟·可回手）
function c39778366.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
	and c:IsType(TYPE_NORMAL+TYPE_UNION) and c:IsAbleToHand()
end
-- 设置效果的取对象条件为：除外区的自己机械族·光属性的通常或同盟怪兽
function c39778366.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c39778366.thfilter(chkc) end
	-- 检测除外区是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c39778366.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c39778366.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果操作信息为：将指定数量的怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果的发动，将对象怪兽送入手牌并确认
function c39778366.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中指定的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认对象怪兽的卡面
		Duel.ConfirmCards(1-tp,tc)
	end
end
