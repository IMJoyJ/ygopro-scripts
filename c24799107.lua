--ドラゴンメイド・シュトラール
-- 效果：
-- 「半龙女仆」怪兽＋5星以上的龙族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的准备阶段才能发动。从自己的手卡·墓地把1只9星以下的「半龙女仆」怪兽特殊召唤。
-- ②：对方把魔法·陷阱·怪兽的效果发动时才能发动。以下效果全部适用。
-- ●那个发动无效并破坏。
-- ●这张卡回到额外卡组，从额外卡组把1只「半龙女仆·龙女管家」特殊召唤。
function c24799107.initial_effect(c)
	-- 记录这张卡文本中记述了「半龙女仆·龙女管家」(41232647)卡名的事实
	aux.AddCodeList(c,41232647)
	-- 为这张卡注册融合召唤手续：以1只「半龙女仆」怪兽和1只满足ffilter的怪兽共2只作为融合素材（允许使用替代素材）
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x133),c24799107.ffilter,true)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方的准备阶段才能发动。从自己的手卡·墓地把1只9星以下的「半龙女仆」怪兽特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：对方把魔法·陷阱·怪兽的效果发动时才能发动。以下效果全部适用。●那个发动无效并破坏。●这张卡回到额外卡组，从额外卡组把1只「半龙女仆·龙女管家」特殊召唤。
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
-- 融合素材过滤函数，筛选5星以上的龙族怪兽
function c24799107.ffilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON)
end
-- 过滤函数，筛选9星以下、属于「半龙女仆」字段且可以被特殊召唤的怪兽
function c24799107.spfilter(c,e,tp)
	return c:IsLevelBelow(9) and c:IsSetCard(0x133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的Target函数，检测怪兽区空格及手卡·墓地存在可特招的9星以下「半龙女仆」怪兽，并设置特殊召唤操作信息
function c24799107.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡·墓地是否存在至少1只满足spfilter条件可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c24799107.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，声明将从自己的手卡·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果的Operation函数，从自己的手卡·墓地选择1只9星以下的「半龙女仆」怪兽（校验王谷抗性）特殊召唤
function c24799107.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区没有可用空格则终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己在手卡·墓地选择1只满足spfilter且不受「王家长眠之谷」影响的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24799107.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的Condition函数，确认这张卡未处于战斗破坏确定状态、连锁可被无效且发动玩家为对方
function c24799107.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡未处于战破状态，当前连锁发动可以被无效，且发动者是对方玩家
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and ep==1-tp
end
-- 过滤函数，筛选额外卡组中可特殊召唤且考虑ec离场后仍有额外怪兽区可用格子的「半龙女仆·龙女管家」
function c24799107.cfilter(c,e,tp,ec)
	-- 检查卡号是否为「半龙女仆·龙女管家」(41232647)、能否被特殊召唤以及ec离场后额外卡组特招格子是否足够
	return c:IsCode(41232647) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0
end
-- ②效果的Target函数，检查这张卡可回额外卡组及额外卡组有可特招的管家，并设置无效、破坏与特招的操作信息
function c24799107.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检测时，检查这张卡能否回到额外卡组，且额外卡组存在满足cfilter的怪兽
	if chk==0 then return c:IsAbleToExtra() and Duel.IsExistingMatchingCard(c24799107.cfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息，声明将使对象连锁卡eg的效果发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，声明将破坏对象连锁卡eg
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 设置操作信息，声明将从自己额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的Operation函数，先无效并破坏对方发动的卡，然后中断处理将这张卡返回额外卡组并特殊召唤「半龙女仆·龙女管家」
function c24799107.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 尝试使对方连锁ev的发动无效，若成功且发动源卡与效果仍有关联则继续处理破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏对方发动的卡eg
		Duel.Destroy(eg,REASON_EFFECT)
	end
	if c:IsRelateToEffect(e) then
		-- 插入效果处理中断，使之后回额外卡组与特招的处理视为与前面不同时发生
		Duel.BreakEffect()
		-- 以效果将这张卡送回额外卡组并确认其已成功进入额外卡组
		if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA) then
			-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让自己在额外卡组中选择1只满足cfilter条件的「半龙女仆·龙女管家」
			local g=Duel.SelectMatchingCard(tp,c24799107.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
			if g:GetCount()>0 then
				-- 将选中的怪兽以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
