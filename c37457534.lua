--古代の機械戦車
-- 效果：
-- 名字带有「古代的机械」的怪兽才能装备。装备怪兽的攻击力上升600。这张卡被破坏送去墓地时，给与对方基本分600分伤害。
function c37457534.initial_effect(c)
	-- 名字带有「古代的机械」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c37457534.target)
	e1:SetOperation(c37457534.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(600)
	c:RegisterEffect(e2)
	-- 名字带有「古代的机械」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c37457534.eqlimit)
	c:RegisterEffect(e3)
	-- 这张卡被破坏送去墓地时，给与对方基本分600分伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37457534,0))  --"伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c37457534.damcon)
	e4:SetTarget(c37457534.damtg)
	e4:SetOperation(c37457534.damop)
	c:RegisterEffect(e4)
end
-- 装备限制判定：只有名字带有「古代的机械」的怪兽才能装备这张卡。
function c37457534.eqlimit(e,c)
	return c:IsSetCard(0x7)
end
-- 装备对象过滤条件：筛选场上表侧表示且名字带有「古代的机械」的怪兽。
function c37457534.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7)
end
-- 发动时的取对象处理：选择场上表侧表示且名字带有「古代的机械」的1只怪兽作为装备对象，并设置操作信息。
function c37457534.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37457534.filter(chkc) end
	-- 发动条件判定：场上（双方主要怪兽区）是否存在至少1只表侧表示且名字带有「古代的机械」的怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c37457534.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要装备的卡”的提示信息，引导玩家选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方主要怪兽区选择1只表侧表示且名字带有「古代的机械」的怪兽作为装备对象，并将其记录为本次连锁的对象。
	Duel.SelectTarget(tp,c37457534.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为装备分类，处理对象为这张装备魔法卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡和选择的对象仍与效果相关且对象表侧表示，则把这张卡装备给对象怪兽。
function c37457534.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备到对象怪兽身上。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 伤害效果发动条件：这张卡被破坏并因此送去墓地时满足条件。
function c37457534.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 伤害效果发动时设定对象玩家和参数：以对方玩家为对象，伤害数值为600，并设置操作信息。
function c37457534.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果对象玩家设为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将效果参数设为600（要造成的伤害数值）。
	Duel.SetTargetParam(600)
	-- 设置操作信息为造成600点伤害给对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 效果处理时，从连锁信息中取得对象玩家和伤害数值，给对方造成600点效果伤害。
function c37457534.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给对象玩家造成600点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
