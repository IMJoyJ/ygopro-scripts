--AtoZ－ドラゴン・バスターキャノン
-- 效果：
-- 「ABC-神龙歼灭者」＋「XYZ-神龙炮」
-- 把自己场上的原本卡名是上记的卡除外的场合才能特殊召唤。
-- ①：对方把怪兽的效果·魔法·陷阱卡发动时，丢弃1张手卡才能发动。那个发动无效并破坏。
-- ②：自己·对方回合，把场上的这张卡除外，以自己的除外状态的「ABC-神龙歼灭者」「XYZ-神龙炮」各1只为对象才能发动。那些怪兽特殊召唤。
function c65172015.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「ABC-神龙歼灭者」和「XYZ-神龙炮」的融合召唤手续
	aux.AddFusionProcCode2(c,1561110,91998119,true,true)
	-- 把自己场上的原本卡名是上记的卡除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上的原本卡名是上记的卡除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c65172015.spcon)
	e2:SetTarget(c65172015.sptg)
	e2:SetOperation(c65172015.spop)
	c:RegisterEffect(e2)
	-- ①：对方把怪兽的效果·魔法·陷阱卡发动时，丢弃1张手卡才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65172015,0))  --"丢弃1张手卡，发动无效并破坏"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c65172015.discon)
	e3:SetCost(c65172015.discost)
	e3:SetTarget(c65172015.distg)
	e3:SetOperation(c65172015.disop)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合，把场上的这张卡除外，以自己的除外状态的「ABC-神龙歼灭者」「XYZ-神龙炮」各1只为对象才能发动。那些怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(65172015,1))  --"把这张卡除外，把除外的怪兽特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCost(c65172015.spcost)
	e4:SetTarget(c65172015.sptg2)
	e4:SetOperation(c65172015.spop2)
	c:RegisterEffect(e4)
end
-- 过滤场上原本卡名为「ABC-神龙歼灭者」或「XYZ-神龙炮」、可以被除外且可以作为特殊召唤素材的卡片
function c65172015.matfilter(c,sc)
	return c:IsOriginalCodeRule(1561110,91998119) and c:IsAbleToRemoveAsCost() and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 检查选取的卡片组是否包含原本卡名分别为「ABC-神龙歼灭者」和「XYZ-神龙炮」的各1张卡，且特殊召唤该卡时额外卡组区域有空位
function c65172015.fselect(g,tp,sc)
	-- 检查卡片组中是否包含原本卡名分别为「ABC-神龙歼灭者」和「XYZ-神龙炮」的各1张卡
	return aux.gfcheck(g,Card.IsOriginalCodeRule,1561110,91998119)
		-- 检查将这些卡除外后，额外卡组是否有足够的格子用于特殊召唤这张卡
		and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
-- 特殊召唤规则的条件判定函数，检查场上是否存在满足特殊召唤条件的卡片组合
function c65172015.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有满足素材过滤条件的卡片
	local g=Duel.GetMatchingGroup(c65172015.matfilter,tp,LOCATION_ONFIELD,0,nil,c)
	return g:CheckSubGroup(c65172015.fselect,2,2,tp,c)
end
-- 特殊召唤规则的素材选择函数，让玩家选择用于特殊召唤的素材卡片组
function c65172015.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足素材过滤条件的卡片
	local g=Duel.GetMatchingGroup(c65172015.matfilter,tp,LOCATION_ONFIELD,0,nil,c)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c65172015.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行函数，将选定的素材除外并进行特殊召唤
function c65172015.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	-- 将选定的素材卡片表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判定是否满足发动无效效果的条件（对方发动卡或效果，且该发动可以被无效，自身未被战斗破坏）
function c65172015.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查发动的效果是否为怪兽效果或魔法·陷阱卡的发动，且该发动可以被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 发动无效效果的Cost消耗处理函数（丢弃1张手卡）
function c65172015.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为发动Cost
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 发动无效效果的Target目标处理函数，设置操作信息
function c65172015.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为“使该发动无效”
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理信息为“破坏该卡”
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 发动无效效果的Operation执行函数，使发动无效并破坏该卡
function c65172015.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该效果的发动，若无效失败则结束处理
	if not Duel.NegateActivation(ev) then return end
	if re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 特殊召唤除外怪兽效果的Cost消耗处理函数（将场上的这张卡除外）
function c65172015.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将场上的这张卡表侧表示除外作为发动Cost
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤除外状态的、可以特殊召唤的「ABC-神龙歼灭者」，且此时除外状态还存在可以特殊召唤的「XYZ-神龙炮」
function c65172015.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsCode(1561110) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查除外状态是否存在另一只可以特殊召唤的「XYZ-神龙炮」
		and Duel.IsExistingTarget(c65172015.spfilter3,tp,LOCATION_REMOVED,0,1,c,e,tp)
end
-- 过滤除外状态的、可以特殊召唤的「XYZ-神龙炮」
function c65172015.spfilter3(c,e,tp)
	return c:IsFaceup() and c:IsCode(91998119) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤除外怪兽效果的Target目标处理函数，选择特殊召唤的对象并设置操作信息
function c65172015.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		-- 获取自己场上怪兽区域的可用空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ft>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查除外状态是否存在可以特殊召唤的「ABC-神龙歼灭者」和「XYZ-神龙炮」
			and Duel.IsExistingTarget(c65172015.spfilter2,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择除外状态的1只「ABC-神龙歼灭者」作为特殊召唤的对象
	local g1=Duel.SelectTarget(tp,c65172015.spfilter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择除外状态的1只「XYZ-神龙炮」作为特殊召唤的对象
	local g2=Duel.SelectTarget(tp,c65172015.spfilter3,tp,LOCATION_REMOVED,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	-- 设置效果处理信息为“特殊召唤这2只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 特殊召唤除外怪兽效果的Operation执行函数，将选定的对象特殊召唤
function c65172015.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁中仍与效果相关的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()<=ft then
		-- 将目标怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选定的怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		-- 因怪兽区域不足，将无法特殊召唤的其余目标怪兽送去墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
