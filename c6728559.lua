--アークネメシス・プロートス
-- 效果：
-- 这张卡不能通常召唤。从自己的场上（表侧表示）·墓地把3只属性不同的怪兽除外的场合可以特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：场上的这张卡不会被效果破坏。
-- ②：宣言场上的怪兽1个属性才能发动。场上的宣言属性的怪兽全部破坏。直到下个回合的结束时，双方不能把宣言的属性的怪兽特殊召唤。
function c6728559.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己的场上（表侧表示）·墓地把3只属性不同的怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c6728559.sprcon)
	e1:SetTarget(c6728559.sprtg)
	e1:SetOperation(c6728559.sprop)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：宣言场上的怪兽1个属性才能发动。场上的宣言属性的怪兽全部破坏。直到下个回合的结束时，双方不能把宣言的属性的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6728559,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,6728559)
	e3:SetTarget(c6728559.destg)
	e3:SetOperation(c6728559.desop)
	c:RegisterEffect(e3)
end
-- 过滤特殊召唤所需除外卡片的条件：自己场上表侧表示或自己墓地的怪兽，且可以被除外
function c6728559.sprfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 检查选取的卡片组是否满足特殊召唤条件：除外后能留出怪兽区域空位，且选取的怪兽属性互不相同
function c6728559.fselect(g,tp)
	-- 检查将选取的卡片组除外后，自己场上是否有可用的怪兽区域，且选取的卡片属性互不相同
	return Duel.GetMZoneCount(tp,g)>0 and g:GetClassCount(Card.GetAttribute)==#g
end
-- 特殊召唤规则的条件函数：检查自己场上和墓地是否存在满足特殊召唤条件的3只属性不同的怪兽
function c6728559.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上（表侧表示）和墓地中所有满足除外条件的怪兽
	local rg=Duel.GetMatchingGroup(c6728559.sprfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return rg:CheckSubGroup(c6728559.fselect,3,3,tp)
end
-- 特殊召唤规则的选取目标函数：让玩家选择3只属性不同的怪兽，并将其保存在效果标签对象中
function c6728559.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上（表侧表示）和墓地中所有满足除外条件的怪兽
	local rg=Duel.GetMatchingGroup(c6728559.sprfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=rg:SelectSubGroup(tp,c6728559.fselect,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行函数：将选取的怪兽除外，完成特殊召唤
function c6728559.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选取的怪兽以特殊召唤的消耗表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤场上表侧表示且为指定属性的怪兽
function c6728559.desfilter(c,attr)
	return c:IsFaceup() and c:IsAttribute(attr)
end
-- 效果②的启动与目标确认函数：检查场上是否存在表侧表示怪兽，获取场上所有表侧表示怪兽的属性并让玩家宣言其中一个，然后设置破坏的操作信息
function c6728559.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	local attr=0
	while tc do
		attr=attr|tc:GetAttribute()
		tc=g:GetNext()
	end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从场上已存在的怪兽属性中宣言1个属性
	local at=Duel.AnnounceAttribute(tp,1,attr)
	e:SetLabel(at)
	-- 获取双方场上所有属于宣言属性的表侧表示怪兽
	local dg=Duel.GetMatchingGroup(c6728559.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,at)
	-- 设置连锁处理中的操作信息：破坏所有属于宣言属性的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果②的执行函数：破坏场上所有宣言属性的怪兽，并注册一个直到下个回合结束时限制双方特殊召唤该属性怪兽的全局效果
function c6728559.desop(e,tp,eg,ep,ev,re,r,rp)
	local attr=e:GetLabel()
	-- 获取双方场上所有属于宣言属性的表侧表示怪兽
	local dg=Duel.GetMatchingGroup(c6728559.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,attr)
	if dg:GetCount()>0 then
		-- 因效果破坏所有选中的怪兽
		Duel.Destroy(dg,REASON_EFFECT)
	end
	-- 直到下个回合的结束时，双方不能把宣言的属性的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,1)
	e1:SetLabel(attr)
	e1:SetTarget(c6728559.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将限制特殊召唤的全局效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的过滤函数：阻止特殊召唤与宣言属性相同的怪兽
function c6728559.splimit(e,c)
	return c:IsAttribute(e:GetLabel())
end
