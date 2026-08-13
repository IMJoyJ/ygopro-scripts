--フュージョン・ウェポン
-- 效果：
-- 6星以下的融合怪兽才能装备。装备怪兽的攻击力·守备力上升1500。
function c27967615.initial_effect(c)
	-- 6星以下的融合怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c27967615.target)
	e1:SetOperation(c27967615.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升1500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
	-- 装备怪兽的守备力上升1500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(1500)
	c:RegisterEffect(e3)
	-- 6星以下的融合怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c27967615.eqlimit)
	c:RegisterEffect(e4)
end
-- 检查装备对象是否为6星以下的融合怪兽，是则允许装备。
function c27967615.eqlimit(e,c)
	return c:IsType(TYPE_FUSION) and c:IsLevelBelow(6)
end
-- 过滤条件：表侧表示且为6星以下的融合怪兽。
function c27967615.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsLevelBelow(6)
end
-- 发动时选择场上表侧表示的6星以下融合怪兽作为装备对象，并设置操作信息。
function c27967615.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c27967615.filter(chkc) end
	-- 检查是否存在至少1只符合条件的装备对象，若存在则允许发动。
	if chk==0 then return Duel.IsExistingTarget(c27967615.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只场上的表侧表示6星以下融合怪兽作为装备对象。
	Duel.SelectTarget(tp,c27967615.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁处理为装备这张魔法卡，操作对象为这张卡本身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 处理时取回装备对象，若这张卡与对象仍关联且对象表侧表示，则将这张卡装备给对象。
function c27967615.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡成功装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
