--古代の機械合成竜
-- 效果：
-- ①：和把「古代的机械」怪兽解放作上级召唤的这张卡的战斗没让对方怪兽被破坏的伤害步骤结束时才能发动。那只对方怪兽除外。
-- ②：把「零件」怪兽解放作上级召唤的这张卡可以向对方怪兽全部各作1次攻击。
-- ③：自己的「古代的机械」怪兽攻击的场合，对方直到伤害步骤结束时怪兽的效果·魔法·陷阱卡不能发动。
function c81269231.initial_effect(c)
	-- 把「古代的机械」怪兽解放作上级召唤的 / 把「零件」怪兽解放作上级召唤的
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c81269231.valcheck)
	c:RegisterEffect(e1)
	-- ①：和把「古代的机械」怪兽解放作上级召唤的这张卡的战斗没让对方怪兽被破坏的伤害步骤结束时才能发动。那只对方怪兽除外。 / ②：把「零件」怪兽解放作上级召唤的这张卡可以向对方怪兽全部各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c81269231.regcon)
	e2:SetOperation(c81269231.regop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ③：自己的「古代的机械」怪兽攻击的场合，对方直到伤害步骤结束时怪兽的效果·魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c81269231.aclimit)
	e3:SetCondition(c81269231.actcon)
	c:RegisterEffect(e3)
end
-- 注册素材检查效果，在上级召唤成功时检测并记录解放的怪兽是否为「古代的机械」或「零件」怪兽
function c81269231.valcheck(e,c)
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
-- 判断此卡是否为上级召唤成功
function c81269231.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 根据解放素材的检测结果，分别为此卡注册对应的追加效果（①的除外效果或②的全体攻击效果）
function c81269231.regop(e,tp,eg,ep,ev,re,r,rp)
	local flag=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if bit.band(flag,0x1)~=0 then
		-- ①：和把「古代的机械」怪兽解放作上级召唤的这张卡的战斗没让对方怪兽被破坏的伤害步骤结束时才能发动。那只对方怪兽除外。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(81269231,0))
		e1:SetCategory(CATEGORY_REMOVE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetCondition(c81269231.rmcon)
		e1:SetTarget(c81269231.rmtg)
		e1:SetOperation(c81269231.rmop)
		e1:SetReset(RESET_EVENT+RESET_TURN_SET+RESET_TOHAND+RESET_TODECK+RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
	if bit.band(flag,0x2)~=0 then
		-- ②：把「零件」怪兽解放作上级召唤的这张卡可以向对方怪兽全部各作1次攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ATTACK_ALL)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 判断除外效果的发动条件：伤害步骤结束时，对方战斗怪兽未被破坏且仍存在于场上
function c81269231.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方的战斗怪兽
	local t=Duel.GetBattleMonster(1-tp)
	e:SetLabelObject(t)
	-- 判断自身是否参与战斗，且对方战斗怪兽是否仍与战斗关联（未被破坏）
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and t and t:IsRelateToBattle()
end
-- 判断对方战斗怪兽是否可以除外，并设置除外的操作信息
function c81269231.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():IsAbleToRemove() end
	-- 设置除外操作信息，指定目标为对方的战斗怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
-- 除外效果的实际处理：将仍与战斗关联的对方战斗怪兽除外
function c81269231.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() then
		-- 将对方战斗怪兽表侧表示除外
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 限制对方不能发动魔法·陷阱卡的发动以及怪兽的效果
function c81269231.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)
end
-- 判断封锁效果的适用条件：当前攻击的怪兽是自己控制的「古代的机械」怪兽
function c81269231.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	return a and a:IsSetCard(0x7) and a:IsControler(tp)
end
