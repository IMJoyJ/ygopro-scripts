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
-- 用于筛选对方场上的正面表示且可以改变控制权的怪兽
function c40267580.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 选择对方场上的一个正面表示且可以改变控制权的怪兽作为装备对象
function c40267580.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c40267580.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上的一个正面表示且可以改变控制权的怪兽
	local g=Duel.SelectTarget(tp,c40267580.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置效果操作信息为装备卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备对象限制效果，确保只有装备卡能装备到该怪兽
function c40267580.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 将装备卡装备给目标怪兽，并设置装备限制和控制权效果
function c40267580.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查装备卡是否正面表示、是否与效果相关且成功装备
		and c:IsFaceup() and c:IsRelateToEffect(e) and Duel.Equip(tp,c,tc) then
		-- 设置装备对象限制效果，防止其他卡装备到该怪兽
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c40267580.eqlimit)
		c:RegisterEffect(e1)
		-- 设置装备卡获得控制权的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_CONTROL)
		e2:SetValue(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		c:RegisterEffect(e2)
	end
end
-- 判断是否为对方回合
function c40267580.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前玩家不是回合玩家时触发
	return tp~=Duel.GetTurnPlayer()
end
-- 设置回复LP的效果目标
function c40267580.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果操作信息的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果操作信息的目标参数为500
	Duel.SetTargetParam(500)
	-- 设置效果操作信息为回复LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,500)
end
-- 执行回复LP的操作
function c40267580.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的LP
	Duel.Recover(p,d,REASON_EFFECT)
end
