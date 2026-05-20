--No.52 ダイヤモンド・クラブ・キング
-- 效果：
-- 4星怪兽×2
-- ①：「No.52 钻蟹王」在自己场上只能有1只表侧表示存在。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。直到回合结束时，这张卡的守备力变成0，攻击力变成3000。
-- ③：这张卡攻击的场合，战斗阶段结束时变成守备表示。
-- ④：没有超量素材的这张卡被攻击的伤害步骤结束时变成攻击表示。
function c7194917.initial_effect(c)
	c:SetUniqueOnField(1,0,7194917)
	-- 添加超量召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。直到回合结束时，这张卡的守备力变成0，攻击力变成3000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7194917,0))  --"攻守变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c7194917.adcost)
	e1:SetOperation(c7194917.adop)
	c:RegisterEffect(e1)
	-- ③：这张卡攻击的场合，战斗阶段结束时变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c7194917.poscon1)
	e2:SetOperation(c7194917.posop1)
	c:RegisterEffect(e2)
	-- ④：没有超量素材的这张卡被攻击的伤害步骤结束时变成攻击表示。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(c7194917.poscon2)
	e3:SetOperation(c7194917.posop2)
	c:RegisterEffect(e3)
end
-- 设置该卡的「No.」数值为52
aux.xyz_number[7194917]=52
-- 作为发动代价，检查并取除这张卡的1个超量素材
function c7194917.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 使这张卡的攻击力变成3000，守备力变成0的效果处理
function c7194917.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 直到回合结束时，这张卡的攻击力变成3000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 直到回合结束时，这张卡的守备力变成0
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(0)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 检查这张卡在本回合是否进行过攻击
function c7194917.poscon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 若这张卡为攻击表示，则将其变成表侧守备表示
function c7194917.posop1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsAttackPos() then
		-- 将这张卡变成表侧守备表示
		Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
	end
end
-- 检查这张卡是否作为攻击对象被攻击，且没有超量素材
function c7194917.poscon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自身是攻击对象且没有超量素材
	return e:GetHandler()==Duel.GetAttackTarget() and e:GetHandler():GetOverlayCount()==0
end
-- 若这张卡在战斗后仍存在于场上且为守备表示，则将其变成表侧攻击表示
function c7194917.posop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() and c:IsDefensePos() then
		-- 将这张卡变成表侧攻击表示
		Duel.ChangePosition(c,POS_FACEUP_ATTACK)
	end
end
