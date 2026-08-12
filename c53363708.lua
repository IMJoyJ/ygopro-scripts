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
	-- 设置装备怪兽在攻击表示时不会成为对方效果对象的过滤函数
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ●守备表示：装备怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(c53363708.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：自己·对方的战斗阶段开始时才能发动。装备怪兽的表示形式变更，把1只怪兽召唤。
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
	-- 这个卡名的②的效果1回合只能使用1次。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 装备魔法卡的发动目标选择函数，检查场上是否有可装备的表侧表示怪兽
function c53363708.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否存在表侧表示的怪兽作为装备对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择场上的一只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备操作信息，将此卡设置为装备卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡的装备处理函数，实际执行装备操作
function c53363708.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选定为装备对象的怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡装备到目标怪兽上
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 攻击表示装备效果的适用条件：装备怪兽为攻击表示时触发
function c53363708.tgcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:IsAttackPos()
end
-- 守备表示装备效果的适用条件：装备怪兽为守备表示时触发
function c53363708.indcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:IsDefensePos()
end
-- ②效果的发动检测函数，检查装备怪兽是否能改变表示形式且手牌有可召唤怪兽
function c53363708.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetEquipTarget()
	-- 检查装备怪兽可以改变表示形式且存在可通常召唤的怪兽
	if chk==0 then return tc and tc:IsCanChangePosition() and Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,true,nil) end
	-- 设置改变表示形式操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
	-- 设置召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果的处理函数，改变装备怪兽表示形式并召唤怪兽
function c53363708.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	-- 将装备怪兽变为守备表示后执行后续召唤处理
	if tc and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 then
		-- 提示玩家选择要召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 让玩家选择手牌或场上可通常召唤的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,true,nil)
		if g:GetCount()>0 then
			-- 执行通常召唤所选的怪兽
			Duel.Summon(tp,g:GetFirst(),true,nil)
		end
	end
end
