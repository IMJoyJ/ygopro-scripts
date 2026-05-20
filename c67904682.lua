--ダーク・フラット・トップ
-- 效果：
-- 暗属性调整＋调整以外的机械族怪兽1只以上
-- 1回合1次，选择自己墓地1只名字带有「反应机」的怪兽或者「巨人轰炸机·大空袭式」才能发动。选择的怪兽无视召唤条件特殊召唤。此外，这张卡被破坏送去墓地的场合，可以从手卡把1只5星以下的机械族怪兽特殊召唤。
function c67904682.initial_effect(c)
	-- 添加同调召唤手续：暗属性调整 + 调整以外的机械族怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(Card.IsRace,RACE_MACHINE),1)
	c:EnableReviveLimit()
	-- 1回合1次，选择自己墓地1只名字带有「反应机」的怪兽或者「巨人轰炸机·大空袭式」才能发动。选择的怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67904682,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c67904682.sptg1)
	e1:SetOperation(c67904682.spop1)
	c:RegisterEffect(e1)
	-- 此外，这张卡被破坏送去墓地的场合，可以从手卡把1只5星以下的机械族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67904682,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c67904682.spcon2)
	e2:SetTarget(c67904682.sptg2)
	e2:SetOperation(c67904682.spop2)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中名字带有「反应机」的怪兽或「巨人轰炸机·大空袭式」，且能无视召唤条件特殊召唤的卡片
function c67904682.spfilter1(c,e,tp)
	return (c:IsSetCard(0x63) or c:IsCode(16898077)) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果1（特殊召唤墓地怪兽）的发动准备与目标选择
function c67904682.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67904682.spfilter1(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足过滤条件1（反应机或大空袭式）的可选择目标
		and Duel.IsExistingTarget(c67904682.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足过滤条件1的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c67904682.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含特殊召唤所选目标的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果1（特殊召唤墓地怪兽）的效果处理
function c67904682.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果1所选择的唯一目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽无视召唤条件以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 检查效果2的发动条件：此卡是否因被破坏而送去墓地
function c67904682.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤手牌中5星以下的机械族怪兽，且能被特殊召唤的卡片
function c67904682.spfilter2(c,e,tp)
	return c:IsLevelBelow(5) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2（手牌特殊召唤）的发动准备
function c67904682.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手牌中是否存在满足过滤条件2（5星以下机械族）的怪兽
		and Duel.IsExistingMatchingCard(c67904682.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果2（手牌特殊召唤）的效果处理
function c67904682.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有空余的怪兽区域，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌中选择1只满足过滤条件2的怪兽
	local g=Duel.SelectMatchingCard(tp,c67904682.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
