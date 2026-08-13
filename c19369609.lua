--LL－プロム・スラッシュ
-- 效果：
-- 1星怪兽×2只以上
-- ①：这张卡的攻击力上升这张卡的超量素材数量×500。
-- ②：1回合1次，把这张卡1个超量素材取除，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者卡组。
-- ③：这张卡以外的自己怪兽进行战斗的伤害步骤开始时，把这张卡的超量素材任意数量取除才能发动。那只自己怪兽的攻击力直到回合结束时上升取除数量×300。
function c19369609.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加XYZ召唤手续：可用1星怪兽2只以上（最多99只）叠放进行XYZ召唤，对应‘1星怪兽×2只以上’的召唤条件。
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
-- 计算①效果中这张卡的攻击力上升值：返回这张卡当前超量素材数量×500。
function c19369609.atkval(e,c)
	return c:GetOverlayCount()*500
end
-- ②效果的发动代价：从这张卡上取除1个超量素材作为COST；若为合法性检查，则返回是否能取除1个素材。
function c19369609.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义②效果可选择的对象：对方场上的魔法·陷阱卡，并且该卡能够返回卡组。
function c19369609.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- ②效果的取对象处理：先确认对方场上有满足条件的魔法·陷阱卡；然后让玩家选择其中1张作为对象，并设定该卡返回卡组的操作信息。
function c19369609.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c19369609.filter(chkc) end
	-- 检查发动时是否存在符合条件的对象：对方场上是否存在至少1张可返回卡组的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c19369609.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示选择提示，提示文字为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从对方场上选择1张满足条件的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c19369609.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息：将对象卡返回卡组，用于后续效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理：取得发动时选择的对象卡，若该卡仍与本效果关联，则将其返回持有者卡组并洗牌。
function c19369609.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的那张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果处理的方式将对象卡返回持有者卡组并洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ③效果的发动条件：自己场上存在正在战斗的、表侧表示且不是这张卡自己的怪兽，并且该怪兽与战斗相关。
function c19369609.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上正在进行战斗的怪兽，用于判断是否符合③效果的发劯条件。
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsFaceup() and tc~=e:GetHandler() and tc:IsRelateToBattle()
end
-- ③效果的发动代价：从这张卡上取除任意数量（至少1张）的超量素材作为COST，并把实际取除的数量记录到效果标签中，供效果处理时使用。
function c19369609.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local rt=c:GetOverlayCount()
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
-- ③效果处理：对那只正在战斗的自己怪兽（若仍满足条件）赋予攻击力上升取除素材数量×300的效果，持续到回合结束时。
function c19369609.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上正在战斗的怪兽，用于在效果处理时选择提升攻击力的对象。
	local tc=Duel.GetBattleMonster(tp)
	if not tc or tc==c then return end
	if tc:IsFaceup() and tc:IsRelateToBattle() and tc:IsControler(tp) then
		local ct=e:GetLabel()
		-- 那只自己怪兽的攻击力直到回合结束时上升取除数量×300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*300)
		tc:RegisterEffect(e1)
	end
end
