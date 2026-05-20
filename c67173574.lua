--CNo.102 光堕天使ノーブル・デーモン
-- 效果：
-- 光属性5星怪兽×4
-- ①：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡2个超量素材取除。
-- ②：这张卡的超量素材全部被取除的场合发动。给与对方1500伤害。
-- ③：这张卡有「No.102 光天使 辉环」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力变成0，效果无效化。
function c67173574.initial_effect(c)
	-- 开启全局标记以支持超量素材被取除时的事件（EVENT_DETACH_MATERIAL）检测
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- 添加超量召唤手续：光属性5星怪兽×4
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),5,4)
	c:EnableReviveLimit()
	-- ①：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡2个超量素材取除。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c67173574.reptg)
	c:RegisterEffect(e1)
	-- ②：这张卡的超量素材全部被取除的场合发动。给与对方1500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67173574,1))  --"伤害"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCode(EVENT_DETACH_MATERIAL)
	e2:SetCondition(c67173574.damcon)
	e2:SetTarget(c67173574.damtg)
	e2:SetOperation(c67173574.damop)
	c:RegisterEffect(e2)
	-- ③：这张卡有「No.102 光天使 辉环」在作为超量素材的场合，得到以下效果。●1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力变成0，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c67173574.condition)
	e3:SetCost(c67173574.cost)
	e3:SetTarget(c67173574.target)
	e3:SetOperation(c67173574.operation)
	c:RegisterEffect(e3)
end
-- 设置该怪兽的“No.”编号为102
aux.xyz_number[67173574]=102
-- 代替破坏效果的Target函数：检查自身是否因战斗或效果破坏，且自身拥有至少2个超量素材
function c67173574.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_EFFECT)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,2,2,REASON_EFFECT)
		return true
	else return false end
end
-- 伤害效果的Condition函数：检查这张卡的超量素材数量是否为0
function c67173574.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()==0
end
-- 伤害效果的Target函数：设置对方玩家为目标并声明造成1500点伤害的操作信息
function c67173574.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsFaceup() end
	-- 将当前连锁的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为1500（伤害数值）
	Duel.SetTargetParam(1500)
	-- 设置当前连锁的操作信息为：给与对方玩家1500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,1500)
end
-- 伤害效果的Operation函数：获取目标玩家和伤害数值，并执行伤害处理
function c67173574.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 获得效果的Condition函数：检查超量素材中是否存在卡号为49678559（No.102 光天使 辉环）的卡
function c67173574.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,49678559)
end
-- 获得效果的Cost函数：检查并取除这张卡的1个超量素材
function c67173574.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：对方场上表侧表示且攻击力大于0的怪兽
function c67173574.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 获得效果的Target函数：选择对方场上1只表侧表示怪兽作为对象
function c67173574.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c67173574.filter(chkc) end
	-- 检查对方场上是否存在至少1只满足过滤条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c67173574.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家提示“选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动效果的玩家选择1只满足过滤条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c67173574.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 获得效果的Operation函数：使作为对象的怪兽攻击力变成0，且效果无效化
function c67173574.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中设定的第一个（也是唯一一个）对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 and tc:IsControler(1-tp) then
		-- 那只对方怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
