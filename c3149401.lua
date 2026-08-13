--誇りと魂の究極竜
-- 效果：
-- 原本攻击力和原本守备力是2500的怪兽×3
-- ①：只要融合召唤的这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ②：只要自己墓地有卡25张以上存在，融合召唤的这张卡的攻击力·守备力上升4500。
-- ③：1回合1次，对方墓地有卡25张以上存在的场合才能发动。对方场上的卡全部破坏。
local s,id,o=GetID()
-- 初始化该卡的所有效果：添加融合素材手续、苏生限制，并注册①的对象抗性与破坏抗性、②的攻击力/守备力上升、③的对方全场破坏效果。
function s.initial_effect(c)
	-- 为这张卡添加融合召唤手续：使用3只原本攻击力和原本守备力都是2500的怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()
	-- ①：只要融合召唤的这张卡在怪兽区域存在，对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcon)
	-- 设置抗性效果的值函数：仅当效果来自对方玩家时返回 true，即只免疫对方的效果对象选择。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置破坏抗性效果的值函数：仅当效果来自对方玩家时返回 true，即只免疫对方的效果破坏。
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
-- 融合素材过滤函数：判断怪兽的原本攻击力和原本守备力是否均为2500，用于选择符合条件的融合素材。
function s.ffilter(c)
	return c:GetBaseAttack()==2500 and c:GetBaseDefense()==2500
end
-- ①效果的条件：这张卡必须是以融合召唤的方式特殊召唤（且在怪兽区域）。
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- ②效果的条件：这张卡是融合召唤，且自己墓地有卡25张以上存在。
function s.atkcon(e)
	-- 返回二阶条件：这张卡是融合召唤，且自己墓地卡数不少于25张。
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_GRAVE,0)>=25
end
-- ③效果的发动条件：对方墓地有卡25张以上存在。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回对方墓地卡数是否不少于25张。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)>=25
end
-- ③效果的发动目标：检查对方场上有卡可破坏，并将对方场上全部卡登记为本次效果将破坏的对象（设置操作信息）。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，确认对方场上至少存在1张卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的全部卡，作为将被破坏的卡片组。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，将对方全场卡的数量和破坏类别告知系统，供其他卡响应时参考。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ③效果处理：获取对方场上当前存在的所有卡并全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新获取对方场上的全部卡，以保证破坏的是处理时在场的卡。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因将前述卡片破坏并送去墓地。
	Duel.Destroy(sg,REASON_EFFECT)
end
