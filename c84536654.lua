--フォーム・チェンジ
-- 效果：
-- ①：以自己场上1只「英雄」融合怪兽为对象才能发动。那只怪兽回到额外卡组，和那只怪兽的原本等级相同等级而卡名不同的1只「假面英雄」怪兽当作「假面变化」的特殊召唤从额外卡组特殊召唤。
function c84536654.initial_effect(c)
	-- ①：以自己场上1只「英雄」融合怪兽为对象才能发动。那只怪兽回到额外卡组，和那只怪兽的原本等级相同等级而卡名不同的1只「假面英雄」怪兽当作「假面变化」的特殊召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c84536654.target)
	e1:SetOperation(c84536654.activate)
	c:RegisterEffect(e1)
end
-- 过滤额外卡组中满足以下条件的卡：等级与对象怪兽原本等级相同、是「假面英雄」怪兽、卡名与对象怪兽不同、可以被特殊召唤，且在对象怪兽离场后有可用的额外卡组怪兽特殊召唤区域
function c84536654.spfilter(c,code,lv,e,tp,mc)
	return c:IsLevel(lv) and c:IsSetCard(0xa008) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_MASK_CHANGE,tp,false,true)
		-- 判断在作为对象的怪兽离场后，是否仍有可用的额外卡组怪兽特殊召唤区域
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 过滤自己场上表侧表示的「英雄」融合怪兽，且该怪兽可以回到额外卡组，并且额外卡组中存在满足特殊召唤条件的「假面英雄」怪兽
function c84536654.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x8) and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
		-- 判断额外卡组中是否存在至少1只与该怪兽原本等级相同、卡名不同且满足特殊召唤条件的「假面英雄」怪兽
		and Duel.IsExistingMatchingCard(c84536654.spfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetCode(),c:GetOriginalLevel(),e,tp,c)
end
-- 效果发动的目标选择与确认函数，用于处理是否满足发动条件、选择对象以及设置操作信息
function c84536654.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c84536654.filter(chkc,e,tp) end
	-- 在发动效果的准备阶段，检查自己场上是否存在符合条件的可作为对象的「英雄」融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c84536654.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 给发动效果的玩家发送提示信息，提示其选择要返回额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1只符合条件的「英雄」融合怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c84536654.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息，表明此效果包含将选中的对象怪兽送回额外卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置当前连锁的操作信息，表明此效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行函数，处理对象怪兽返回额外卡组以及从额外卡组特殊召唤「假面英雄」怪兽的过程
function c84536654.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local code=tc:GetCode()
	local lv=tc:GetOriginalLevel()
	-- 将作为对象的怪兽送回额外卡组，若未能成功送回，则效果处理终止
	if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
	-- 给发动效果的玩家发送提示信息，提示其选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组中选择1只与返回额外卡组的怪兽原本等级相同且卡名不同的「假面英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,c84536654.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,code,lv,e,tp,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使后续的特殊召唤处理与之前的返回额外卡组处理不视为同时进行
		Duel.BreakEffect()
		-- 将选中的「假面英雄」怪兽当作「假面变化」的特殊召唤，以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(g,SUMMON_VALUE_MASK_CHANGE,tp,tp,false,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
