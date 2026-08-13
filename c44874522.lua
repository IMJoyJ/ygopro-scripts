--古代の機械熱核竜
-- 效果：
-- ①：把「古代的机械」怪兽解放作上级召唤的这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：把「零件」怪兽解放作上级召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：这张卡攻击的场合，对方直到伤害步骤结束时怪兽的效果·魔法·陷阱卡不能发动。
-- ④：这张卡攻击的伤害步骤结束时才能发动。选场上1张魔法·陷阱卡破坏。
function c44874522.initial_effect(c)
	-- ①：把「古代的机械」怪兽解放作上级召唤的这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。②：把「零件」怪兽解放作上级召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c44874522.valcheck)
	c:RegisterEffect(e1)
	-- ①：把「古代的机械」怪兽解放作上级召唤的这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。②：把「零件」怪兽解放作上级召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c44874522.regcon)
	e2:SetOperation(c44874522.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
	-- ③：这张卡攻击的场合，对方直到伤害步骤结束时怪兽的效果·魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c44874522.aclimit)
	e3:SetCondition(c44874522.actcon)
	c:RegisterEffect(e3)
	-- ④：这张卡攻击的伤害步骤结束时才能发动。选场上1张魔法·陷阱卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(44874522,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(c44874522.condition)
	e4:SetTarget(c44874522.target)
	e4:SetOperation(c44874522.operation)
	c:RegisterEffect(e4)
end
-- 检查上级召唤这张卡时使用的素材，若素材中含有「古代的机械」怪兽则置flag的0x1位，若含有「零件」怪兽则置0x2位，并将flag存入效果e的Label中，用于后续判断是否赋予贯穿/追加攻击。
function c44874522.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	local tc=g:GetFirst()
	while tc do
		if tc:IsSetCard(0x7) and tc:IsType(TYPE_MONSTER) then flag=bit.bor(flag,0x1) end
		if tc:IsSetCard(0x51) and tc:IsType(TYPE_MONSTER) then flag=bit.bor(flag,0x2) end
		tc=g:GetNext()
	end
	e:SetLabel(flag)
end
-- 该效果的触发条件为这张卡成功进行上级召唤（召唤类型为SUMMON_TYPE_ADVANCE）。
function c44874522.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 根据材料检查记录的标志位，若含有「古代的机械」素材则给此卡注册贯穿伤害效果；若含有「零件」素材则注册额外攻击次数+1的效果；两个效果均在该卡离场等标准重置时消失。
function c44874522.regop(e,tp,eg,ep,ev,re,r,rp)
	local flag=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if bit.band(flag,0x1)~=0 then
		-- ①：把「古代的机械」怪兽解放作上级召唤的这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	if bit.band(flag,0x2)~=0 then
		-- ②：把「零件」怪兽解放作上级召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 作为EFFECT_CANNOT_ACTIVATE的判定函数：若对方发动的效果是魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE）或是怪兽效果（TYPE_MONSTER），则返回true，即禁止其发动。
function c44874522.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)
end
-- 作为EFFECT_CANNOT_ACTIVATE的适用条件：仅当当前攻击怪兽是这张卡自身时，封锁对方的效果发动。
function c44874522.actcon(e)
	-- 判断当前进行攻击的怪兽是否为此卡自身。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 此卡在伤害步骤结束时作为发动条件判断：通过aux.dsercon确认此卡仍与这次战斗相关（未离场或拥有战斗破坏状态），且当前攻击者为这张卡自身，两者同时满足才可发动④。
function c44874522.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测此卡在伤害步骤结束时仍与战斗相关（未离场或处于战斗破坏状态），并且当前的攻击者正是此卡自身。
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetAttacker()==e:GetHandler()
end
-- 筛选场上满足条件的卡：只要是魔法·陷阱卡即可成为④的破坏对象。
function c44874522.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ④的发动合法性检查和目标设定：若场上存在可破坏的魔法·陷阱卡则允许发动；取得场上所有魔法·陷阱卡，并将其设置为本次破坏效果的操作信息，预计破坏1张。
function c44874522.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查场上是否存在至少1张魔法·陷阱卡，若存在则满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c44874522.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有魔法·陷阱卡的集合，用于设置操作信息。
	local g=Duel.GetMatchingGroup(c44874522.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将本次操作信息设定为破坏类别，目标为场上所有魔法·陷阱卡，预计破坏数量为1，供连锁与相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ④效果处理时，从双方场上选择1张魔法·陷阱卡，向玩家显示选择提示并播放选中动画，最后以效果原因将其破坏。
function c44874522.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示“请选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从双方场上选择1张魔法·陷阱卡作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,c44874522.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的卡片播放被选择的动画并记录为对象。
		Duel.HintSelection(g)
		-- 以效果原因破坏所选卡片。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
