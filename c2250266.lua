--D・ステープラン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：只要这张卡在场上表侧表示存在，对方不能选择其他怪兽作为攻击对象。这张卡被战斗破坏的场合，把让这张卡破坏的怪兽的攻击力下降300。
-- ●守备表示：这张卡不会被战斗破坏。这张卡被攻击的场合，那次伤害计算后选择对方场上表侧攻击表示存在的1只怪兽变成守备表示，这张卡的表示形式变成攻击表示。
function c2250266.initial_effect(c)
	-- 这张卡得到这张卡的表示形式的以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_LEAVE_FIELD_P)
	e1:SetOperation(c2250266.check)
	c:RegisterEffect(e1)
	-- 这张卡被战斗破坏的场合，把让这张卡破坏的怪兽的攻击力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2250266,0))  --"攻击下降"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c2250266.cona)
	e2:SetOperation(c2250266.opa)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，对方不能选择其他怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetCondition(c2250266.cona2)
	e3:SetValue(c2250266.atlimit)
	c:RegisterEffect(e3)
	-- 这张卡不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetCondition(c2250266.cond)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 这张卡被攻击的场合，那次伤害计算后选择对方场上表侧攻击表示存在的1只怪兽变成守备表示，这张卡的表示形式变成攻击表示。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(2250266,1))  --"变成攻击表示"
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLED)
	e5:SetCondition(c2250266.cond)
	e5:SetTarget(c2250266.tgd2)
	e5:SetOperation(c2250266.opd2)
	c:RegisterEffect(e5)
end
-- 在离场前检查这张卡是否未被无效且为攻击表示：若是则把辅助效果e1的Label记为1（攻击），否则记为0（非攻击/无效），用于后续战斗破坏时判断攻击表示效果是否适用。
function c2250266.check(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsDisabled() and c:IsAttackPos() then e:SetLabel(1)
	else e:SetLabel(0) end
end
-- e2的发动条件：通过e1的Label判断这张卡在被战斗破坏离场前为攻击表示，只有攻击表示时才发动攻击力下降效果。
function c2250266.cona(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
-- e2的效果处理：取得导致这张卡被战斗破坏的怪兽rc；若rc仍与本次战斗关联，则给rc注册一个单次永续效果，使其攻击力下降300，并在rc离场/翻转等标准重置时失效。
function c2250266.opa(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsRelateToBattle() then
		-- 把让这张卡破坏的怪兽的攻击力下降300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end
-- e3的适用条件：这张卡为表侧攻击表示，满足“攻击表示”时才能封锁对方攻击对象。
function c2250266.cona2(e)
	return e:GetHandler():IsAttackPos()
end
-- e3的Value函数：对每个将成为攻击对象的怪兽c，若c不是这张卡自身则返回true，即对方不能选择这只c作为攻击对象，实现“对方不能选择其他怪兽作为攻击对象”。
function c2250266.atlimit(e,c)
	return c~=e:GetHandler()
end
-- e4/e5共用条件：这张卡未被无效且为守备表示，满足“守备表示”时才适用不会战斗破坏及被攻击变形的效果。
function c2250266.cond(e)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
-- 选择对象的过滤器：对方场上表侧攻击表示且当前可以变更表示形式的怪兽，作为“对方场上表侧攻击表示存在的1只怪兽”的候选。
function c2250266.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- e5的发动目标处理：伤害计算后，若效果可以发动，提示玩家选择对方场上1只表侧攻击表示且可变更表示形式的怪兽作为对象，并设置操作信息为改变表示形式；同时处理连锁选择（chkc）合法性。
function c2250266.tgd2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c2250266.filter(chkc) end
	if chk==0 then return true end
	-- 向操作玩家显示选择提示消息，提示文字为“请选择攻击表示的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)  --"请选择攻击表示的怪兽"
	-- 让操作玩家从对方场上筛选出符合条件的1只表侧攻击表示怪兽，并将它登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c2250266.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁将进行改变表示形式的处理，对象为已选择的那1只怪兽，用于让其他卡（如星尘龙等）能检测到该操作。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- e5的效果处理：取得效果对象tc，若tc仍与效果关联且表侧攻击表示，则先将tc变为表侧守备表示；若变更成功且这张卡仍与本次战斗关联，则再将自身变为表侧攻击表示。
function c2250266.opd2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果连锁中登记的对象卡（对方场上被选择的那只表侧攻击表示怪兽）。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackPos()
		-- 判定条件：对象tc仍与效果关联、表侧攻击表示，并且成功通过ChangePosition将tc变为表侧守备表示（返回值非0），同时自身仍与本次战斗关联，才执行后续将自身变为攻击表示。
		and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 and c:IsRelateToBattle() then
		-- 将这张卡自身的表示形式变更为表侧攻击表示，完成“这张卡的表示形式变成攻击表示”的处理。
		Duel.ChangePosition(e:GetHandler(),POS_FACEUP_ATTACK,0,POS_FACEUP_ATTACK,0)
	end
end
