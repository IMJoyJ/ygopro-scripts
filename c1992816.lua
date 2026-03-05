--No.9 天蓋星ダイソン・スフィア
-- 效果：
-- 9星怪兽×2
-- ①：持有比这张卡高的攻击力的怪兽在对方场上存在的场合，自己主要阶段1把这张卡1个超量素材取除才能发动。这个回合，这张卡可以直接攻击。
-- ②：持有超量素材的这张卡被攻击的战斗步骤才能发动1次。那次攻击无效。
-- ③：这张卡没有超量素材的状态被选择作为攻击对象时，以自己墓地2只怪兽为对象才能发动。那些怪兽在这张卡下面重叠作为超量素材。
function c1992816.initial_effect(c)
	-- 为卡片添加等级为9、需要2只怪兽作为超量素材的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,9,2)
	c:EnableReviveLimit()
	-- ②：持有超量素材的这张卡被攻击的战斗步骤才能发动1次。那次攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1992816,0))  --"攻击无效"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_BATTLE_PHASE)
	e1:SetCondition(c1992816.atkcon)
	e1:SetCost(c1992816.atkcost)
	e1:SetOperation(c1992816.atkop)
	c:RegisterEffect(e1)
	-- ③：这张卡没有超量素材的状态被选择作为攻击对象时，以自己墓地2只怪兽为对象才能发动。那些怪兽在这张卡下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1992816,1))  --"增加素材"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c1992816.olcon)
	e2:SetTarget(c1992816.oltg)
	e2:SetOperation(c1992816.olop)
	c:RegisterEffect(e2)
	-- ①：持有比这张卡高的攻击力的怪兽在对方场上存在的场合，自己主要阶段1把这张卡1个超量素材取除才能发动。这个回合，这张卡可以直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1992816,2))  --"直接攻击"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c1992816.dacon)
	e3:SetCost(c1992816.dacost)
	e3:SetOperation(c1992816.daop)
	c:RegisterEffect(e3)
end
-- 设置该卡的XYZ等级为9
aux.xyz_number[1992816]=9
-- 判断是否为攻击对象且拥有超量素材
function c1992816.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为攻击对象且拥有超量素材
	return e:GetHandler()==Duel.GetAttackTarget() and e:GetHandler():GetOverlayCount()~=0
end
-- 检查是否已使用过此效果并注册标志
function c1992816.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(1992816)==0 end
	e:GetHandler():RegisterFlagEffect(1992816,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 无效此次攻击
function c1992816.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击
	Duel.NegateAttack()
end
-- 判断是否未持有超量素材且为XYZ怪兽
function c1992816.olcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()==0 and e:GetHandler():IsType(TYPE_XYZ)
end
-- 过滤墓地中的可作为超量素材的怪兽
function c1992816.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 选择2只墓地中的怪兽作为超量素材
function c1992816.oltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1992816.matfilter(chkc) end
	-- 检查是否存在满足条件的2只墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c1992816.matfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择2只墓地中的怪兽作为超量素材
	local g=Duel.SelectTarget(tp,c1992816.matfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置操作信息，表示将有2张卡从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,2,0,0)
end
-- 过滤满足条件的卡
function c1992816.olfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsCanOverlay()
end
-- 将选中的卡叠放至该卡下方
function c1992816.olop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 获取连锁中选择的目标卡组并进行过滤
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c1992816.olfilter,nil,e)
		if g:GetCount()>0 then
			-- 将选中的卡叠放至该卡下方
			Duel.Overlay(c,g)
		end
	end
end
-- 过滤攻击力高于指定值的场上怪兽
function c1992816.dafilter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
-- 判断是否为主阶段1且对方场上存在攻击力更高的怪兽
function c1992816.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为主阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
		-- 检查对方场上是否存在攻击力更高的怪兽
		and Duel.IsExistingMatchingCard(c1992816.dafilter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack())
end
-- 检查是否能移除1个超量素材作为费用
function c1992816.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置该卡获得直接攻击效果
function c1992816.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e)
		-- 检查对方场上是否存在攻击力更高的怪兽
		and Duel.IsExistingMatchingCard(c1992816.dafilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) then
		-- 设置该卡获得直接攻击效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
