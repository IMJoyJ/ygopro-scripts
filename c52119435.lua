--転晶のコーディネラル
-- 效果：
-- 效果怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：连接状态的这张卡以及这张卡所连接区的怪兽不会被对方的效果破坏。
-- ②：这张卡所连接区有怪兽2只存在的场合才能发动。那2只怪兽的控制权交换。
function c52119435.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2只满足效果怪兽类型的卡片作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	-- ①：连接状态的这张卡以及这张卡所连接区的怪兽不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c52119435.indtg)
	-- 设置效果值为indoval函数，用于过滤不会被对方效果破坏的条件
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区有怪兽2只存在的场合才能发动。那2只怪兽的控制权交换。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52119435,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,52119435)
	e2:SetTarget(c52119435.cttg)
	e2:SetOperation(c52119435.ctop)
	c:RegisterEffect(e2)
end
-- 判断目标卡片是否为连接状态的这张卡或其连接区中的怪兽
function c52119435.indtg(e,tc)
	local c=e:GetHandler()
	return c:IsLinkState() and tc==c or c:GetLinkedGroup():IsContains(tc)
end
-- 过滤满足控制权变更条件的怪兽，包括自身控制、可改变控制权和场上存在可用区域
function c52119435.ctfilter(c,tp)
	-- 检查目标怪兽是否为当前玩家控制、可改变控制权且当前玩家场上有可用区域
	return c:IsControler(tp) and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 设置发动条件，确保连接区有2只怪兽且双方各有一只满足条件的怪兽
function c52119435.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetLinkedGroup()
	if chk==0 then return #g==2 and g:IsExists(c52119435.ctfilter,1,nil,tp) and g:IsExists(c52119435.ctfilter,1,nil,1-tp) end
	-- 将当前处理的连锁对象设置为连接区的怪兽组
	Duel.SetTargetCard(g)
	-- 设置操作信息，表示本次效果会交换控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,2,0,0)
end
-- 执行控制权交换操作，交换两个目标怪兽的控制权
function c52119435.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定的目标卡片，并筛选出与该效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a and b then
		-- 交换两个目标怪兽的控制权
		Duel.SwapControl(a,b)
	end
end
