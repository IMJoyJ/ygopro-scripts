--ラプテノスの超魔剣
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽的表示形式的以下效果适用。
-- ●攻击表示：装备怪兽不会成为对方的效果的对象。
-- ●守备表示：装备怪兽不会被战斗破坏。
-- ②：自己·对方的战斗阶段开始时才能发动。装备怪兽的表示形式变更，把1只怪兽召唤。
function c53363708.initial_effect(c)
	-- ①：装备怪兽的表示形式的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c53363708.target)
	e1:SetOperation(c53363708.operation)
	c:RegisterEffect(e1)
	-- ●攻击表示：装备怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCondition(c53363708.tgcon)
	-- 设置抗性效果的判定值：效果发动者为对方时，装备怪兽不能成为该效果的对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ●守备表示：装备怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(c53363708.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的战斗阶段开始时才能发动。装备怪兽的表示形式变更，把1只怪兽召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(53363708,0))
	e4:SetCategory(CATEGORY_POSITION+CATEGORY_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,53363708)
	e4:SetTarget(c53363708.postg)
	e4:SetOperation(c53363708.posop)
	c:RegisterEffect(e4)
	-- ①：装备怪兽的表示形式的以下效果适用。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 发动时选择场上1只表侧表示怪兽作为装备对象，并设置装备操作信息。
function c53363708.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只表侧表示怪兽可以成为装备对象，以此判定效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从场上选择1只表侧表示怪兽，并将其设为这张卡的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记本连锁将进行的装备操作（装备这张卡给对象），供效果发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果结算时，若这张卡和目标怪兽仍与效果关联且目标表侧表示，则将这张卡装备给目标怪兽。
function c53363708.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这张卡当前连锁的对象（即要装备的怪兽）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备魔法卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 发动条件：装备怪兽为表侧攻击表示时，攻击表示的抗性效果才适用。
function c53363708.tgcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:IsAttackPos()
end
-- 发动条件：装备怪兽为表侧守备表示时，守备表示的战破抗性才适用。
function c53363708.indcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:IsDefensePos()
end
-- ②效果的发动条件判断：检查战斗阶段开始时装备怪兽能否变更表示形式，以及是否存在可通常召唤的怪兽，并登记相应的操作信息。
function c53363708.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetEquipTarget()
	-- 验证装备怪兽可以变更表示形式，并且手牌或场上有满足通常召唤条件的怪兽。
	if chk==0 then return tc and tc:IsCanChangePosition() and Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,true,nil) end
	-- 登记将变更装备怪兽表示形式的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
	-- 登记将进行1只怪兽的通常召唤的操作信息（目标在效果处理时决定）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理：先变更装备怪兽的表示形式，若成功，则选择1只怪兽进行通常召唤。
function c53363708.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	-- 变更装备怪兽的表示形式（表侧攻击与表侧守备互换），并确认是否成功变更。
	if tc and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 then
		-- 显示“请选择要召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 从手牌或场上选择1张满足通常召唤条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,true,nil)
		if g:GetCount()>0 then
			-- 无视一回合通常召唤次数限制，将选择的怪兽通常召唤。
			Duel.Summon(tp,g:GetFirst(),true,nil)
		end
	end
end
