--グレイドル・スライムJr.
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只「灰篮」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把和这个效果特殊召唤的怪兽相同等级的1只水族怪兽从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
-- ②：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只「灰篮」怪兽特殊召唤。
function c80250319.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只「灰篮」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把和这个效果特殊召唤的怪兽相同等级的1只水族怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80250319,0))  --"从墓地特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c80250319.sptg1)
	e1:SetOperation(c80250319.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只「灰篮」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80250319,2))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c80250319.spcon2)
	e2:SetTarget(c80250319.sptg2)
	e2:SetOperation(c80250319.spop2)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地或卡组中可以特殊召唤的「灰篮」怪兽
function c80250319.spfilter1(c,e,tp)
	return c:IsSetCard(0xd1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与对象选择判定
function c80250319.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c80250319.spfilter1(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「灰篮」怪兽
		and Duel.IsExistingTarget(c80250319.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「灰篮」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c80250319.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含目标怪兽组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤手牌中与指定等级相同且可以特殊召唤的水族怪兽
function c80250319.spfilter2(c,e,tp,lv)
	return c:IsRace(RACE_AQUA) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的执行处理（特殊召唤墓地的怪兽，并可选特殊召唤手牌的同等级水族怪兽）
function c80250319.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的墓地目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍存在于墓地，则将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取手卡中与特殊召唤的怪兽相同等级的、可特殊召唤的水族怪兽组
		local g=Duel.GetMatchingGroup(c80250319.spfilter2,tp,LOCATION_HAND,0,nil,e,tp,tc:GetLevel())
		-- 检查手卡中是否存在符合条件的怪兽，且自己场上仍有空余的怪兽区域
		if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否选择从手卡特殊召唤水族怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(80250319,1)) then  --"是否从手卡把水族怪兽特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤不与前一次特殊召唤视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的手卡怪兽表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。②：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只「灰篮」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c80250319.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该限制效果，使其对玩家生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能特殊召唤水属性以外的怪兽
function c80250319.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 检查这张卡是否被战斗破坏并送去墓地
function c80250319.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果②的发动准备判定
function c80250319.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在可以特殊召唤的「灰篮」怪兽
		and Duel.IsExistingMatchingCard(c80250319.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表明将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的执行处理（从卡组特殊召唤1只「灰篮」怪兽）
function c80250319.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有空余的怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只「灰篮」怪兽
	local g=Duel.SelectMatchingCard(tp,c80250319.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的卡组怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
