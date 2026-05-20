--アンブラル・ウィル・オ・ザ・ウィスプ
-- 效果：
-- 这张卡召唤·特殊召唤成功时，选择这张卡以外的自己的场上·墓地1只名字带有「阴影」的怪兽才能发动。这张卡的等级变成和选择的怪兽的等级相同。此外，场上表侧攻击表示存在的这张卡被战斗破坏送去墓地时，把让这张卡破坏的怪兽破坏。
function c70546737.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，选择这张卡以外的自己的场上·墓地1只名字带有「阴影」的怪兽才能发动。这张卡的等级变成和选择的怪兽的等级相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70546737,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c70546737.lvtg)
	e1:SetOperation(c70546737.lvop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 此外，场上表侧攻击表示存在的这张卡被战斗破坏送去墓地时，把让这张卡破坏的怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70546737,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(c70546737.descon)
	e3:SetTarget(c70546737.destg)
	e3:SetOperation(c70546737.desop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上或墓地表侧表示存在、等级在1以上且等级与自身不同的「阴影」怪兽
function c70546737.filter(c,clv)
	return c:IsSetCard(0x87) and c:IsLevelAbove(1) and not c:IsLevel(clv)
		and ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE))
end
-- 等级变化效果的发动准备，确认并选择符合条件的「阴影」怪兽作为对象
function c70546737.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c70546737.filter(chkc,e:GetHandler():GetLevel()) end
	-- 在发动准备阶段，检测自己场上或墓地是否存在符合条件的「阴影」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c70546737.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler(),e:GetHandler():GetLevel()) end
	-- 向玩家发送提示信息，要求选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上或墓地1只符合条件的「阴影」怪兽作为效果的对象
	Duel.SelectTarget(tp,c70546737.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,e:GetHandler(),e:GetHandler():GetLevel())
end
-- 等级变化效果的处理，使这张卡的等级变成和选择的怪兽的等级相同
function c70546737.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e)
		and (not tc:IsLocation(LOCATION_MZONE) or tc:IsFaceup()) then
		-- 这张卡的等级变成和选择的怪兽的等级相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 破坏效果的发动条件：场上表侧攻击表示存在的这张卡被战斗破坏送去墓地
function c70546737.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetBattlePosition()==POS_FACEUP_ATTACK and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
-- 破坏效果的发动准备，将让这张卡破坏的怪兽设为效果处理的对象并设置破坏操作信息
function c70546737.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=e:GetHandler():GetReasonCard()
	-- 将让这张卡破坏的怪兽设定为当前连锁的对象
	Duel.SetTargetCard(rc)
	-- 设置当前连锁的操作信息为：破坏1张作为对象的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,0,0)
end
-- 破坏效果的处理，把让这张卡破坏的怪兽破坏
function c70546737.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被设定为对象的让这张卡破坏的怪兽
	local rc=Duel.GetFirstTarget()
	if rc:IsRelateToEffect(e) then
		-- 因效果将该破坏这张卡的怪兽破坏
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
