--S－Force ナイトチェイサー
-- 效果：
-- 连接怪兽以外的「治安战警队」怪兽1只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽不能选择和自身相同纵列的怪兽作为攻击对象。
-- ②：自己·对方的主要阶段，以自己场上1只「治安战警队」怪兽为对象才能发动。那只怪兽回到持有者卡组。那之后，可以选除外的1只自己的「治安战警队」怪兽特殊召唤。
function c20515672.initial_effect(c)
	-- 为这张卡设定连接召唤手续：以c20515672.mat为素材过滤条件，需要1只连接怪兽以外的「治安战警队」怪兽作为连接素材。
	aux.AddLinkProcedure(c,c20515672.mat,1,1)
	c:EnableReviveLimit()
	-- ①效果：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽不能选择和自身相同纵列的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c20515672.attg)
	e1:SetValue(c20515672.atlimit)
	c:RegisterEffect(e1)
	-- ②效果：这个卡名的②的效果1回合只能使用1次。自己·对方的主要阶段，以自己场上1只「治安战警队」怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以把自己的除外状态的1只「治安战警队」怪兽特殊召唤。
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
-- 连接素材过滤函数：判定怪兽为「治安战警队」系列（0x156）且不是连接怪兽，对应“连接怪兽以外的「治安战警队」怪兽1只”。
function c20515672.mat(c)
	return c:IsLinkSetCard(0x156) and not c:IsLinkType(TYPE_LINK)
end
-- ①效果的辅助过滤：判断怪兽是否表侧表示、属于「治安战警队」、位于怪兽区域且由tp玩家控制，用于识别“自己的「治安战警队」怪兽”。
function c20515672.atfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- ①效果的攻击方限制条件：若攻击怪兽所在纵列存在自己的「治安战警队」怪兽，则该攻击怪兽受到“不能选择同纵列目标”的限制；同时将攻击怪兽存入效果的LabelObject供后续判断使用。
function c20515672.attg(e,c)
	local cg=c:GetColumnGroup()
	e:SetLabelObject(c)
	return cg:IsExists(c20515672.atfilter,1,nil,e:GetHandlerPlayer())
end
-- ①效果的不可选择目标判定：若被选择为攻击对象的怪兽与之前记录的攻击怪兽在同一纵列，则不允许选择该怪兽作为攻击对象。
function c20515672.atlimit(e,c)
	local lc=e:GetLabelObject()
	return lc:GetColumnGroup():IsContains(c)
end
-- ②效果的发动条件函数：只能在主要阶段1或主要阶段2满足条件时才能发动。
function c20515672.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ②效果的对象筛选：选择自己场上的表侧表示「治安战警队」怪兽，且该怪兽可以返回卡组。
function c20515672.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsAbleToDeck()
end
-- ②效果的发动流程：从自己场上选择1只符合条件的表侧表示「治安战警队」怪兽作为对象，并登记“返回卡组”的操作信息。
function c20515672.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c20515672.tdfilter(chkc) end
	-- 发动时合法性检查：确认自己场上存在至少1只可作为对象且满足条件的「治安战警队」表侧怪兽。
	if chk==0 then return Duel.IsExistingTarget(c20515672.tdfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出“请选择要返回卡组的卡”的选择提示消息，供后续选卡使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己场上选择1只符合条件的「治安战警队」表侧怪兽，并将其设为当前效果的对象。
	local g=Duel.SelectTarget(tp,c20515672.tdfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将本次连锁的操作信息登记为“有1张卡将返回卡组”，用于其他效果对发动条件的检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 特殊召唤对象筛选：识别除外区的自己的表侧表示「治安战警队」怪兽，且该怪兽可以被玩家tp特殊召唤（检查召唤条件和苏生限制）。
function c20515672.spfilter(c,e,tp)
	return c:IsSetCard(0x156) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的处理：获取对象怪兽，将其送回持有者卡组并洗牌；若返回成功，则可以选择除外区的1只「治安战警队」怪兽进行特殊召唤。
function c20515672.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与本效果关联，且成功通过效果送回持有者卡组（洗牌）后位于卡组或额外卡组，才继续后续特殊召唤处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 计算自己场上可用的怪兽区空格数，用于判断是否满足特殊召唤所需的空间。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取除外区中所有符合特殊召唤条件的「治安战警队」表侧怪兽。
		local g=Duel.GetMatchingGroup(c20515672.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
		-- 若场上存在空格、除外区有可特殊召唤的怪兽，且玩家选择“是”，则进入特殊召唤处理。
		if ft>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(20515672,1)) then  --"是否选除外的自己怪兽特殊召唤？"
			-- 中断当前效果处理，使之后进行的特殊召唤视为独立的效果处理，避免错过特殊召唤成功时的时点。
			Duel.BreakEffect()
			-- 弹出“请选择要特殊召唤的卡”的选择提示消息，供后续选卡使用。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将玩家选择的怪兽正面表示特殊召唤到自己场上，不附加召唤条件和苏生限制检查。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
