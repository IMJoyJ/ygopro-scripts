--聖刻龍－セテクドラゴン
-- 效果：
-- 这张卡不能通常召唤。把自己墓地3只龙族的通常怪兽从游戏中除外的场合可以特殊召唤。1回合1次，可以把自己墓地1只龙族怪兽从游戏中除外，选择场上1张卡破坏。
function c66789970.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己墓地3只龙族的通常怪兽从游戏中除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c66789970.hspcon)
	e1:SetTarget(c66789970.hsptg)
	e1:SetOperation(c66789970.hspop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把自己墓地1只龙族怪兽从游戏中除外，选择场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66789970,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c66789970.descost)
	e2:SetTarget(c66789970.destg)
	e2:SetOperation(c66789970.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地的龙族通常怪兽
function c66789970.rfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判定
function c66789970.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少3只龙族的通常怪兽
		and Duel.IsExistingMatchingCard(c66789970.rfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 特殊召唤规则的准备操作（选择要除外的怪兽）
function c66789970.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地所有满足条件的龙族通常怪兽
	local g=Duel.GetMatchingGroup(c66789970.rfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作
function c66789970.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽因特殊召唤而表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤条件：自己墓地的龙族怪兽
function c66789970.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost()
end
-- 破坏效果的发动代价
function c66789970.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以作为代价除外的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c66789970.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1只龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c66789970.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选定的怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 破坏效果的目标选择
function c66789970.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为对象的目标卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏选定的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行操作
function c66789970.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
