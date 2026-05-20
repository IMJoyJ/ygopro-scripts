--神秘の妖精 エルフィリア
-- 效果：
-- 1回合1次，把手卡1只风属性怪兽给对方观看才能发动。直到下次的对方的结束阶段时，双方玩家不能用持有给人观看的怪兽的等级以外的等级的怪兽为素材作超量召唤。
function c85239662.initial_effect(c)
	-- 1回合1次，把手卡1只风属性怪兽给对方观看才能发动。直到下次的对方的结束阶段时，双方玩家不能用持有给人观看的怪兽的等级以外的等级的怪兽为素材作超量召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85239662,0))  --"召唤限制"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c85239662.cost)
	e2:SetOperation(c85239662.operation)
	c:RegisterEffect(e2)
end
-- 过滤手卡中未公开的风属性怪兽
function c85239662.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and not c:IsPublic()
end
-- 效果发动的代价：选择手卡1只未公开的风属性怪兽给对方确认，并记录其等级，随后洗牌
function c85239662.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只未公开的风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85239662.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 在系统缓存中设置提示信息，提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手卡选择1只未公开的风属性怪兽
	local g=Duel.SelectMatchingCard(tp,c85239662.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽给对方确认
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 洗切发动效果玩家的手卡
	Duel.ShuffleHand(tp)
end
-- 效果处理：注册一个影响全场的时效性效果，限制双方玩家超量召唤时可使用的素材等级
function c85239662.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下次的对方的结束阶段时，双方玩家不能用持有给人观看的怪兽的等级以外的等级的怪兽为素材作超量召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c85239662.target)
	e1:SetLabel(e:GetLabel())
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	e1:SetValue(1)
	-- 将限制超量召唤素材的效果注册到全局环境中
	Duel.RegisterEffect(e1,tp)
end
-- 过滤出等级不等于展示怪兽等级且等级在1以上的怪兽，使其不能作为超量召唤的素材
function c85239662.target(e,c)
	return not c:IsLevel(e:GetLabel()) and c:IsLevelAbove(1)
end
