--カノプスの守護者
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方把效果发动时才能发动（同一连锁上最多1次）。从自己的手卡·墓地把1只「荷鲁斯」怪兽特殊召唤。这个回合，自己不能把原本卡名和这个效果特殊召唤的怪兽相同的怪兽用「卡诺匹斯的守护者」的效果特殊召唤。
-- ②：这张卡从手卡·场上送去墓地的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c1490690.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e0)
	-- ①：对方把效果发动时才能发动（同一连锁上最多1次）。从自己的手卡·墓地把1只「荷鲁斯」怪兽特殊召唤。这个回合，自己不能把原本卡名和这个效果特殊召唤的怪兽相同的怪兽用「卡诺匹斯的守护者」的效果特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1490690,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c1490690.con)
	e1:SetTarget(c1490690.tg)
	e1:SetOperation(c1490690.op)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·场上送去墓地的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1490690,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,1490690)
	e2:SetCondition(c1490690.stcon)
	e2:SetTarget(c1490690.sttg)
	e2:SetOperation(c1490690.stop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：仅在对方玩家发动效果时才能发动（rp==1-tp表示效果发动者是对手）。
function c1490690.con(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- ①效果的特殊召唤对象过滤：必须是「荷鲁斯」系列怪兽，且能够以表侧表示被特殊召唤。
function c1490690.filter(c,e,tp)
	return c:IsSetCard(0x19d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ①效果的发动合法性检查：我方主要怪兽区有空位，且手卡·墓地存在至少1只满足特殊召唤条件的「荷鲁斯」怪兽。
function c1490690.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在至少1只可特殊召唤的「荷鲁斯」怪兽。
		and Duel.IsExistingMatchingCard(c1490690.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本效果包含特殊召唤，预计从手卡·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：选择手卡·墓地中的1只「荷鲁斯」怪兽特殊召唤，并给己方附加本回合不能通过本卡效果特殊召唤同名怪兽的限制。
function c1490690.op(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方主要怪兽区仍有空位，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向操作者显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地中选择1只符合条件的「荷鲁斯」怪兽（过滤时排除受王家长眠之谷影响的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1490690.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 这个回合，自己不能把原本卡名和这个效果特殊召唤的怪兽相同的怪兽用「卡诺匹斯的守护者」的效果特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c1490690.splimit)
		e1:SetLabel(g:GetFirst():GetOriginalCodeRule())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将自肃效果注册到玩家tp，使其在本回合内受到对应特殊召唤限制。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃效果的过滤条件：特殊召唤的怪兽原本卡名与记录的一致，且该特殊召唤由「卡诺匹斯的守护者」的效果发动时，禁止其特殊召唤。
function c1490690.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	local sc=se:GetHandler()
	return sc and sc:IsCode(1490690) and c:IsOriginalCodeRule(e:GetLabel())
end
-- ②效果的发动条件：这张卡是从手卡或场上被送去墓地的场合才能发动。
function c1490690.stcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- ②效果的发动合法性检查：这张卡当前可以盖放；并设置操作信息表示将从墓地移动。
function c1490690.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：本效果涉及从墓地离开（CATEGORY_LEAVE_GRAVE），用于相关效果判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：满足条件且卡片仍与效果关联时，将其盖放到我方魔陷区；成功盖放后，给它附加离场时除外代替离开的替代效果。
function c1490690.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡仍与本次效果关联，且成功盖放到场上时才继续处理。
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
