--S－Force ナイトチェイサー
-- 效果：
-- 连接怪兽以外的「治安战警队」怪兽1只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽不能选择和自身相同纵列的怪兽作为攻击对象。
-- ②：自己·对方的主要阶段，以自己场上1只「治安战警队」怪兽为对象才能发动。那只怪兽回到持有者卡组。那之后，可以选除外的1只自己的「治安战警队」怪兽特殊召唤。
function c20515672.initial_effect(c)
	-- 添加连接召唤手续，要求使用1到1张满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,c20515672.mat,1,1)
	c:EnableReviveLimit()
	-- 只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽不能选择和自身相同纵列的怪兽作为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c20515672.attg)
	e1:SetValue(c20515672.atlimit)
	c:RegisterEffect(e1)
	-- 自己·对方的主要阶段，以自己场上1只「治安战警队」怪兽为对象才能发动。那只怪兽回到持有者卡组。那之后，可以选除外的1只自己的「治安战警队」怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20515672,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,20515672)
	e2:SetCondition(c20515672.tdcon)
	e2:SetTarget(c20515672.tdtg)
	e2:SetOperation(c20515672.tdop)
	c:RegisterEffect(e2)
end
-- 连接怪兽以外的「治安战警队」怪兽
function c20515672.mat(c)
	return c:IsLinkSetCard(0x156) and not c:IsLinkType(TYPE_LINK)
end
-- 满足条件的「治安战警队」怪兽
function c20515672.atfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判断目标怪兽是否在攻击时被限制
function c20515672.attg(e,c)
	local cg=c:GetColumnGroup()
	e:SetLabelObject(c)
	return cg:IsExists(c20515672.atfilter,1,nil,e:GetHandlerPlayer())
end
-- 限制对方怪兽不能选择相同纵列的怪兽作为攻击对象
function c20515672.atlimit(e,c)
	local lc=e:GetLabelObject()
	return lc:GetColumnGroup():IsContains(c)
end
-- 判断当前是否处于主要阶段1或主要阶段2
function c20515672.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 满足条件的「治安战警队」怪兽
function c20515672.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsAbleToDeck()
end
-- 设置效果目标，选择场上1只满足条件的怪兽
function c20515672.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c20515672.tdfilter(chkc) end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c20515672.tdfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1只满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c20515672.tdfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果操作信息，指定将目标怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 满足条件的「治安战警队」怪兽
function c20515672.spfilter(c,e,tp)
	return c:IsSetCard(0x156) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果操作，将目标怪兽送回卡组并可能特殊召唤除外的怪兽
function c20515672.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且已送回卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取满足条件的除外怪兽组
		local g=Duel.GetMatchingGroup(c20515672.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
		-- 判断是否可以发动特殊召唤效果
		if ft>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(20515672,1)) then  --"是否选除外的自己怪兽特殊召唤？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
