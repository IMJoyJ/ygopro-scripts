--キャトルミューティレーション
-- 效果：
-- 自己场上表侧表示存在的1只兽族怪兽回手卡，从手卡特殊召唤1只和回手怪兽等级相同的兽族怪兽上场。
function c35149085.initial_effect(c)
	-- 效果原文：自己场上表侧表示存在的1只兽族怪兽回手卡，从手卡特殊召唤1只和回手怪兽等级相同的兽族怪兽上场。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c35149085.target)
	e1:SetOperation(c35149085.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择满足条件的怪兽（正面表示、等级大于0、兽族、能回手），且满足召唤限制条件
function c35149085.filter(c,ft)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsRace(RACE_BEAST) and c:IsAbleToHand() and (ft>0 or c:GetSequence()<5)
end
-- 效果处理：设置效果目标，选择1只自己场上的兽族怪兽作为对象
function c35149085.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35149085.filter(chkc,ft) end
	-- 判断是否满足发动条件：场上存在满足条件的怪兽
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(c35149085.filter,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 提示玩家选择要回手的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c35149085.filter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 设置效果操作信息：将选中的怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤函数：选择满足条件的怪兽（兽族、等级等于目标怪兽、能特殊召唤）
function c35149085.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_BEAST) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：执行效果，将目标怪兽送入手牌并特殊召唤等级相同的怪兽
function c35149085.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=tc:GetLevel()
		-- 将目标怪兽送入手牌并确认是否成功
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
			-- 确认自己场上是否有空位可以特殊召唤
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的1只手牌怪兽进行特殊召唤
			local g=Duel.SelectMatchingCard(tp,c35149085.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,lv)
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
