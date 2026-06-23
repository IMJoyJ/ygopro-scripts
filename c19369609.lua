--LL－プロム・スラッシュ
-- 效果：
-- 1星怪兽×2只以上
-- ①：这张卡的攻击力上升这张卡的超量素材数量×500。
-- ②：1回合1次，把这张卡1个超量素材取除，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者卡组。
-- ③：这张卡以外的自己怪兽进行战斗的伤害步骤开始时，把这张卡的超量素材任意数量取除才能发动。那只自己怪兽的攻击力直到回合结束时上升取除数量×300。
function c19369609.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续，使用1星怪兽2只以上作为素材
	aux.AddXyzProcedure(c,nil,1,2,nil,nil,99)
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c19369609.atkval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19369609,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c19369609.descost)
	e2:SetTarget(c19369609.destg)
	e2:SetOperation(c19369609.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡以外的自己怪兽进行战斗的伤害步骤开始时，把这张卡的超量素材任意数量取除才能发动。那只自己怪兽的攻击力直到回合结束时上升取除数量×300。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19369609,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c19369609.condition)
	e3:SetCost(c19369609.cost)
	e3:SetOperation(c19369609.operation)
	c:RegisterEffect(e3)
end
-- 效果计算攻击力时，攻击力等于超量素材数量乘以500
function c19369609.atkval(e,c)
	return c:GetOverlayCount()*500
end
-- 效果发动时，检查是否能将1个超量素材取除作为代价，若可以则执行取除操作
function c19369609.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选满足条件的魔法·陷阱卡，即在场上的魔法·陷阱卡且能送回卡组
function c19369609.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 选择目标卡，即对方场上的魔法·陷阱卡
function c19369609.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c19369609.filter(chkc) end
	-- 判断是否有符合条件的目标卡存在
	if chk==0 then return Duel.IsExistingTarget(c19369609.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c19369609.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，指定将目标卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理阶段，将目标卡送回卡组
function c19369609.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 判断是否满足效果发动条件，即自己场上存在正面表示的怪兽且不是此卡
function c19369609.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的怪兽
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsFaceup() and tc~=e:GetHandler() and tc:IsRelateToBattle()
end
-- 效果发动时，检查是否能将任意数量的超量素材取除作为代价，若可以则执行取除操作
function c19369609.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local rt=c:GetOverlayCount()
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
-- 效果处理阶段，为战斗中的己方怪兽增加攻击力
function c19369609.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗中的怪兽
	local tc=Duel.GetBattleMonster(tp)
	if not tc or tc==c then return end
	if tc:IsFaceup() and tc:IsRelateToBattle() and tc:IsControler(tp) then
		local ct=e:GetLabel()
		-- 为战斗中的己方怪兽增加攻击力，增加量等于取除的超量素材数量乘以300
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*300)
		tc:RegisterEffect(e1)
	end
end
