--No.33 先史遺産－超兵器マシュ＝マック
-- 效果：
-- 5星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以持有和原本攻击力不同攻击力的对方场上1只怪兽为对象才能发动。给与对方那只怪兽的攻击力和那个原本攻击力的相差数值的伤害，这张卡的攻击力上升这个效果给与的伤害的数值。
function c39139935.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为5的怪兽叠放，最少需要2只，最多2只
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以持有和原本攻击力不同攻击力的对方场上1只怪兽为对象才能发动。给与对方那只怪兽的攻击力和那个原本攻击力的相差数值的伤害，这张卡的攻击力上升这个效果给与的伤害的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(39139935,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c39139935.cost)
	e1:SetTarget(c39139935.target)
	e1:SetOperation(c39139935.operation)
	c:RegisterEffect(e1)
end
-- 设置该卡为编号33的超量怪兽
aux.xyz_number[39139935]=33
-- 支付效果代价，从自己场上取除1个超量素材
function c39139935.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选条件：表侧表示且攻击力与原本攻击力不同的怪兽
function c39139935.filter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
-- 设置效果目标，选择对方场上满足条件的1只怪兽
function c39139935.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c39139935.filter(chkc) end
	-- 检查是否有满足条件的怪兽存在
	if chk==0 then return Duel.IsExistingTarget(c39139935.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c39139935.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	local atk=tc:GetAttack()
	local batk=tc:GetBaseAttack()
	-- 设置效果处理信息，确定将要给予的伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,(batk>atk) and (batk-atk) or (atk-batk))
end
-- 处理效果的发动，对目标怪兽造成伤害并提升自身攻击力
function c39139935.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		local batk=tc:GetBaseAttack()
		if batk~=atk then
			local dif=(batk>atk) and (batk-atk) or (atk-batk)
			-- 对对方玩家造成指定数值的伤害
			local dam=Duel.Damage(1-tp,dif,REASON_EFFECT)
			if dam>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
				-- 使自身攻击力上升指定数值
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(dif)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
			end
		end
	end
end
