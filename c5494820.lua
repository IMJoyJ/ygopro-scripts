--サイクロンレーザー
-- 效果：
-- 只有「超时空战斗机 V形蛇」可以装备。攻击力上升300点。装备这张卡的怪兽攻击守备表示的怪兽时，若攻击力超过那个守备力，给与对方那个数值的战斗伤害。
function c5494820.initial_effect(c)
	-- 只有「超时空战斗机 V形蛇」可以装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c5494820.target)
	e1:SetOperation(c5494820.operation)
	c:RegisterEffect(e1)
	-- 攻击力上升300点。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 装备这张卡的怪兽攻击守备表示的怪兽时，若攻击力超过那个守备力，给与对方那个数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- 只有「超时空战斗机 V形蛇」可以装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c5494820.eqfilter)
	c:RegisterEffect(e4)
end
-- 过滤装备限制，判定卡片是否为「超时空战斗机 V形蛇」
function c5494820.eqfilter(e,c)
	return c:IsCode(10992251)
end
-- 过滤场上表侧表示的「超时空战斗机 V形蛇」
function c5494820.filter(c)
	return c:IsFaceup() and c:IsCode(10992251)
end
-- 装备魔法卡发动时的效果处理，选择场上1只表侧表示的「超时空战斗机 V形蛇」作为对象
function c5494820.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c5494820.filter(chkc) end
	-- 判定场上是否存在可以装备的表侧表示的「超时空战斗机 V形蛇」
	if chk==0 then return Duel.IsExistingTarget(c5494820.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的「超时空战斗机 V形蛇」作为对象
	Duel.SelectTarget(tp,c5494820.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理，将这张卡装备给目标怪兽
function c5494820.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为装备对象的怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
