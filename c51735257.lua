--No.50 ブラック・コーン号
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以持有这张卡的攻击力以下的攻击力的对方场上1只怪兽为对象才能发动。那只怪兽送去墓地，给与对方1000伤害。这个效果发动的回合，这张卡不能攻击。
function c51735257.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用等级为4的怪兽叠放2只以上
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以持有这张卡的攻击力以下的攻击力的对方场上1只怪兽为对象才能发动。那只怪兽送去墓地，给与对方1000伤害。这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51735257,0))  --"送墓并伤害"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c51735257.cost)
	e1:SetTarget(c51735257.target)
	e1:SetOperation(c51735257.operation)
	c:RegisterEffect(e1)
end
-- 设置该卡片的XYZ编号为50
aux.xyz_number[51735257]=50
-- 检查是否满足cost条件：未宣布过攻击且可以移除1个超量素材
function c51735257.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 使该怪兽在本回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤函数，判断目标怪兽是否为表侧表示且攻击力不超过指定值
function c51735257.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 设置效果的目标选择逻辑：选择对方场上攻击力不超过自身攻击力的1只怪兽
function c51735257.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c51735257.filter(chkc,e:GetHandler():GetAttack()) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c51735257.filter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择符合条件的1只对方场上的怪兽作为目标
	local g=Duel.SelectTarget(tp,c51735257.filter,tp,0,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
	-- 设置操作信息：将目标怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息：给与对方1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 执行效果处理：将目标怪兽送去墓地并给与对方1000伤害
function c51735257.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
		if tc:IsLocation(LOCATION_GRAVE) then
			-- 给与对方1000伤害
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end
