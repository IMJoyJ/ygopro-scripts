--誇りと魂の究極竜
-- 效果：
-- 原本攻击力和原本守备力是2500的怪兽×3
-- ①：只要融合召唤的这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ②：只要自己墓地有卡25张以上存在，融合召唤的这张卡的攻击力·守备力上升4500。
-- ③：1回合1次，对方墓地有卡25张以上存在的场合才能发动。对方场上的卡全部破坏。
local s,id,o=GetID()
-- 初始化效果函数，注册融合召唤手续、苏生限制以及所有效果
function s.initial_effect(c)
	-- 添加融合召唤手续，使用3个满足s.ffilter条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()
	-- ①：只要融合召唤的这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcon)
	-- 设置效果值为aux.tgoval，用于过滤对方效果不能将此卡作为对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果值为aux.indoval，用于过滤对方效果不能破坏此卡
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：只要自己墓地有卡25张以上存在，融合召唤的这张卡的攻击力·守备力上升4500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(4500)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ③：1回合1次，对方墓地有卡25张以上存在的场合才能发动。对方场上的卡全部破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCountLimit(1)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
-- 过滤函数，返回原本攻击力和原本守备力都是2500的怪兽
function s.ffilter(c)
	return c:GetBaseAttack()==2500 and c:GetBaseDefense()==2500
end
-- 条件函数，判断此卡是否为融合召唤
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 条件函数，判断是否满足融合召唤且自己墓地有25张以上卡
function s.atkcon(e)
	-- 判断是否为融合召唤且自己墓地有25张以上卡
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_GRAVE,0)>=25
end
-- 条件函数，判断对方墓地是否有25张以上卡
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方墓地是否有25张以上卡
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)>=25
end
-- 设置破坏效果的目标函数，检查对方场上是否存在卡并设置操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡作为目标组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定将要破坏的卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 破坏效果的处理函数，对目标卡组进行破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡作为目标组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 将目标卡组全部破坏，原因设为效果
	Duel.Destroy(sg,REASON_EFFECT)
end
