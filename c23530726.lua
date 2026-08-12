--閃術兵器－Ｓ．Ｐ．Ｅ．Ｃ．Ｔ．Ｒ．Ａ．
-- 效果：
-- 包含连接怪兽的怪兽2只以上
-- 这个卡名在规则上也当作「闪刀姬」卡使用。这张卡不用连接召唤不能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：连锁2以后对方把魔法·陷阱·怪兽的效果发动时，从自己的手卡·墓地把2张魔法卡除外才能发动。那个效果无效。那之后，可以把对方场上1张卡破坏。
-- ②：自己墓地没有魔法卡存在的场合，这张卡的攻击力下降3000。
local s,id,o=GetID()
-- 初始化效果函数，设置连接召唤程序、启用复活限制、注册攻击力下降效果、特殊召唤条件和连锁发动效果
function s.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2只包含连接怪兽的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,nil,s.lcheck)
	c:EnableReviveLimit()
	-- 自己墓地没有魔法卡存在的场合，这张卡的攻击力下降3000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.atcon)
	e1:SetValue(-3000)
	c:RegisterEffect(e1)
	-- 这张卡不用连接召唤不能从额外卡组特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置特殊召唤条件为必须通过连接召唤
	e2:SetValue(aux.linklimit)
	c:RegisterEffect(e2)
	-- 连锁2以后对方把魔法·陷阱·怪兽的效果发动时，从自己的手卡·墓地把2张魔法卡除外才能发动。那个效果无效。那之后，可以把对方场上1张卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 连接怪兽检查函数，判断怪兽组中是否存在连接怪兽
function s.lcheck(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
-- 攻击力下降效果的发动条件，当自己墓地没有魔法卡时触发
function s.atcon(e)
	-- 当自己墓地没有魔法卡时触发
	return not Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,TYPE_SPELL)
end
-- 连锁发动效果的发动条件，对方发动效果且连锁编号大于等于2时触发
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动效果且连锁编号大于等于2时触发
	return ep==1-tp and Duel.GetCurrentChain()>=2
end
-- 除外卡的过滤函数，筛选手卡或墓地的魔法卡
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 发动效果的费用，选择2张手卡或墓地的魔法卡除外
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的魔法卡可作为除外费用
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张魔法卡
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置连锁发动效果的目标，使对方效果无效
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁发动效果的操作信息，记录将要使效果无效的目标
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 连锁发动效果的处理函数，使对方效果无效并可选择破坏对方场上一张卡
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡作为可破坏对象
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 使对方效果无效并询问是否破坏对方场上一张卡
	if Duel.NegateEffect(ev) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否破坏对方场上的卡？"
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显示被选为对象的卡
		Duel.HintSelection(sg)
		-- 中断当前效果处理，使后续效果视为错时点
		Duel.BreakEffect()
		-- 破坏选中的对方场上的一张卡
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
