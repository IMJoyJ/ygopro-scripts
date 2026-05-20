--ペンギン・ソード
-- 效果：
-- 「企鹅」怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力上升800。
-- ②：装备怪兽给与对方战斗伤害时才能发动。选对方场上1张卡回到持有者手卡。
-- ③：对方场上的表侧表示的卡因「企鹅」卡的效果从场上离开，回到手卡的场合或者被除外的场合发动。直到下个回合的结束时，那些卡以及原本卡名和那些卡相同的卡的效果无效化。
function c69792699.initial_effect(c)
	-- 「企鹅」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c69792699.target)
	e1:SetOperation(c69792699.operation)
	c:RegisterEffect(e1)
	-- 「企鹅」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c69792699.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力上升800。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(800)
	c:RegisterEffect(e3)
	-- ②：装备怪兽给与对方战斗伤害时才能发动。选对方场上1张卡回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(69792699,0))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c69792699.rthcon)
	e4:SetTarget(c69792699.rthtg)
	e4:SetOperation(c69792699.rthop)
	c:RegisterEffect(e4)
	-- ③：对方场上的表侧表示的卡因「企鹅」卡的效果从场上离开，回到手卡的场合或者被除外的场合发动。直到下个回合的结束时，那些卡以及原本卡名和那些卡相同的卡的效果无效化。这个卡名的③的效果1回合只能使用1次。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(69792699,1))
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,69792699)
	e5:SetCondition(c69792699.negcon)
	e5:SetOperation(c69792699.negop)
	c:RegisterEffect(e5)
end
-- 定义装备限制：只能装备给「企鹅」怪兽
function c69792699.eqlimit(e,c)
	return c:IsSetCard(0x5a)
end
-- 过滤条件：场上表侧表示的「企鹅」怪兽
function c69792699.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x5a)
end
-- 装备魔法卡发动时的效果对象选择与操作信息设置
function c69792699.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c69792699.filter(chkc) end
	-- 检查场上是否存在可以装备的表侧表示「企鹅」怪兽
	if chk==0 then return Duel.IsExistingTarget(c69792699.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的「企鹅」怪兽作为装备对象
	Duel.SelectTarget(tp,c69792699.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的装备处理
function c69792699.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 检查是否是装备怪兽给与对方玩家战斗伤害
function c69792699.rthcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 过滤条件：对方场上可以回到手牌且未被战斗破坏的卡
function c69792699.rthfilter(c)
	return c:IsAbleToHand() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 弹手牌效果的发动准备与操作信息设置
function c69792699.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以回到手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c69792699.rthfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置操作信息为将对方场上的1张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
-- 弹手牌效果的实际处理：选择并让对方场上的1张卡回到持有者手牌
function c69792699.rthop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择对方场上1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c69792699.rthfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 选中卡片的视觉提示效果
		Duel.HintSelection(g)
		-- 将选中的卡因效果送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤条件：原本由对方控制的场上表侧表示卡片，因效果离开场上并进入手牌或被除外
function c69792699.cfilter(c,tp)
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsReason(REASON_EFFECT) and c:IsLocation(LOCATION_HAND+LOCATION_REMOVED)
end
-- 检查是否因「企鹅」卡的效果使对方场上的表侧表示卡片离开场上并回到手牌或被除外
function c69792699.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x5a) and eg:IsExists(c69792699.cfilter,1,nil,tp)
end
-- 效果无效化处理：对所有满足条件的卡及其同名卡注册无效化效果
function c69792699.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(c69792699.cfilter,nil,tp)
	-- 遍历所有因该效果离场的卡片
	for tc in aux.Next(g) do
		-- 直到下个回合的结束时，那些卡以及原本卡名和那些卡相同的卡的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
		e1:SetTarget(c69792699.distg)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 注册场上同名卡效果无效化的全局效果
		Duel.RegisterEffect(e1,tp)
		-- 直到下个回合的结束时，那些卡以及原本卡名和那些卡相同的卡的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(c69792699.discon)
		e2:SetOperation(c69792699.disop)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		-- 注册用于在连锁处理时使同名卡发动效果无效的全局效果
		Duel.RegisterEffect(e2,tp)
		-- 直到下个回合的结束时，那些卡以及原本卡名和那些卡相同的卡的效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e3:SetTarget(c69792699.distg)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册使同名陷阱怪兽效果无效的全局效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 目标过滤：匹配与被离场卡片原本卡名相同的卡
function c69792699.distg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 检查发动的效果是否来自与被离场卡片原本卡名相同的卡
function c69792699.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 无效该连锁的效果处理
function c69792699.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的效果无效
	Duel.NegateEffect(ev)
end
