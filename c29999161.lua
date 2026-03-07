--発条の巻き戻し
-- 效果：
-- 选择自己场上表侧表示存在的1只4星以下的名字带有「发条」的怪兽回到手卡，和回去的怪兽相同等级的1只名字带有「发条」的怪兽从手卡特殊召唤。
function c29999161.initial_effect(c)
	-- 效果原文：选择自己场上表侧表示存在的1只4星以下的名字带有「发条」的怪兽回到手卡，和回去的怪兽相同等级的1只名字带有「发条」的怪兽从手卡特殊召唤。
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
-- 过滤函数：选择场上正面表示、名字带有「发条」、等级4以下且能送入手牌的怪兽
function c29999161.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 效果处理：选择场上正面表示、名字带有「发条」、等级4以下且能送入手牌的怪兽作为对象
function c29999161.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c29999161.filter(chkc) end
	-- 检查阶段：确认场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c29999161.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示信息：提示玩家选择要返回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对象：选择1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c29999161.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：将送入手牌的怪兽设置为效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：将从手牌特殊召唤的怪兽设置为效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤函数：选择手牌中名字带有「发条」、等级与目标怪兽相同且能特殊召唤的怪兽
function c29999161.spfilter(c,lv,e,tp)
	return c:IsSetCard(0x58) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：将目标怪兽送回手牌，并从手牌中特殊召唤相同等级的怪兽
function c29999161.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对象：获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 条件判断：确认目标怪兽有效且正面表示、已送入手牌
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 洗切手牌：将目标怪兽的持有者手牌洗切
		Duel.ShuffleHand(tc:GetControler())
		-- 判断召唤区是否为空：确认是否有足够的召唤区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示信息：提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择特殊召唤怪兽：选择手牌中满足等级和属性条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c29999161.spfilter,tp,LOCATION_HAND,0,1,1,nil,tc:GetLevel(),e,tp)
		if g:GetCount()>0 then
			-- 特殊召唤怪兽：将选择的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
