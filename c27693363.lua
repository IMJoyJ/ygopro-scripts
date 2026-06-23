--ベアルクティ－ポラリィ
-- 效果：
-- 这张卡不能同调召唤，等级差直到1为止从自己场上把调整1只和调整以外的怪兽1只送去墓地的场合才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组选1张「北极天熊北斗星」发动。
-- ②：把自己场上1只7星以上的怪兽解放才能发动。从自己墓地选1只「北极天熊」怪兽加入手卡或特殊召唤。
function c27693363.initial_effect(c)
	-- 记录该卡拥有「北极天熊北斗星」这张卡的卡名
	aux.AddCodeList(c,89264428)
	c:EnableReviveLimit()
	-- 这张卡不能同调召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 等级差直到1为止从自己场上把调整1只和调整以外的怪兽1只送去墓地的场合才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c27693363.sprcon)
	e2:SetTarget(c27693363.sprtg)
	e2:SetOperation(c27693363.sprop)
	c:RegisterEffect(e2)
	-- 这张卡特殊召唤成功的场合才能发动。从卡组选1张「北极天熊北斗星」发动
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27693363,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,27693363)
	e3:SetTarget(c27693363.acttg)
	e3:SetOperation(c27693363.actop)
	c:RegisterEffect(e3)
	-- 把自己场上1只7星以上的怪兽解放才能发动。从自己墓地选1只「北极天熊」怪兽加入手卡或特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27693363,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,27693364)
	e4:SetCost(c27693363.thcost)
	e4:SetTarget(c27693363.thtg)
	e4:SetOperation(c27693363.thop)
	c:RegisterEffect(e4)
end
-- 筛选场上表侧表示且等级大于等于1且能作为墓地化代价的怪兽
function c27693363.tgrfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsAbleToGraveAsCost()
end
-- 检查组中是否存在满足条件的怪兽
function c27693363.mnfilter(c,g)
	return g:IsExists(c27693363.mnfilter2,1,c,c)
end
-- 判断两个怪兽的等级差是否为1
function c27693363.mnfilter2(c,mc)
	return c:GetLevel()-mc:GetLevel()==1
end
-- 判断组中是否满足特殊召唤条件：2只怪兽、1只调整、1只非调整、等级差为1、额外卡组有足够召唤空间
function c27693363.fselect(g,tp,sc)
	return g:GetCount()==2
		-- 判断组中是否存在调整
		and g:IsExists(Card.IsType,1,nil,TYPE_TUNER) and g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_TUNER)
		and g:IsExists(c27693363.mnfilter,1,nil,g)
		-- 判断额外卡组是否有足够召唤空间
		and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
-- 判断是否满足特殊召唤条件
function c27693363.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c27693363.tgrfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c27693363.fselect,2,2,tp,c)
end
-- 获取场上所有满足条件的怪兽
function c27693363.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 提示玩家选择要送去墓地的卡
	local g=Duel.GetMatchingGroup(c27693363.tgrfilter,tp,LOCATION_MZONE,0,nil)
	-- 将选择的怪兽组送去墓地
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c27693363.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将选择的怪兽组送去墓地
function c27693363.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local tg=e:GetLabelObject()
	-- 将选择的怪兽组送去墓地
	Duel.SendtoGrave(tg,REASON_SPSUMMON)
	tg:DeleteGroup()
end
-- 筛选卡组中可以发动的「北极天熊北斗星」
function c27693363.actfilter(c,tp)
	return c:IsCode(89264428) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 判断卡组中是否存在可以发动的「北极天熊北斗星」
function c27693363.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在可以发动的「北极天熊北斗星」
	if chk==0 then return Duel.IsExistingMatchingCard(c27693363.actfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 选择并发动「北极天熊北斗星」
function c27693363.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择卡组中可以发动的「北极天熊北斗星」
	local g=Duel.SelectMatchingCard(tp,c27693363.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		local te=tc:GetActivateEffect()
		-- 获取场上已存在的灵摆区域的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将场上已存在的灵摆区域的卡送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果
			Duel.BreakEffect()
		end
		-- 将卡移动到灵摆区域
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发卡的发动时点
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
-- 筛选场上等级大于等于7的怪兽
function c27693363.rfilter(c,tp)
	return c:IsLevelAbove(7) and (c:IsControler(tp) or c:IsFaceup())
end
-- 筛选墓地中可以被除外的怪兽
function c27693363.excostfilter(c,tp)
	return c:IsAbleToRemove() and (c:IsHasEffect(16471775,tp) or c:IsHasEffect(89264428,tp))
end
-- 判断是否满足解放条件
function c27693363.costfilter(c,e,tp)
	-- 判断场上是否有召唤空间
	local check=Duel.GetMZoneCount(tp,c)>0
	-- 判断墓地中是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(c27693363.tgfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,check)
end
-- 筛选墓地中「北极天熊」怪兽
function c27693363.tgfilter(c,e,tp,check)
	return c:IsSetCard(0x163) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 设置解放怪兽的费用
function c27693363.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上可解放的怪兽
	local g1=Duel.GetReleaseGroup(tp):Filter(c27693363.rfilter,nil,tp)
	-- 获取墓地中可除外的怪兽
	local g2=Duel.GetMatchingGroup(c27693363.excostfilter,tp,LOCATION_GRAVE,0,nil,tp)
	g1:Merge(g2)
	if chk==0 then return g1:IsExists(c27693363.costfilter,1,nil,e,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g1:FilterSelect(tp,c27693363.costfilter,1,1,nil,e,tp)
	local tc=rg:GetFirst()
	local te=tc:IsHasEffect(16471775,tp) or tc:IsHasEffect(89264428,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 使用额外解放次数
		aux.UseExtraReleaseCount(rg,tp)
		-- 解放怪兽
		Duel.Release(tc,REASON_COST)
	end
end
-- 判断墓地中是否存在满足条件的怪兽
function c27693363.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断墓地中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27693363.tgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,true) end
end
-- 选择并处理墓地中的「北极天熊」怪兽
function c27693363.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有召唤空间
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择墓地中满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27693363.tgfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,check)
	local tc=g:GetFirst()
	if tc then
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or not check
			-- 选择将怪兽加入手卡或特殊召唤
			or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		else
			-- 将怪兽特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
