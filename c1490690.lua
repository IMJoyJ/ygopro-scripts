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
-- 效果发动时，判断是否为对方发动效果
function c1490690.con(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤函数，用于筛选「荷鲁斯」怪兽且可以特殊召唤
function c1490690.filter(c,e,tp)
	return c:IsSetCard(0x19d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 设置连锁处理时的条件，判断是否满足特殊召唤的条件
function c1490690.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或墓地是否存在满足条件的「荷鲁斯」怪兽
		and Duel.IsExistingMatchingCard(c1490690.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理特殊召唤效果，选择并特殊召唤符合条件的怪兽，并设置不能特殊召唤相同卡名怪兽的效果
function c1490690.op(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的「荷鲁斯」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1490690.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 创建并注册一个效果，使本回合不能特殊召唤与该怪兽相同卡名的怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c1490690.splimit)
		e1:SetLabel(g:GetFirst():GetOriginalCodeRule())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到玩家场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制特殊召唤的过滤函数，判断是否为相同卡名的怪兽
function c1490690.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	local sc=se:GetHandler()
	return sc and sc:IsCode(1490690) and c:IsOriginalCodeRule(e:GetLabel())
end
-- 判断此卡是否从手卡或场上送去墓地
function c1490690.stcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 设置连锁处理时的条件，判断是否满足盖放的条件
function c1490690.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置连锁处理信息，表示将要盖放此卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 处理盖放效果，将此卡盖放到场上，并设置其离开场时除外的效果
function c1490690.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能正常盖放
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 创建并注册一个效果，使此卡离开场时除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
