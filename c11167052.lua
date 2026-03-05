--霊神統一
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「灵神的圣殿」不会被效果破坏，不会成为对方的效果的对象。
-- ②：1回合1次，把自己场上1只怪兽解放才能发动。原本属性和解放的怪兽不同的1只「元素灵剑士」怪兽从卡组特殊召唤。
-- ③：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。手卡全部丢弃。那之后，从自己墓地选这个效果丢弃的卡数量的「灵神」怪兽加入手卡。
function c11167052.initial_effect(c)
	-- 为卡片注册关联卡片代码，标明效果文本中存在「灵神的圣殿」
	aux.AddCodeList(c,61557074)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔法与陷阱区域存在，自己场上的「灵神的圣殿」不会被效果破坏，不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c11167052.intg)
	-- 设置效果值为过滤函数，用于判断是否能成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 1回合1次，把自己场上1只怪兽解放才能发动。原本属性和解放的怪兽不同的1只「元素灵剑士」怪兽从卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(11167052,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c11167052.spcost)
	e4:SetTarget(c11167052.sptg)
	e4:SetOperation(c11167052.spop)
	c:RegisterEffect(e4)
	-- 把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。手卡全部丢弃。那之后，从自己墓地选这个效果丢弃的卡数量的「灵神」怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(11167052,1))  --"墓地回收"
	e5:SetCategory(CATEGORY_HANDES+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMING_END_PHASE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c11167052.thcon)
	e5:SetCost(c11167052.thcost)
	e5:SetTarget(c11167052.thtg)
	e5:SetOperation(c11167052.thop)
	c:RegisterEffect(e5)
end
-- 过滤函数，判断目标是否为表侧表示的「灵神的圣殿」
function c11167052.intg(e,c)
	return c:IsFaceup() and c:IsCode(61557074)
end
-- 设置标记用于判断是否满足特殊召唤条件
function c11167052.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤函数，判断是否存在满足条件的怪兽用于解放并能从卡组特殊召唤
function c11167052.filter1(c,e,tp)
	-- 检查卡组中是否存在满足条件的「元素灵剑士」怪兽
	return Duel.IsExistingMatchingCard(c11167052.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalAttribute())
		-- 检查场上是否有足够的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤函数，判断是否为「元素灵剑士」且属性与解放怪兽不同
function c11167052.filter2(c,e,tp,att)
	return c:IsSetCard(0x400d) and c:GetOriginalAttribute()~=att and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标和处理逻辑
function c11167052.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在满足条件的可解放怪兽
		return Duel.CheckReleaseGroup(tp,c11167052.filter1,1,nil,e,tp)
	end
	-- 选择场上满足条件的可解放怪兽
	local rg=Duel.SelectReleaseGroup(tp,c11167052.filter1,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetOriginalAttribute())
	-- 将选中的怪兽解放作为特殊召唤的代价
	Duel.Release(rg,REASON_COST)
	-- 设置操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤效果的处理逻辑
function c11167052.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local att=e:GetLabel()
	-- 提示玩家选择特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c11167052.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,att)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断效果是否处于启用状态
function c11167052.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 设置墓地回收效果的发动代价
function c11167052.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，判断是否为「灵神」怪兽
function c11167052.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x113) and c:IsAbleToHand()
end
-- 设置墓地回收效果的目标和处理逻辑
function c11167052.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家手牌组
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local ct=hg:GetCount()
	-- 检查是否存在满足条件的「灵神」怪兽
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(c11167052.thfilter,tp,LOCATION_GRAVE,0,ct,nil) end
	-- 设置操作信息，表示将丢弃手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,hg,ct,0,0)
	-- 设置操作信息，表示将从墓地回收怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_GRAVE)
end
-- 执行墓地回收效果的处理逻辑
function c11167052.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家手牌组
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将手牌全部送去墓地
	local ct=Duel.SendtoGrave(hg,REASON_EFFECT+REASON_DISCARD)
	if ct<=0 then return end
	-- 提示玩家选择要回收的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从墓地中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c11167052.thfilter,tp,LOCATION_GRAVE,0,ct,ct,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
