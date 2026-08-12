--剛竜剣士ダイナスターP
-- 效果：
-- 「龙剑士」灵摆怪兽＋灵摆怪兽
-- 把自己场上的上记卡解放的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：只要这张卡在怪兽区域存在，自己的怪兽区域·灵摆区域的灵摆怪兽卡不会被战斗以及对方的效果破坏。
-- ②：1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只「龙剑士」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为融合素材。
function c22638495.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用1只灵摆类型的融合素材和1只龙剑士系列的灵摆类型融合素材进行融合召唤
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_PENDULUM),aux.AND(aux.FilterBoolFunction(Card.IsFusionType,TYPE_PENDULUM),aux.FilterBoolFunction(Card.IsFusionSetCard,0xc7)),false)
	-- 添加接触融合程序，通过解放自己场上的满足条件的怪兽来特殊召唤此卡
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	-- 只要这张卡在怪兽区域存在，自己的怪兽区域·灵摆区域的灵摆怪兽卡不会被战斗以及对方的效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c22638495.splimit)
	c:RegisterEffect(e1)
	-- 1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只「龙剑士」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为融合素材
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c22638495.sptg)
	e3:SetOperation(c22638495.spop2)
	c:RegisterEffect(e3)
	-- 只要这张卡在怪兽区域存在，自己的怪兽区域·灵摆区域的灵摆怪兽卡不会被战斗破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE+LOCATION_PZONE,0)
	e4:SetTarget(c22638495.indtg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 只要这张卡在怪兽区域存在，自己的怪兽区域·灵摆区域的灵摆怪兽卡不会被对方的效果破坏
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE+LOCATION_PZONE,0)
	e5:SetTarget(c22638495.indtg)
	-- 设置效果值为辅助函数，用于判断目标是否不会成为对方效果的对象
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
-- 此卡不能从额外卡组特殊召唤，必须通过接触融合方式特殊召唤
function c22638495.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 过滤满足龙剑士系列、灵摆类型且可以特殊召唤的卡
function c22638495.spfilter(c,e,tp)
	return c:IsSetCard(0xc7) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件，包括场上的怪兽数量和手牌/墓地是否存在符合条件的卡
function c22638495.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己手牌或墓地是否存在符合条件的灵摆怪兽
		and Duel.IsExistingMatchingCard(c22638495.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只灵摆怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行特殊召唤操作，选择符合条件的卡进行特殊召唤，并设置其不能作为融合素材
function c22638495.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地选择1只符合条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c22638495.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 设置选中的卡不能作为融合素材
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断目标是否为灵摆怪兽
function c22638495.indtg(e,c)
	return c:IsType(TYPE_PENDULUM)
end
