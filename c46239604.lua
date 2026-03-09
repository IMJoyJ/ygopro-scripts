--魔知ガエル
-- 效果：
-- ①：这张卡只要在怪兽区域存在，卡名当作「死亡青蛙」使用。
-- ②：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
-- ③：这张卡从场上送去墓地时才能发动。从自己的卡组·墓地选「魔知青蛙」以外的1只「青蛙」怪兽加入手卡。
function c46239604.initial_effect(c)
	-- 使该卡在怪兽区域存在时视为「死亡青蛙」
	aux.EnableChangeCode(c,84451804)
	-- 只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46239604,0))  --"加入手牌"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c46239604.condition)
	e2:SetTarget(c46239604.target)
	e2:SetOperation(c46239604.operation)
	c:RegisterEffect(e2)
	-- 这张卡从场上送去墓地时才能发动。从自己的卡组·墓地选「魔知青蛙」以外的1只「青蛙」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c46239604.atlimit)
	c:RegisterEffect(e3)
end
-- 设置效果限制：除自身外不能成为攻击目标
function c46239604.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 效果发动条件：该卡从前场送去墓地
function c46239604.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：检索「青蛙」属性且非「魔知青蛙」且可加入手牌的怪兽
function c46239604.filter(c)
	return c:IsSetCard(0x12) and not c:IsCode(46239604) and c:IsAbleToHand()
end
-- 设置效果处理时的连锁信息：准备从卡组或墓地选1只青蛙怪兽加入手牌
function c46239604.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：确认场上存在满足条件的青蛙怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c46239604.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：指定将要处理的卡为1张来自卡组或墓地的青蛙怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果处理函数：提示选择并执行将青蛙怪兽加入手牌的操作
function c46239604.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组和墓地中选择满足条件的青蛙怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c46239604.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的青蛙怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
