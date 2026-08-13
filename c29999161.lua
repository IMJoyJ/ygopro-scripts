--発条の巻き戻し
-- 效果：
-- 选择自己场上表侧表示存在的1只4星以下的名字带有「发条」的怪兽回到手卡，和回去的怪兽相同等级的1只名字带有「发条」的怪兽从手卡特殊召唤。
function c29999161.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只4星以下的名字带有「发条」的怪兽回到手卡，和回去的怪兽相同等级的1只名字带有「发条」的怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c29999161.target)
	e1:SetOperation(c29999161.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：对象必须是自己场上表侧表示、卡名含有「发条」、等级4以下且可以被返回手卡的怪兽。
function c29999161.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 效果的发动条件与对象选择：确认有合法对象时才能发动，发动时选择自己场上1只符合条件的表侧表示发条怪兽作为对象，并设置“返回手牌”和“特殊召唤”的操作信息。
function c29999161.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c29999161.filter(chkc) end
	-- 发动时点检查：确认自己场上是否存在至少1只符合条件的表侧表示4星以下「发条」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c29999161.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“选择要返回手牌的卡”的提示信息，用于选择对象的交互界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己场上表侧表示的符合条件的「发条」怪兽中选择1只作为效果对象。
	local g=Duel.SelectTarget(tp,c29999161.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置本次连锁的处理信息：将选择的对象卡从场上返回手牌（数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置本次连锁的处理信息：预定从手卡将1只怪兽特殊召唤到自己的场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤的过滤条件：选择手卡中卡名含有「发条」、等级与返回怪兽相同、并且可以被当前效果特殊召唤的怪兽。
function c29999161.spfilter(c,lv,e,tp)
	return c:IsSetCard(0x58) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：获取对象卡，确认对象仍合法且成功返回手牌后，洗切手牌，检查可用怪兽区，再从手卡选择1只同名系列且同等级的怪兽表侧表示特殊召唤。
function c29999161.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡仍然与效果相关联、表侧表示，且通过效果成功返回手牌并位于手卡中；只有满足这些条件才继续处理。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 洗切返回手牌的那张卡的控制者的手牌（因为手牌内容可能被确认或洗切重置）。
		Duel.ShuffleHand(tc:GetControler())
		-- 检查自己的怪兽区域是否有空位；如果没有空位则无法特殊召唤，直接终止处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向玩家显示“选择要特殊召唤的卡”的提示信息，用于特殊召唤选择界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡中选择1只满足特殊召唤条件（卡名含「发条」且等级等于返回怪兽等级）的怪兽。
		local g=Duel.SelectMatchingCard(tp,c29999161.spfilter,tp,LOCATION_HAND,0,1,1,nil,tc:GetLevel(),e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示（通常为攻击表示）特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
