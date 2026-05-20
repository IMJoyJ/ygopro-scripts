--邪神イレイザー
-- 效果：
-- 这张卡不能特殊召唤。把自己场上3只怪兽解放的场合才能通常召唤。
-- ①：这张卡的攻击力·守备力变成对方场上的卡数量×1000。
-- ②：自己主要阶段才能发动。这张卡破坏。
-- ③：这张卡被破坏送去墓地的场合发动。场上的卡全部破坏。
function c57793869.initial_effect(c)
	-- 把自己场上3只怪兽解放的场合才能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c57793869.ttcon)
	e1:SetOperation(c57793869.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e2)
	-- 这张卡不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
	-- ①：这张卡的攻击力·守备力变成对方场上的卡数量×1000。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c57793869.adval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e5)
	-- ③：这张卡被破坏送去墓地的场合发动。场上的卡全部破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(57793869,0))  --"场上的卡全部破坏"
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCondition(c57793869.erascon)
	e6:SetTarget(c57793869.erastg)
	e6:SetOperation(c57793869.erasop)
	c:RegisterEffect(e6)
	-- ②：自己主要阶段才能发动。这张卡破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(57793869,1))  --"这张卡破坏"
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTarget(c57793869.destg)
	e7:SetOperation(c57793869.desop)
	c:RegisterEffect(e7)
end
-- 通常召唤（上级召唤）的条件过滤函数
function c57793869.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查场上是否存在至少3只怪兽作为解放
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 通常召唤（上级召唤）的具体解放操作
function c57793869.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择3只怪兽作为解放的祭品
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 解放选中的怪兽用于上级召唤
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 计算并返回攻击力·守备力数值的函数
function c57793869.adval(e,c)
	-- 返回对方场上的卡数量乘以1000的数值
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_ONFIELD)*1000
end
-- 检查此卡是否因被破坏而送去墓地
function c57793869.erascon(e)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 全场破坏效果的目标过滤与操作信息设置
function c57793869.erastg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上的所有卡片
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息为破坏场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 全场破坏效果的具体执行操作
function c57793869.erasop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上的所有卡片
	local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 因效果破坏所有获取到的卡片
	Duel.Destroy(dg,REASON_EFFECT)
end
-- 自身破坏效果的目标过滤与操作信息设置
function c57793869.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 自身破坏效果的具体执行操作
function c57793869.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
