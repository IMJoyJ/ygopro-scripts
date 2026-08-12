--滅亡き闇 ヴェイドス
-- 效果：
-- 「灭亡龙 威多释」＋9星以下的炎族怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡融合召唤的场合才能发动。对方场上的魔法·陷阱卡全部破坏。
-- ②：只要这张卡在怪兽区域存在，这张卡不会被效果破坏，对方不能把这张卡作为怪兽的效果的对象。
-- ③：对方把场上的魔法·陷阱·怪兽的效果发动时，把自己场上1张表侧表示的「灰灭」卡送去墓地才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册融合召唤手续、不能成为对方怪兽效果对象、不会被效果破坏、融合召唤成功时破坏对方魔陷、对方发动场上效果时送墓场上「灰灭」卡来破坏该卡等效果
function s.initial_effect(c)
	-- 设置融合召唤手续：以卡号78783557（灭亡龙 威多释）和2只以上满足过滤条件s.ffilter的怪兽作为融合素材
	aux.AddFusionProcCodeFunRep(c,78783557,s.ffilter,2,127,true,true)
	c:EnableReviveLimit()
	-- 对方不能把这张卡作为怪兽的效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- 只要这张卡在怪兽区域存在，这张卡不会被效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：这张卡融合召唤的场合才能发动。对方场上的魔法·陷阱卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏魔法陷阱"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ③：对方把场上的魔法·陷阱·怪兽的效果发动时，把自己场上1张表侧表示的「灰灭」卡送去墓地才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"破坏发动效果的卡"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.descon2)
	e4:SetCost(s.descost2)
	e4:SetTarget(s.destg2)
	e4:SetOperation(s.desop2)
	c:RegisterEffect(e4)
end
-- 融合素材过滤条件：等级9以下的炎族怪兽
function s.ffilter(c)
	return c:IsLevelBelow(9) and c:IsRace(RACE_PYRO)
end
-- 过滤对方发动的怪兽效果（用于抗性判定）
function s.efilter(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and e:GetHandlerPlayer()~=re:GetHandlerPlayer()
end
-- 效果①的发动条件：此卡是通过融合召唤特殊召唤的
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤魔法·陷阱卡
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的发动准备：检查对方场上是否存在魔陷，并设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查对方场上是否存在至少1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有的魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁处理的操作信息：破坏对方场上的所有魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 向对方玩家提示发动了“破坏对方场上魔陷”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))  --"破坏魔法陷阱"
end
-- 效果①的效果处理：获取并破坏对方场上的所有魔法·陷阱卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏获取到的卡片组
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 效果③的发动条件：对方在场上发动卡或效果
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re)
		and rp~=tp
end
-- 过滤用于支付Cost的卡：自己场上表侧表示的「灰灭」卡
function s.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1ad) and c:IsAbleToGraveAsCost()
end
-- 效果③的Cost处理：检查并选择自己场上1张表侧表示的「灰灭」卡送去墓地
function s.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除发动效果的卡以外的、可送去墓地的表侧表示「灰灭」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,re:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1张表侧表示的「灰灭」卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,re:GetHandler())
	-- 将选中的卡作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果③的发动准备：检查发动效果的卡是否可破坏，并设置破坏的操作信息
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 设置连锁处理的操作信息：破坏发动效果的那张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	-- 向对方玩家提示发动了“破坏发动效果的卡”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))  --"破坏发动效果的卡"
end
-- 效果③的效果处理：若发动效果的卡仍存在，则将其破坏
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 因效果破坏发动效果的那张卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
