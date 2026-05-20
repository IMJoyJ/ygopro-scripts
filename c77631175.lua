--CHキング・アーサー
-- 效果：
-- 战士族4星怪兽×2
-- 这张卡被战斗破坏的场合，可以作为代替把这张卡1个超量素材取除。这个效果让超量素材被取除时，这张卡的攻击力上升500，给与对方基本分500分伤害。
function c77631175.initial_effect(c)
	-- 设置超量召唤手续：战士族4星怪兽2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),4,2)
	c:EnableReviveLimit()
	-- 这张卡被战斗破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c77631175.reptg)
	c:RegisterEffect(e1)
	-- 这个效果让超量素材被取除时，这张卡的攻击力上升500，给与对方基本分500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77631175,1))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CUSTOM+77631175)
	e2:SetTarget(c77631175.target)
	e2:SetOperation(c77631175.operation)
	c:RegisterEffect(e2)
end
-- 代替破坏效果的Target函数，检测是否因战斗破坏以及是否能取除1个超量素材，并执行取除素材和触发自定义事件
function c77631175.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReason(REASON_BATTLE) and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local c=e:GetHandler()
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		-- 触发自定义事件，用于检测“这个效果让超量素材被取除时”的时点
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+77631175,e,0,0,0,0)
		return true
	else return false end
end
-- 攻击力上升和伤害效果的Target函数，设置伤害的对象玩家和伤害数值，并设置操作信息
function c77631175.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数（伤害数值）设置为500
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息为给与对方玩家500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 攻击力上升和伤害效果的Operation函数，使自身攻击力上升500，并给与对方500点伤害
function c77631175.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡的攻击力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 获取当前连锁设定的对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
