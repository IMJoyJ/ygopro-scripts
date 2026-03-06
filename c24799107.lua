--ドラゴンメイド・シュトラール
-- 效果：
-- 「半龙女仆」怪兽＋5星以上的龙族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的准备阶段才能发动。从自己的手卡·墓地把1只9星以下的「半龙女仆」怪兽特殊召唤。
-- ②：对方把魔法·陷阱·怪兽的效果发动时才能发动。以下效果全部适用。
-- ●那个发动无效并破坏。
-- ●这张卡回到额外卡组，从额外卡组把1只「半龙女仆·龙女管家」特殊召唤。
function c24799107.initial_effect(c)
	-- 为卡片添加融合召唤手续，使用满足「半龙女仆」系列且等级5以上的龙族怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x133),c24799107.ffilter,true)
	c:EnableReviveLimit()
	-- ①：自己·对方的准备阶段才能发动。从自己的手卡·墓地把1只9星以下的「半龙女仆」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24799107,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,24799107)
	e1:SetTarget(c24799107.sptg)
	e1:SetOperation(c24799107.spop)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱·怪兽的效果发动时才能发动。以下效果全部适用。●那个发动无效并破坏。●这张卡回到额外卡组，从额外卡组把1只「半龙女仆·龙女管家」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24799107,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,24799108)
	e2:SetCondition(c24799107.discon)
	e2:SetTarget(c24799107.distg)
	e2:SetOperation(c24799107.disop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤函数，判断怪兽是否等级5以上且为龙族
function c24799107.ffilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON)
end
-- 特殊召唤过滤函数，判断怪兽是否等级9以下且为「半龙女仆」系列
function c24799107.spfilter(c,e,tp)
	return c:IsLevelBelow(9) and c:IsSetCard(0x133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，判断是否满足特殊召唤条件
function c24799107.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或墓地是否存在满足条件的「半龙女仆」怪兽
		and Duel.IsExistingMatchingCard(c24799107.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果发动时的操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤效果的处理函数，选择并特殊召唤符合条件的怪兽
function c24799107.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「半龙女仆」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24799107.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动条件函数，判断是否满足无效并破坏效果的发动条件
function c24799107.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此卡未在战斗中被破坏、连锁可被无效且发动者为对方
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and ep==1-tp
end
-- 特殊召唤过滤函数，判断「半龙女仆·龙女管家」是否可特殊召唤且有足够区域
function c24799107.cfilter(c,e,tp,ec)
	-- 判断「半龙女仆·龙女管家」是否满足特殊召唤条件
	return c:IsCode(41232647) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0
end
-- 无效并破坏效果的处理函数，设置操作信息
function c24799107.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断此卡是否可送入额外卡组并存在满足条件的「半龙女仆·龙女管家」
	if chk==0 then return c:IsAbleToExtra() and Duel.IsExistingMatchingCard(c24799107.cfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息，表示将要使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示将要破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 设置操作信息，表示将要从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 无效并破坏效果的处理函数，执行无效、破坏和特殊召唤操作
function c24799107.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使连锁发动无效并判断发动的卡是否可破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
	if c:IsRelateToEffect(e) then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 判断此卡是否成功送入额外卡组且仍在额外卡组
		if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA) then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的「半龙女仆·龙女管家」
			local g=Duel.SelectMatchingCard(tp,c24799107.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
			if g:GetCount()>0 then
				-- 将选中的「半龙女仆·龙女管家」特殊召唤到场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
