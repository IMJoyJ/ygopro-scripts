--極星宝スヴァリン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「极神」怪兽存在的场合才能发动。对方场上的全部表侧表示的卡的效果直到回合结束时无效化。
-- ②：把自己场上1只「极星」怪兽解放，以自己墓地1只「极神」怪兽为对象才能发动。那只怪兽特殊召唤。
function c64797746.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有「极神」怪兽存在的场合才能发动。对方场上的全部表侧表示的卡的效果直到回合结束时无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64797746,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,64797746)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCondition(c64797746.discon)
	e2:SetTarget(c64797746.distg)
	e2:SetOperation(c64797746.disop)
	c:RegisterEffect(e2)
	-- ②：把自己场上1只「极星」怪兽解放，以自己墓地1只「极神」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64797746,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,64797746)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCost(c64797746.spcost)
	e3:SetTarget(c64797746.sptg)
	e3:SetOperation(c64797746.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「极神」怪兽
function c64797746.disfilter(c)
	return c:IsSetCard(0x4b) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上存在表侧表示的「极神」怪兽
function c64797746.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「极神」怪兽
	return Duel.IsExistingMatchingCard(c64797746.disfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备（检查对方场上是否存在可无效的卡片并设置操作信息）
function c64797746.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张可无效的表侧表示卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可无效的表侧表示卡片
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：无效对方场上所有符合条件的卡片的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果①的效果处理（使对方场上全部表侧表示卡片的效果直到回合结束时无效化）
function c64797746.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前对方场上所有可无效的表侧表示卡片
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使与目标卡片相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果直到回合结束时无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果直到回合结束时无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 效果直到回合结束时无效化
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
-- 过滤条件：可解放的「极星」怪兽（且解放后能空出怪兽区域）
function c64797746.rfilter(c,tp)
	-- 检查卡片是否为「极星」怪兽，且解放该卡后自己场上有可用于特殊召唤的怪兽区域
	return c:IsSetCard(0x42) and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果②的发动代价（解放自己场上1只「极星」怪兽）
function c64797746.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为发动代价解放的「极星」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c64797746.rfilter,1,nil,tp) end
	-- 选择自己场上1只「极星」怪兽解放
	local g=Duel.SelectReleaseGroup(tp,c64797746.rfilter,1,1,nil,tp)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：自己墓地可以特殊召唤的「极神」怪兽
function c64797746.spfilter(c,e,tp)
	return c:IsSetCard(0x4b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（选择自己墓地1只「极神」怪兽作为对象并设置操作信息）
function c64797746.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c64797746.spfilter(chkc,e,tp) end
	-- 检查自己墓地是否存在可作为特殊召唤对象的「极神」怪兽
	if chk==0 then return Duel.IsExistingTarget(c64797746.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「极神」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c64797746.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理（将作为对象的「极神」怪兽特殊召唤）
function c64797746.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
