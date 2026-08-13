--No.61 ヴォルカザウルス
-- 效果：
-- 5星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动（这个效果发动的回合，这张卡不能直接攻击）。那只对方怪兽破坏，给与对方那个原本攻击力数值的伤害。
function c29669359.initial_effect(c)
	-- 为No.61添加XYZ召唤手续：需要2只5星怪兽叠放来进行XYZ召唤。
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
-- 将这张卡登记为No.61，以适用No.卡的相关规则（如No.之间的战斗不会被破坏等）。
aux.xyz_number[29669359]=61
-- 发动条件检查：这张卡存在至少1个可移除的超量素材以作为代价，且本回合尚未进行过直接攻击，才能发动效果。
function c29669359.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		and not e:GetHandler():IsDirectAttacked() end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- （这个效果发动的回合，这张卡不能直接攻击）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 定义对象筛选条件：选择对方场上表侧表示的怪兽。
function c29669359.filter(c)
	return c:IsFaceup()
end
-- 目标选择阶段：以对方场上1只表侧表示怪兽为对象；发动前确认存在可指定的对象，选择对象后记录其原本攻击力，并设置破坏与伤害的操作信息。
function c29669359.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c29669359.filter(chkc) end
	-- 发动条件检查：确认对方场上是否存在1只可作为效果对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c29669359.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只表侧表示怪兽作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c29669359.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local atk=g:GetFirst():GetTextAttack()
	if atk<0 then atk=0 end
	-- 设置操作信息：将选择的怪兽登记为将被破坏的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：给与对方伤害，伤害值等于对象怪兽的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 效果处理：若对象仍与效果关联且仍由对方控制，则破坏该怪兽；若破坏成功，给与对方其原本攻击力数值的伤害。
function c29669359.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理阶段要处理的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 以效果破坏该对象怪兽，若破坏成功（返回非0）则继续执行伤害处理。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给与对方玩家该怪兽原本攻击力数值的效果伤害。
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
