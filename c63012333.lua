--精気を吸う骨の塔
-- 效果：
-- 若自己场上有除这张卡以外的不死族怪兽存在，则这张卡不能被攻击。每当不死族怪兽特殊召唤成功时，将对方卡组最上面2张卡送去墓地。
function c63012333.initial_effect(c)
	-- 若自己场上有除这张卡以外的不死族怪兽存在，则这张卡不能被攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c63012333.atklm)
	-- 设置不能成为攻击对象效果的Value，使用内置过滤函数aux.imval1以防止受效果免疫影响
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 每当不死族怪兽特殊召唤成功时，将对方卡组最上面2张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63012333,0))  --"对方卡组最上面2张卡送去墓地"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c63012333.condition)
	e2:SetTarget(c63012333.target)
	e2:SetOperation(c63012333.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选场上表侧表示的不死族怪兽
function c63012333.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 不能被攻击效果的启用条件：自己场上存在除这张卡以外的不死族怪兽
function c63012333.atklm(e)
	local c=e:GetHandler()
	-- 检查自己场上是否存在至少1张除自身以外的表侧表示不死族怪兽
	return Duel.IsExistingMatchingCard(c63012333.filter,c:GetControler(),LOCATION_MZONE,0,1,c)
end
-- 触发条件：特殊召唤成功的怪兽中不包含这张卡自身，且其中存在至少1只不死族怪兽
function c63012333.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c63012333.filter,1,nil)
end
-- 效果发动靶向：必发效果直接通过，并设置将对方卡组最上方2张卡送去墓地的操作信息
function c63012333.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方卡组最上面2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,2)
end
-- 效果运行：将对方卡组最上面2张卡送去墓地
function c63012333.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方卡组最上面2张卡因效果送去墓地
	Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
end
