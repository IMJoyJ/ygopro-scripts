--大天使ゼラート
-- 效果：
-- 这张卡不能进行通常召唤。这张卡仅当场上存在「天空的圣域」时，祭掉自己场上1只以表侧表示存在的「杰拉的战士」才能特殊召唤。从手卡将1张光属性怪兽卡弃到墓地，破坏对方场上存在的所有怪兽。此效果仅当自己场上存在「天空的圣域」时才适用。
function c18378582.initial_effect(c)
	-- 记录该卡具有「天空的圣域」这张场地卡的卡名
	aux.AddCodeList(c,56433456)
	c:EnableReviveLimit()
	-- 这张卡不能进行通常召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡仅当场上存在「天空的圣域」时，祭掉自己场上1只以表侧表示存在的「杰拉的战士」才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c18378582.spcon)
	e2:SetTarget(c18378582.sptg)
	e2:SetOperation(c18378582.spop)
	c:RegisterEffect(e2)
	-- 从手卡将1张光属性怪兽卡弃到墓地，破坏对方场上存在的所有怪兽。此效果仅当自己场上存在「天空的圣域」时才适用
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18378582,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c18378582.descost)
	e3:SetTarget(c18378582.destg)
	e3:SetOperation(c18378582.desop)
	c:RegisterEffect(e3)
end
-- 用于判断是否满足特殊召唤条件的过滤函数，检查场上是否存在表侧表示的「杰拉的战士」且有可用怪兽区
function c18378582.rfilter(c,tp)
	-- 检查目标怪兽是否为表侧表示、卡号为「杰拉的战士」且当前玩家场上存在可用怪兽区
	return c:IsFaceup() and c:IsCode(66073051) and Duel.GetMZoneCount(tp,c)>0
end
-- 判断特殊召唤条件是否满足的函数，检查是否满足场地条件并能解放符合条件的怪兽
function c18378582.spcon(e,c)
	-- 当该卡为nil时，检查当前是否处于「天空的圣域」场地效果下
	if c==nil then return Duel.IsEnvironment(56433456) end
	-- 检查当前玩家场上是否存在满足rfilter条件的怪兽用于特殊召唤的解放
	return Duel.CheckReleaseGroupEx(c:GetControler(),c18378582.rfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 设置特殊召唤时选择解放怪兽的处理函数，从符合条件的怪兽中选择1只进行解放
function c18378582.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可解放的怪兽组，并筛选出符合条件的「杰拉的战士」
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c18378582.rfilter,nil,tp)
	-- 向玩家发送提示信息，提示选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作，将之前选择的怪兽进行解放
function c18378582.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽以特殊召唤的方式进行解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 用于判断手卡中是否存在满足条件的光属性怪兽卡的过滤函数
function c18378582.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 设置破坏效果的发动费用，丢弃一张光属性怪兽卡作为代价
function c18378582.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡中是否存在至少一张光属性且可丢弃的怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c18378582.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手卡中丢弃一张满足条件的光属性怪兽卡作为发动费用
	Duel.DiscardHand(tp,c18378582.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置破坏效果的目标处理函数，确定要破坏对方场上所有怪兽
function c18378582.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少一只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有怪兽的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定要破坏的怪兽数量和类型
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，当满足场地条件时破坏对方场上所有怪兽
function c18378582.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否处于「天空的圣域」场地效果下
	if Duel.IsEnvironment(56433456) then
		-- 获取对方场上所有怪兽的卡片组
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 将指定的怪兽以效果原因进行破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
