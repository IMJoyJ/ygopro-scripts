--剛竜剣士ダイナスターP
-- 效果：
-- 「龙剑士」灵摆怪兽＋灵摆怪兽
-- 把自己场上的上记卡解放的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：只要这张卡在怪兽区域存在，自己的怪兽区域·灵摆区域的灵摆怪兽卡不会被战斗以及对方的效果破坏。
-- ②：1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只「龙剑士」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为融合素材。
function c22638495.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册融合召唤手续，融合素材条件为：素材1为灵摆怪兽，素材2为「龙剑士」字段的灵摆怪兽，即对应融合素材‘「龙剑士」灵摆怪兽＋灵摆怪兽’。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_PENDULUM),aux.AND(aux.FilterBoolFunction(Card.IsFusionType,TYPE_PENDULUM),aux.FilterBoolFunction(Card.IsFusionSetCard,0xc7)),false)
	-- 为这张卡注册接触融合手续，无需「融合」，把自己场上的怪兽作为素材解放，从额外卡组特殊召唤；素材限制在自己的主要怪兽区，解放原因计入特殊召唤和素材。
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	-- 设置这张卡的特殊召唤条件（效果外文本），对应效果原文：‘把自己场上的上记卡解放的场合才能从额外卡组特殊召唤（不需要「融合」）。’
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c22638495.splimit)
	c:RegisterEffect(e1)
	-- 对应效果原文：‘②：1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只「龙剑士」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为融合素材。’
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c22638495.sptg)
	e3:SetOperation(c22638495.spop2)
	c:RegisterEffect(e3)
	-- 对应效果原文：‘①：只要这张卡在怪兽区域存在，自己的怪兽区域·灵摆区域的灵摆怪兽卡不会被战斗以及对方的效果破坏。’中的‘不会被战斗破坏’部分。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE+LOCATION_PZONE,0)
	e4:SetTarget(c22638495.indtg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 对应效果原文：‘①：只要这张卡在怪兽区域存在，自己的怪兽区域·灵摆区域的灵摆怪兽卡不会被战斗以及对方的效果破坏。’中的‘以及对方的效果破坏’部分。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE+LOCATION_PZONE,0)
	e5:SetTarget(c22638495.indtg)
	-- 将免疫效果破坏的值设为 aux.tgoval，表示只对对方发动的效果造成的破坏生效，即只保护这些卡不被对方的效果破坏，己方效果不保护。
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
-- 特殊召唤条件判定函数：只有这张卡当前不在额外卡组时，才允许被其他效果特殊召唤；即防止这张卡从额外卡组被直接特殊召唤，必须经由正规手续出场。
function c22638495.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 定义效果②可特殊召唤的卡牌过滤条件：必须是「龙剑士」（0xc7）字段的灵摆怪兽，并且能够被特殊召唤（不检查苏生限制）。
function c22638495.spfilter(c,e,tp)
	return c:IsSetCard(0xc7) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件：自己主要怪兽区有空位，并且手卡·墓地中存在至少1只满足 spfilter 的「龙剑士」灵摆怪兽。
function c22638495.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域，确保特殊召唤有空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在至少1只符合条件的「龙剑士」灵摆怪兽，作为效果发动的必要条件。
		and Duel.IsExistingMatchingCard(c22638495.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息，向系统声明此效果处理涉及特殊召唤，目标位置为手卡·墓地，预计处理1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的处理流程：确认空位后，让玩家从手卡·墓地选择1只「龙剑士」灵摆怪兽（墓地选择需通过王家长眠之谷过滤），以表侧表示特殊召唤，并给该怪兽附加‘不能作为融合素材’的效果。
function c22638495.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认自己主要怪兽区仍有空位，若无空位则效果处理不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·墓地中选择1张满足 spfilter 的卡；使用 aux.NecroValleyFilter 使墓地中受王家长眠之谷影响不能特殊召唤的卡不会被选中。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c22638495.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 对这次特殊召唤的怪兽附加‘不能作为融合素材’的效果，对应效果原文：‘这个效果特殊召唤的怪兽不能作为融合素材。’
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 破坏免疫效果的目标筛选条件：只有灵摆怪兽卡才会受到该保护效果的影响。
function c22638495.indtg(e,c)
	return c:IsType(TYPE_PENDULUM)
end
