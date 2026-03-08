--雷神龍－サンダー・ドラゴン
-- 效果：
-- 「雷龙」怪兽×3
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把手卡1只雷族怪兽和「雷神龙-雷龙」以外的自己场上1只雷族融合怪兽除外的场合可以从额外卡组特殊召唤。
-- ①：雷族怪兽的效果在手卡发动时才能发动（伤害步骤也能发动）。场上1张卡破坏。
-- ②：场上的这张卡被效果破坏的场合，可以作为代替把自己墓地2张卡除外。
function c41685633.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用3个满足条件的雷族融合怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x11c),3,true)
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡只能通过融合召唤特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ●把手卡1只雷族怪兽和「雷神龙-雷龙」以外的自己场上1只雷族融合怪兽除外的场合可以从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c41685633.sprcon)
	e2:SetTarget(c41685633.sptg)
	e2:SetOperation(c41685633.sprop)
	c:RegisterEffect(e2)
	-- ①：雷族怪兽的效果在手卡发动时才能发动（伤害步骤也能发动）。场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41685633,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c41685633.descon)
	e3:SetTarget(c41685633.destg)
	e3:SetOperation(c41685633.desop)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡被效果破坏的场合，可以作为代替把自己墓地2张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(c41685633.desreptg)
	c:RegisterEffect(e4)
end
-- 筛选手卡或场上的雷族怪兽，满足能作为融合素材的条件
function c41685633.sprfilter1(c,sc)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToRemoveAsCost() and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 筛选场上的雷族融合怪兽，排除自身以外的雷神龙-雷龙
function c41685633.sprfilter2(c)
	if not (c:IsLocation(LOCATION_MZONE) and c:IsFusionType(TYPE_FUSION)) then return false end
	if not c:IsFusionCode(41685633) then return true end
	for i,code in ipairs({c:GetFusionCode()}) do
		if code~=41685633 then return true end
	end
	return false
end
-- 检查所选的2张卡是否满足条件：一张在手卡，一张为雷族融合怪兽
function c41685633.fselect(g,tp,sc)
	-- 检查所选的2张卡是否满足条件：一张在手卡，一张为雷族融合怪兽
	return aux.gffcheck(g,Card.IsLocation,LOCATION_HAND,c41685633.sprfilter2,nil)
		-- 检查是否有足够的额外卡组召唤空间
		and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
-- 判断是否满足特殊召唤条件：手卡和场上的雷族怪兽组合满足要求
function c41685633.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足条件的雷族怪兽组
	local g=Duel.GetMatchingGroup(c41685633.sprfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,c)
	return g:CheckSubGroup(c41685633.fselect,2,2,tp,c)
end
-- 获取满足条件的雷族怪兽组并选择2张进行特殊召唤
function c41685633.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的雷族怪兽组
	local g=Duel.GetMatchingGroup(c41685633.sprfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,c)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c41685633.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤操作，将选中的卡除外作为召唤素材
function c41685633.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	-- 将选中的卡以除外形式移除
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否为手卡发动的雷族怪兽效果
function c41685633.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的触发位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_HAND)~=0 and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetOriginalRace()==RACE_THUNDER
end
-- 设置破坏效果的目标和数量
function c41685633.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可破坏的卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有可破坏的卡
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，选择并破坏一张卡
function c41685633.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可破坏的卡
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显示选中卡的动画效果
		Duel.HintSelection(sg)
		-- 将选中的卡以破坏形式移除
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 判断是否满足代替破坏的条件
function c41685633.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
		-- 检查墓地是否存在2张可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,2,nil) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择2张墓地的卡进行除外
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,2,2,nil)
		-- 将选中的卡以除外形式移除
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		return true
	else return false end
end
