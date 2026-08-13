--ブレイン・ジャッカー
-- 效果：
-- 反转：这张卡当作装备卡使用，装备到对方场上的怪兽上。获得这张卡装备的怪兽的控制权。每次对方准备阶段对方基本分回复500。
function c40267580.initial_effect(c)
	-- 反转：这张卡当作装备卡使用，装备到对方场上的怪兽上。获得这张卡装备的怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40267580,0))  --"装备获得控制权"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c40267580.eqtg)
	e1:SetOperation(c40267580.eqop)
	c:RegisterEffect(e1)
	-- 每次对方准备阶段对方基本分回复500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40267580,1))  --"LP回复"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c40267580.reccon)
	e2:SetTarget(c40267580.rectg)
	e2:SetOperation(c40267580.recop)
	c:RegisterEffect(e2)
end
-- 过滤条件：怪兽须为表侧表示且其控制权可以被变更。
function c40267580.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 反转效果发动时的取对象处理：选择对方场上1只满足filter条件的表侧表示怪兽作为对象，并登记改变控制权和装备的操作信息。
function c40267580.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c40267580.filter(chkc) end
	if chk==0 then return true end
	-- 给玩家显示“请选择要改变控制权的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让发动者从对方场上选择1只符合filter条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c40267580.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：此次效果包含改变控制权，对象为已选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 登记操作信息：此次效果包含装备，装备卡为效果发动者自身（捕脑魔）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制函数：仅允许效果所有者（捕脑魔）装备给这张卡；若其他卡尝试装备则不允许。
function c40267580.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：将捕脑魔当作装备卡装备给对象怪兽，并为该怪兽添加装备限制，再赋予捕脑魔控制权变更效果。
function c40267580.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		-- 确认捕脑魔未被战斗破坏、表侧表示且与效果关联，并成功装备到对象怪兽身上。
		and c:IsFaceup() and c:IsRelateToEffect(e) and Duel.Equip(tp,c,tc) then
		-- （作为装备卡时）限制对象怪兽只能装备捕脑魔，对应“这张卡当作装备卡使用，装备到对方场上的怪兽上”。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c40267580.eqlimit)
		c:RegisterEffect(e1)
		-- 获得这张卡装备的怪兽的控制权。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_CONTROL)
		e2:SetValue(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		c:RegisterEffect(e2)
	end
end
-- 回复效果的发动条件：当前不是效果持有者的准备阶段，即对方准备阶段。
function c40267580.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是效果持有者，从而确认处于对方准备阶段。
	return tp~=Duel.GetTurnPlayer()
end
-- 回复效果的目标处理：设定回复对象为对方玩家，回复数值为500，并登记回复操作信息。
function c40267580.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的效果对象玩家设为对方（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次连锁的效果参数值设为500，表示要回复的数值。
	Duel.SetTargetParam(500)
	-- 登记操作信息：这是一个回复效果，回复对象为对方玩家，数值为500。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,500)
end
-- 回复效果处理：从连锁信息中读取对象玩家和数值，并执行LP回复。
function c40267580.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的对象玩家和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使对象玩家回复对应的LP数值，回复原因为效果。
	Duel.Recover(p,d,REASON_EFFECT)
end
