--アロマヒーリング
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己回复自己场上的「芳香」怪兽种类×1000基本分。
-- ②：把墓地的这张卡除外，以自己墓地1只「芳香」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，自己回复500基本分。这个效果特殊召唤的怪兽从场上离开的场合除外。
local s,id,o=GetID()
-- 注册两个效果：效果①为魔法卡发动时回复LP，效果②为墓地中除外自身后特殊召唤并回复LP；两者共用同名卡的1回合1次使用限制（SetCountLimit(1,id)）。
function s.initial_effect(c)
	-- ①：自己回复自己场上的「芳香」怪兽种类×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rectg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「芳香」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，自己回复500基本分。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 设置效果②的发动COST为把墓地中的这张卡除外，对应效果原文'把墓地的这张卡除外'。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：卡必须是表侧表示且拥有「芳香」字段，用于统计场上的「芳香」怪兽。
function s.recfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc9)
end
-- ①效果的发动条件与操作信息设定：当自己场上有表侧「芳香」怪兽时可发动；计算场上「芳香」怪兽种类数×1000，并写入连锁信息作为回复值。
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：确认自己场上有至少1只表侧表示的「芳香」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.recfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有表侧表示的「芳香」怪兽，组成集合g，用于统计种类数。
	local g=Duel.GetMatchingGroup(s.recfilter,tp,LOCATION_MZONE,0,nil)
	local rec=g:GetClassCount(Card.GetCode)*1000
	-- 设置本次连锁的操作信息：效果类别为回复LP，目标玩家为tp，回复数值为rec（种类数×1000）。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- ①效果处理：重新获取场上表侧「芳香」怪兽，计算种类数×1000，然后让tp玩家回复该数值的LP。
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次获取自己场上的表侧「芳香」怪兽集合，以处理时实际存在的怪兽种类数为准。
	local g=Duel.GetMatchingGroup(s.recfilter,tp,LOCATION_MZONE,0,nil)
	local rec=g:GetClassCount(Card.GetCode)*1000
	-- 让tp玩家回复rec点基本分，回复原因是卡的效果。
	Duel.Recover(tp,rec,REASON_EFFECT)
end
-- 定义②效果特殊召唤的怪兽筛选条件：必须是「芳香」字段怪兽，且能被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xc9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标选择与发动条件：若指定对象则检查该对象是否符合条件；发动时需自己场上有可用怪兽区且墓地存在符合条件的「芳香」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 发动条件：自己主要怪兽区有空位（至少1个），才可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件：自己墓地存在至少1只满足特殊召唤条件的「芳香」怪兽，可以成为效果对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，提示为'请选择要特殊召唤的卡'。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「芳香」怪兽，并将其设为效果对象（Duel.SelectTarget会建立连锁关联）。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将当前连锁的对象玩家设置为tp，用于记录回复LP的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为500，表示之后要回复的LP数值。
	Duel.SetTargetParam(500)
	-- 设置操作信息：本次效果包含特殊召唤，对象为选中的怪兽g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：本次效果还包含回复LP，对象玩家为tp，回复量为500。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- ②效果处理：将对象怪兽特殊召唤，并为其附加'从场上离开的场合除外'的效果；特殊召唤完成后回复500LP。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 从当前连锁信息中取出之前保存的对象玩家p和回复参数d（500），用于后续LP回复。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if tc:IsRelateToEffect(e) then
		-- 使用SpecialSummonStep将对象怪兽以表侧表示特殊召唤；若特殊召唤成功进入后续处理。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 那之后，自己回复500基本分。这个效果特殊召唤的怪兽从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			tc:RegisterEffect(e1,true)
			-- 结束特殊召唤处理步骤，与SpecialSummonStep配对使用，确认特殊召唤成功。
			Duel.SpecialSummonComplete()
			-- 中断当前效果处理，使后续的LP回复与特殊召唤视为不同时处理，避免错误时点。
			Duel.BreakEffect()
			-- 让玩家p回复d点基本分（即500），回复原因为效果。
			Duel.Recover(p,d,REASON_EFFECT)
		end
	end
end
