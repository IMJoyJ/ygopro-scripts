--ガガガザムライ
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只「我我我」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡以外的自己怪兽被选择作为攻击对象时才能发动。这张卡变成表侧守备表示，攻击对象转移为这张卡进行伤害计算。
function c91499077.initial_effect(c)
	-- 设置XYZ召唤手续：4星怪兽2只
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只「我我我」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91499077,0))  --"2次攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c91499077.atcon)
	e1:SetCost(c91499077.atcost)
	e1:SetTarget(c91499077.attg)
	e1:SetOperation(c91499077.atop)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的自己怪兽被选择作为攻击对象时才能发动。这张卡变成表侧守备表示，攻击对象转移为这张卡进行伤害计算。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91499077,1))  --"对象变更"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c91499077.cbcon)
	e2:SetOperation(c91499077.cbop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：当前回合玩家可以进入战斗阶段
function c91499077.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 效果①的代价：取除这张卡的1个超量素材
function c91499077.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：自己场上表侧表示、属于「我我我」字段、且未获得追加攻击效果的怪兽
function c91499077.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x54) and c:GetEffectCount(EFFECT_EXTRA_ATTACK)==0
end
-- 效果①的目标选择：选择自己场上1只表侧表示的「我我我」怪兽为对象
function c91499077.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c91499077.filter(chkc) end
	-- 在发动阶段，检查自己场上是否存在符合条件的「我我我」怪兽
	if chk==0 then return Duel.IsExistingTarget(c91499077.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只符合条件的「我我我」怪兽作为效果对象
	Duel.SelectTarget(tp,c91499077.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理：使作为对象的怪兽在同一次战斗阶段中可以作2次攻击
function c91499077.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：这张卡以外的自己怪兽被选择作为攻击对象时
function c91499077.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local bt=eg:GetFirst()
	return r~=REASON_REPLACE and bt~=e:GetHandler() and bt:IsControler(tp)
end
-- 效果②的效果处理：这张卡变成表侧守备表示，攻击对象转移为这张卡进行伤害计算
function c91499077.cbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否表侧表示存在且此效果有效，并尝试将自身变为表侧守备表示
	if c:IsFaceup() and c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)~=0 then
		-- 获取当前进行攻击的怪兽
		local at=Duel.GetAttacker()
		if at:IsAttackable() and not at:IsImmuneToEffect(e) and not c:IsImmuneToEffect(e) then
			-- 强制令攻击怪兽与这张卡进行伤害计算
			Duel.CalculateDamage(at,c)
		end
	end
end
