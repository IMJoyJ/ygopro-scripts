--ゴーストリックの雪女
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，这张卡被战斗破坏送去墓地时才能发动。让把这张卡破坏的怪兽变成里侧守备表示，不能把表示形式变更。
function c54490275.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c54490275.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54490275,0))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c54490275.postg)
	e2:SetOperation(c54490275.posop)
	c:RegisterEffect(e2)
	-- 此外，这张卡被战斗破坏送去墓地时才能发动。让把这张卡破坏的怪兽变成里侧守备表示，不能把表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(54490275,1))  --"变成里侧守备"
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(c54490275.poscon2)
	e3:SetTarget(c54490275.postg2)
	e3:SetOperation(c54490275.posop2)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的「鬼计」怪兽
function c54490275.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制效果的Condition函数，当自己场上不存在表侧表示的「鬼计」怪兽时，不能召唤
function c54490275.sumcon(e)
	-- 检查自己场上是否不存在表侧表示的「鬼计」怪兽
	return not Duel.IsExistingMatchingCard(c54490275.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 变成里侧守备表示效果的Target函数，检查自身是否能变成里侧守备表示且本回合未发动过该效果，并注册1回合1次的发动标记
function c54490275.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(54490275)==0 end
	c:RegisterFlagEffect(54490275,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息，表示该效果包含改变1张卡表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果的Operation函数，若自身仍在场上且表侧表示，则将其变成里侧守备表示
function c54490275.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身变成里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 战斗破坏效果的Condition函数，检查自身是否因战斗破坏送去墓地，且破坏自身的怪兽仍存在
function c54490275.poscon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetReasonCard():IsRelateToBattle()
end
-- 战斗破坏效果的Target函数，获取破坏自身的怪兽，检查其是否能变成里侧守备表示，并将其设为效果对象
function c54490275.postg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	if chk==0 then return rc:IsCanTurnSet() end
	-- 将破坏自身的怪兽设为当前连锁的效果对象
	Duel.SetTargetCard(rc)
	-- 设置操作信息，表示该效果包含改变该怪兽表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,rc,1,0,0)
end
-- 战斗破坏效果的Operation函数，将作为对象的怪兽变成里侧守备表示，并为其添加不能变更表示形式的效果
function c54490275.posop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象（即破坏自身的怪兽）
	local rc=Duel.GetFirstTarget()
	if rc:IsFaceup() and rc:IsRelateToEffect(e) then
		-- 将破坏自身的怪兽变成里侧守备表示
		Duel.ChangePosition(rc,POS_FACEDOWN_DEFENSE)
		-- 不能把表示形式变更。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end
