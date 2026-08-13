--キャトルミューティレーション
-- 效果：
-- 自己场上表侧表示存在的1只兽族怪兽回手卡，从手卡特殊召唤1只和回手怪兽等级相同的兽族怪兽上场。
function c35149085.initial_effect(c)
	-- 对应效果原文：自己场上表侧表示存在的1只兽族怪兽回手卡，从手卡特殊召唤1只和回手怪兽等级相同的兽族怪兽上场。
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
-- 定义对象筛选函数：目标须为表侧表示、等级大于0、兽族、可以回手牌；且若没有空出的主要怪兽区，则目标必须是额外怪兽区的怪兽，以便回手后腾出特殊召唤格子。
function c35149085.filter(c,ft)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsRace(RACE_BEAST) and c:IsAbleToHand() and (ft>0 or c:GetSequence()<5)
end
-- 效果发动时的目标选择与合法性判定：获取主要怪兽区空格数，检查是否存在符合条件的兽族怪兽，让玩家选择1只作为对象，并设置将1张卡返回手牌的操作信息。
function c35149085.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己主要怪兽区的可用空格数，用于判断回手后是否仍有格子可供特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35149085.filter(chkc,ft) end
	-- 发动条件检查：若主要怪兽区空格数不为负（即至少允许选择额外怪兽区），且自己场上有1只满足条件的兽族表侧怪兽可以作为对象，则效果可以发动。
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(c35149085.filter,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 给玩家显示“请选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上选择1只满足条件的兽族表侧怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c35149085.filter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 设置本次连锁的操作信息：包含将1张卡返回手牌的处理。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义特殊召唤筛选函数：选择手牌中满足兽族、等级与回手怪兽相同、并且能被效果特殊召唤的怪兽。
function c35149085.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_BEAST) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理阶段：获取对象怪兽，确认其仍表侧且与效果关联后，将其返回手牌；回手成功且场上仍有空格时，从手牌选择符合条件的兽族怪兽并表侧特殊召唤。
function c35149085.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=tc:GetLevel()
		-- 将对象怪兽以效果原因返回持有者手牌，并确认实际回手成功且该卡现在位于手牌。
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
			-- 确认自己场上仍有可用的主要怪兽区，用于后续特殊召唤。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 给玩家显示“请选择要特殊召唤的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从手牌中选择1只满足等级相同、兽族且可特殊召唤的怪兽。
			local g=Duel.SelectMatchingCard(tp,c35149085.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,lv)
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
