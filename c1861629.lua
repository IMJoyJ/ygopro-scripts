--デコード・トーカー
-- 效果：
-- 效果怪兽2只以上
-- ①：这张卡的攻击力上升这张卡所连接区的怪兽数量×500。
-- ②：自己场上的卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡所连接区1只自己怪兽解放才能发动。那个发动无效并破坏。
function c1861629.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2个连接素材，且连接素材必须是效果怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡所连接区的怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c1861629.atkval)
	c:RegisterEffect(e1)
	-- ②：自己场上的卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡所连接区1只自己怪兽解放才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1861629,0))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c1861629.discon)
	e2:SetCost(c1861629.discost)
	e2:SetTarget(c1861629.distg)
	e2:SetOperation(c1861629.disop)
	c:RegisterEffect(e2)
end
-- 计算攻击力时，返回连接区怪兽数量乘以500的值
function c1861629.atkval(e,c)
	return c:GetLinkedGroupCount()*500
end
-- 判断目标卡是否在场上且属于指定玩家
function c1861629.tfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp)
end
-- 判断连锁是否可以被无效，条件为：不是自己发动、不是战斗破坏状态、效果具有取对象属性、对象卡组中存在场上属于自己的卡、连锁可被无效
function c1861629.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡组信息
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象卡组中是否存在满足条件的卡且连锁可被无效
	return tg and tg:IsExists(c1861629.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 判断卡是否在连接组中且未处于战斗破坏状态
function c1861629.cfilter(c,g)
	return g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 处理发动时的解放费用，选择1张连接区的怪兽进行解放
function c1861629.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c1861629.cfilter,1,nil,lg) end
	-- 从连接区选择1张满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c1861629.cfilter,1,1,nil,lg)
	-- 将选中的怪兽以代价形式解放
	Duel.Release(g,REASON_COST)
end
-- 设置连锁发动时的操作信息，包括使发动无效和破坏对象卡
function c1861629.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息为破坏对象卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果操作，使连锁发动无效并破坏对象卡
function c1861629.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁发动是否成功无效且对象卡存在并关联到该效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对象卡以效果原因破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
