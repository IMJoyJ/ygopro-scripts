--ドラゴンメイド・シュトラール
-- 效果：
-- 「半龙女仆」怪兽＋5星以上的龙族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的准备阶段才能发动。从自己的手卡·墓地把1只9星以下的「半龙女仆」怪兽特殊召唤。
-- ②：对方把魔法·陷阱·怪兽的效果发动时才能发动。以下效果全部适用。
-- ●那个发动无效并破坏。
-- ●这张卡回到额外卡组，从额外卡组把1只「半龙女仆·龙女管家」特殊召唤。
function c24799107.initial_effect(c)
	-- 为这张卡添加融合召唤手续：以1只「半龙女仆」怪兽和1只5星以上的龙族怪兽作为融合素材。
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
-- 融合素材过滤条件：怪兽为5星以上且种族为龙族。
function c24799107.ffilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON)
end
-- 特殊召唤对象的过滤条件：等级9以下、属于「半龙女仆」系列且可以被效果特殊召唤。
function c24799107.spfilter(c,e,tp)
	return c:IsLevelBelow(9) and c:IsSetCard(0x133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件：自己场上存在空余的怪兽区域，且手卡·墓地存在1只满足条件的「半龙女仆」怪兽（不取对象）。
function c24799107.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否有空余的怪兽区域（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手卡·墓地中存在至少1只等级9以下、属于「半龙女仆」且可被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c24799107.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将进行特殊召唤，特召对象从手卡·墓地中选取，数量为1，持有者为自己。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：从手卡·墓地选择1只满足条件的「半龙女仆」怪兽，以表侧表示特殊召唤到自己场上。
function c24799107.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有空余的怪兽区域，否则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·墓地选择1只满足 spfilter 的「半龙女仆」怪兽（自动排除因王家长眠之谷而不能从墓地特殊召唤的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24799107.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：此卡不处于战斗破坏确定状态，对方发动的效果可以被无效，且该效果由对方发动。
function c24799107.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认此卡没有被战斗破坏确定，且对方连锁的效果可被无效，且发动者为对方。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and ep==1-tp
end
-- 额外卡组特召对象的过滤条件：卡号为41232647（半龙女仆·龙女管家），可被特殊召唤，且此卡回额外卡组后仍有空位可特殊召唤额外怪兽。
function c24799107.cfilter(c,e,tp,ec)
	-- 判断额外卡组中的卡是否为「半龙女仆·龙女管家」、能否被特殊召唤，并确认回额外后额外卡组怪兽可用的区域数量大于0。
	return c:IsCode(41232647) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0
end
-- ②效果的发动条件与操作信息设置：此卡可回额外卡组，且额外卡组存在可特召的「半龙女仆·龙女管家」，同时登记无效、破坏、特召等处理信息。
function c24799107.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件确认：此卡可以回到额外卡组，且额外卡组存在1只可特殊召唤的「半龙女仆·龙女管家」。
	if chk==0 then return c:IsAbleToExtra() and Duel.IsExistingMatchingCard(c24799107.cfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息：要将对方发动的那个效果无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对方效果的那张卡可被破坏且仍与效果关联，则设置操作信息：破坏该卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 设置操作信息：将从额外卡组特殊召唤1只「半龙女仆·龙女管家」。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：无效并破坏对方发动的效果；随后此卡回到额外卡组，成功返回后从额外卡组特殊召唤1只「半龙女仆·龙女管家」。
function c24799107.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 尝试无效对方连锁的发动；若无效成功且对方效果卡仍与该连锁关联，则继续执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的效果的那张卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
	if c:IsRelateToEffect(e) then
		-- 中断当前效果处理，使后续回额外卡组和特殊召唤的操作与前面的无效·破坏分开处理。
		Duel.BreakEffect()
		-- 将此卡返回额外卡组（洗牌）；若返回成功且此卡现在位于额外卡组，则继续后续特殊召唤。
		if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA) then
			-- 发送“请选择要特殊召唤的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择1只满足 cfilter 的「半龙女仆·龙女管家」作为特殊召唤对象。
			local g=Duel.SelectMatchingCard(tp,c24799107.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
			if g:GetCount()>0 then
				-- 将选择的「半龙女仆·龙女管家」以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
