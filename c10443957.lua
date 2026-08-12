--サイバー・ドラゴン・インフィニティ
-- 效果：
-- 机械族·光属性6星怪兽×3
-- 「电子龙·无限」1回合1次也能在自己场上的「电子龙·新星」上面重叠来超量召唤。
-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
-- ②：1回合1次，以场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽作为这张卡的超量素材。
-- ③：1回合1次，魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c10443957.initial_effect(c)
	aux.AddXyzProcedure(c,c10443957.mfilter,6,3,c10443957.ovfilter,aux.Stringid(10443957,0),3,c10443957.xyzop)  --"是否在「电子龙·新星」上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c10443957.atkval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽作为这张卡的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c10443957.target)
	e2:SetOperation(c10443957.operation)
	c:RegisterEffect(e2)
	-- ③：1回合1次，魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c10443957.discon)
	e3:SetCost(c10443957.discost)
	e3:SetTarget(c10443957.distg)
	e3:SetOperation(c10443957.disop)
	c:RegisterEffect(e3)
end
-- 判断怪兽是否为机械族且光属性
function c10443957.mfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 判断怪兽是否为「电子龙·新星」
function c10443957.ovfilter(c)
	return c:IsFaceup() and c:IsCode(58069384)
end
-- 超量召唤时的处理函数
function c10443957.xyzop(e,tp,chk)
	-- 检查是否已使用过效果
	if chk==0 then return Duel.GetFlagEffect(tp,10443957)==0 end
	-- 注册标识效果，防止效果重复使用
	Duel.RegisterFlagEffect(tp,10443957,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 计算攻击力增加量
function c10443957.atkval(e,c)
	return c:GetOverlayCount()*200
end
-- 判断目标怪兽是否为表侧攻击表示且可作为超量素材
function c10443957.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanOverlay()
end
-- 设置效果目标
function c10443957.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c10443957.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c10443957.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示选择作为超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	-- 选择目标怪兽作为超量素材
	Duel.SelectTarget(tp,c10443957.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 效果处理函数
function c10443957.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将目标怪兽身上的超量素材送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将目标怪兽叠放至自身上
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- 无效效果发动的条件判断
function c10443957.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自身未在战斗中被破坏且连锁效果可被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 支付效果代价的函数
function c10443957.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果处理信息
function c10443957.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将要使发动无效的处理信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置将要破坏的处理信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效效果并破坏的处理函数
function c10443957.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效并判断是否可以破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
