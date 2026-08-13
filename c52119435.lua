--転晶のコーディネラル
-- 效果：
-- 效果怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：连接状态的这张卡以及这张卡所连接区的怪兽不会被对方的效果破坏。
-- ②：这张卡所连接区有怪兽2只存在的场合才能发动。那2只怪兽的控制权交换。
function c52119435.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，指定连接素材为2只效果怪兽（即Link-2连接怪兽）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	-- ①：连接状态的这张卡以及这张卡所连接区的怪兽不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c52119435.indtg)
	-- 设置①效果的判定值为aux.indoval，即当效果来源为对方时返回真，从而使这些卡不会因对方发动的效果被破坏。
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
-- 定义①效果的适用对象：这张卡处于连接状态时，对象为这张卡自身，或者是这张卡所连接区的怪兽。
function c52119435.indtg(e,tc)
	local c=e:GetHandler()
	return c:IsLinkState() and tc==c or c:GetLinkedGroup():IsContains(tc)
end
-- 定义②效果处理时可交换控制权的怪兽需满足的条件：被选中的怪兽必须归属于指定玩家、能够改变控制权，并且该玩家有可用怪兽区域接受交换后的怪兽。
function c52119435.ctfilter(c,tp)
	-- 判断一只怪兽是否满足控制权交换条件：控制者是否为指定玩家、是否可改变控制权、以及对应玩家是否存在可用的额外/主要怪兽区空格。
	return c:IsControler(tp) and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 定义②效果的发动条件：取这张卡所连接区的怪兽，若恰好有2只，且其中至少有1只属于我方且可交换，至少有1只属于对方且可交换，则设置为对象并登记操作信息。
function c52119435.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetLinkedGroup()
	if chk==0 then return #g==2 and g:IsExists(c52119435.ctfilter,1,nil,tp) and g:IsExists(c52119435.ctfilter,1,nil,1-tp) end
	-- 将当前连锁的对象设置为这张卡所连接区的2只怪兽，使其与效果建立关联。
	Duel.SetTargetCard(g)
	-- 登记操作信息：本次连锁将执行改变控制权效果，涉及对象为这2只怪兽，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,2,0,0)
end
-- 定义②效果处理时的具体操作：从连锁对象中筛选出仍与此效果关联的卡，若两张都存在，则交换它们的控制权。
function c52119435.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡组，并过滤出仍然与效果e有关联的卡片（效果处理时已离场或失效的卡会被剔除）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a and b then
		-- 交换a和b这两只怪兽的控制权，完成②效果的处理。
		Duel.SwapControl(a,b)
	end
end
