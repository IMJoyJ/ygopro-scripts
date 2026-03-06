--No.61 ヴォルカザウルス
-- 效果：
-- 5星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动（这个效果发动的回合，这张卡不能直接攻击）。那只对方怪兽破坏，给与对方那个原本攻击力数值的伤害。
function c29669359.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用等级为5的怪兽叠放，最少需要2只
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动（这个效果发动的回合，这张卡不能直接攻击）。那只对方怪兽破坏，给与对方那个原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetDescription(aux.Stringid(29669359,0))  --"破坏和伤害"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c29669359.cost)
	e1:SetTarget(c29669359.target)
	e1:SetOperation(c29669359.operation)
	c:RegisterEffect(e1)
end
-- 设置该卡的XYZ编号为61
aux.xyz_number[29669359]=61
-- 检查是否可以去除1个超量素材并确认该卡未直接攻击过
function c29669359.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		and not e:GetHandler():IsDirectAttacked() end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 使该卡在本回合不能直接攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤函数，判断目标怪兽是否为表侧表示
function c29669359.filter(c)
	return c:IsFaceup()
end
-- 设置效果的目标选择逻辑，选择对方场上的1只表侧表示怪兽
function c29669359.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c29669359.filter(chkc) end
	-- 检查对方场上是否存在1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c29669359.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为目标
	local g=Duel.SelectTarget(tp,c29669359.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local atk=g:GetFirst():GetTextAttack()
	if atk<0 then atk=0 end
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 效果的处理函数，对目标怪兽进行破坏并造成伤害
function c29669359.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 判断破坏是否成功
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 对对方造成等同于目标怪兽原本攻击力的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
