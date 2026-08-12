--シャーク・フォートレス
-- 效果：
-- 5星怪兽×2
-- ①：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
function c50449881.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为5的怪兽2只进行叠放
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50449881,0))  --"多次攻击"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c50449881.condition)
	e1:SetCost(c50449881.cost)
	e1:SetTarget(c50449881.target)
	e1:SetOperation(c50449881.operation)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c50449881.atlimit)
	c:RegisterEffect(e2)
end
-- 效果条件：检查回合玩家能否进入战斗阶段
function c50449881.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 效果代价：消耗1个超量素材
function c50449881.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：选择表侧表示且未获得额外攻击次数的怪兽
function c50449881.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 选择目标：选择自己场上1只表侧表示的怪兽作为对象
function c50449881.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50449881.filter(chkc) end
	-- 判断是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c50449881.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c50449881.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：为选中的怪兽增加1次攻击次数
function c50449881.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 为对象怪兽添加额外攻击次数效果，使其在本回合可进行2次攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 攻击限制函数：除了自身外的其他怪兽不能被对方选择为攻击对象
function c50449881.atlimit(e,c)
	return c~=e:GetHandler()
end
