--天威の龍拳聖
-- 效果：
-- 包含连接怪兽的怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡不会被和效果怪兽的战斗破坏。
-- ②：自己场上没有其他的效果怪兽存在的场合才能发动。选最多有自己墓地以及自己场上表侧表示存在的除效果怪兽以外的怪兽数量的对方场上的效果怪兽破坏。
function c23935886.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2张连接怪兽作为素材
	aux.AddLinkProcedure(c,nil,2,nil,c23935886.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡不会被和效果怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c23935886.indval)
	c:RegisterEffect(e1)
	-- ②：自己场上没有其他的效果怪兽存在的场合才能发动。选最多有自己墓地以及自己场上表侧表示存在的除效果怪兽以外的怪兽数量的对方场上的效果怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23935886,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,23935886)
	e2:SetCondition(c23935886.descon)
	e2:SetTarget(c23935886.destg)
	e2:SetOperation(c23935886.desop)
	c:RegisterEffect(e2)
end
-- 连接怪兽的过滤函数，检查是否存在连接怪兽
function c23935886.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
-- 效果怪兽的过滤函数，检查是否为表侧表示的效果怪兽
function c23935886.indval(e,c)
	return c:IsType(TYPE_EFFECT)
end
-- 效果怪兽的过滤函数，检查是否为表侧表示的效果怪兽
function c23935886.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 破坏效果的发动条件函数，检查自己场上是否存在其他效果怪兽
function c23935886.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在其他效果怪兽
	return not Duel.IsExistingMatchingCard(c23935886.filter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 破坏对象的过滤函数，检查是否为墓地或场上表侧表示的非效果怪兽
function c23935886.ctfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT))
		or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and not c:IsType(TYPE_EFFECT))
end
-- 破坏效果的目标设定函数，检查是否满足发动条件
function c23935886.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地或场上是否存在非效果怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23935886.ctfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		-- 检查对方场上是否存在效果怪兽
		and Duel.IsExistingMatchingCard(c23935886.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有效果怪兽的卡片组
	local g=Duel.GetMatchingGroup(c23935886.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定破坏效果的分类和目标数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理函数，根据满足条件的非效果怪兽数量选择并破坏对方效果怪兽
function c23935886.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己墓地和场上表侧表示的非效果怪兽数量
	local ct=Duel.GetMatchingGroupCount(c23935886.ctfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 向玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的效果怪兽作为破坏目标
	local g=Duel.SelectMatchingCard(tp,c23935886.filter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		-- 为选中的破坏目标显示选中动画
		Duel.HintSelection(g)
		-- 将选中的对方效果怪兽以效果原因破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
