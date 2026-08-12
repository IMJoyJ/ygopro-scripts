--コスモブレイン
-- 效果：
-- 这张卡不能通常召唤。从手卡以及自己场上的表侧表示怪兽之中把效果怪兽以外的1只怪兽送去墓地的场合可以特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升因为这张卡特殊召唤而送去墓地的怪兽的等级×200。
-- ②：把自己场上1只效果怪兽解放才能发动。从手卡·卡组把1只通常怪兽特殊召唤。
function c85679527.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从手卡以及自己场上的表侧表示怪兽之中把效果怪兽以外的1只怪兽送去墓地的场合可以特殊召唤。①：这张卡的攻击力上升因为这张卡特殊召唤而送去墓地的怪兽的等级×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c85679527.sprcon)
	e1:SetTarget(c85679527.sprtg)
	e1:SetOperation(c85679527.sprop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只效果怪兽解放才能发动。从手卡·卡组把1只通常怪兽特殊召唤。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85679527,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,85679527)
	e2:SetCost(c85679527.spcost)
	e2:SetTarget(c85679527.sptg)
	e2:SetOperation(c85679527.spop)
	c:RegisterEffect(e2)
end
-- 过滤用于特殊召唤此卡的送去墓地的怪兽（手卡或场上表侧表示的效果怪兽以外的怪兽，且能送去墓地并能腾出怪兽区域）
function c85679527.sprfilter(c,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and not c:IsType(TYPE_EFFECT) and c:IsType(TYPE_MONSTER)
		-- 检查卡片是否能作为代价送去墓地，且该卡离开场后能腾出至少1个怪兽区域
		and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件函数：检查手卡或场上是否存在至少1只满足送墓条件的非效果怪兽
function c85679527.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查手卡或自己场上是否存在至少1张满足特殊召唤过滤条件的卡
	return Duel.IsExistingMatchingCard(c85679527.sprfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤规则的目标选择函数：让玩家选择1只用于特殊召唤送去墓地的怪兽，并将其记录在效果对象中
function c85679527.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡及自己场上所有满足送墓条件的非效果怪兽组
	local g=Duel.GetMatchingGroup(c85679527.sprfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,tp)
	-- 给玩家发送提示信息，要求选择送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作函数：将选定的怪兽送去墓地，并根据其等级上升此卡的攻击力
function c85679527.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local rc=e:GetLabelObject()
	local lv=rc:GetLevel()
	-- 将用于特殊召唤的怪兽送去墓地
	Duel.SendtoGrave(rc,REASON_SPSUMMON)
	if not rc:IsType(TYPE_MONSTER) or lv<=0 then return end
	-- ①：这张卡的攻击力上升因为这张卡特殊召唤而送去墓地的怪兽的等级×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(lv*200)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 过滤解放发动效果所需的效果怪兽（必须是效果怪兽，且解放后能腾出怪兽区域）
function c85679527.costfilter(c,tp)
	-- 检查卡片是否为效果怪兽，且该卡被解放后能腾出至少1个可供自己特殊召唤的怪兽区域
	return c:IsType(TYPE_EFFECT) and Duel.GetMZoneCount(tp,c,tp)>0
end
-- 效果②的发动代价函数：检查并解放自己场上的1只效果怪兽
function c85679527.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查自己场上是否存在至少1只可解放的效果怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c85679527.costfilter,1,nil,tp) end
	-- 让玩家从场上选择1只满足条件的效果怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c85679527.costfilter,1,1,nil,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤手卡·卡组中可以特殊召唤的通常怪兽
function c85679527.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向/发动准备函数：检查手卡·卡组中是否存在可特殊召唤的通常怪兽，并设置特殊召唤的操作信息
function c85679527.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查手卡或卡组中是否存在至少1只可以特殊召唤的通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85679527.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前处理的连锁的操作信息，表示此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果②的效果处理函数：从手卡·卡组选择1只通常怪兽特殊召唤到场上
function c85679527.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，要求选择特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组中选择1只满足特殊召唤条件的通常怪兽
	local g=Duel.SelectMatchingCard(tp,c85679527.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
