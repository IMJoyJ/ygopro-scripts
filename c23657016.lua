--幻禄の天盃龍
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡当作调整使用特殊召唤。那之后，可以让这张卡的等级上升1星。
-- ②：自己·对方回合，把这张卡解放才能发动。从卡组把「幻禄之天杯龙」以外的1只「天杯龙」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是龙族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果的发动条件和处理
function s.initial_effect(c)
	-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡当作调整使用特殊召唤。那之后，可以让这张卡的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤&等级上升"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把这张卡解放才能发动。从卡组把「幻禄之天杯龙」以外的1只「天杯龙」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是龙族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡不是因抽卡而加入手卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- 效果①的发动时点：加入手牌时
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有空位可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理：特殊召唤自己并可能提升等级
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡是否还在场上且特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 将自己变为调整
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		-- 判断等级是否高于1且询问是否提升等级
		if c:IsLevelAbove(1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否上升等级？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提升等级1星
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_LEVEL)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(1)
			c:RegisterEffect(e2)
		end
	end
end
-- 效果②的发动费用：解放自己
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自己作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选符合条件的「天杯龙」怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x1aa) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时点：自由时点
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 判断卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组特殊召唤1只「天杯龙」怪兽并设置龙族不能特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择1只符合条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 特殊召唤选中的怪兽
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local c=e:GetHandler()
	-- 设置永续效果：自己不能特殊召唤非龙族怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 效果②的限制条件：不能特殊召唤非龙族怪兽
function s.splimit(e,c)
	return not c:IsRace(RACE_DRAGON)
end
