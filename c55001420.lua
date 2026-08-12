--深緑の魔弓使い
-- 效果：
-- 若自己场上有植物族怪兽存在，则这张卡不能被攻击。每祭掉自己场上1只植物族怪兽，就能破坏场上1张魔法·陷阱卡。
function c55001420.initial_effect(c)
	-- 若自己场上有植物族怪兽存在，则这张卡不能被攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c55001420.ccon)
	-- 设置不能成为攻击对象效果的过滤函数
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 每祭掉自己场上1只植物族怪兽，就能破坏场上1张魔法·陷阱卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55001420,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c55001420.descost)
	e2:SetTarget(c55001420.destg)
	e2:SetOperation(c55001420.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的植物族怪兽
function c55001420.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 不能被攻击效果的发动条件：自己场上存在植物族怪兽
function c55001420.ccon(e)
	-- 检查自己场上是否存在至少1只表侧表示的植物族怪兽
	return Duel.IsExistingMatchingCard(c55001420.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 起动效果的代价：解放自己场上1只植物族怪兽
function c55001420.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的植物族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_PLANT) end
	-- 玩家选择自己场上1只植物族怪兽用于解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_PLANT)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：魔法或陷阱卡
function c55001420.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 起动效果的目标：选择场上1张魔法·陷阱卡作为对象
function c55001420.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c55001420.filter(chkc) end
	-- 检查场上是否存在可作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c55001420.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c55001420.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 起动效果的处理：破坏选中的卡
function c55001420.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
