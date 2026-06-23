--機皇神龍アステリスク
-- 效果：
-- 这张卡不能通常召唤。自己场上的「机皇」怪兽是3只以上的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功时，以这张卡以外的自己场上的「机皇」怪兽任意数量为对象才能发动。那些自己的「机皇」怪兽送去墓地。这张卡的攻击力变成这个效果送去墓地的怪兽的原本攻击力合计数值。
-- ②：每次同调怪兽特殊召唤发动。给与把那些怪兽特殊召唤的玩家1000伤害。
function c38522377.initial_effect(c)
	c:EnableReviveLimit()
	-- ②：每次同调怪兽特殊召唤发动。给与把那些怪兽特殊召唤的玩家1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38522377.spcon)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功时，以这张卡以外的自己场上的「机皇」怪兽任意数量为对象才能发动。那些自己的「机皇」怪兽送去墓地。这张卡的攻击力变成这个效果送去墓地的怪兽的原本攻击力合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38522377,0))  --"攻击变化"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c38522377.atktg)
	e2:SetOperation(c38522377.atkop)
	c:RegisterEffect(e2)
	-- ②：每次同调怪兽特殊召唤发动。给与把那些怪兽特殊召唤的玩家1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38522377,1))  --"LP伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c38522377.damcon)
	e3:SetTarget(c38522377.damtg)
	e3:SetOperation(c38522377.damop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在「机皇」怪兽。
function c38522377.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13)
end
-- 特殊召唤条件函数，判断是否满足特殊召唤的条件。
function c38522377.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家场上是否有足够的怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查玩家场上是否有至少3只「机皇」怪兽。
		and Duel.IsExistingMatchingCard(c38522377.spfilter,c:GetControler(),LOCATION_MZONE,0,3,nil)
end
-- 效果处理函数，用于选择目标怪兽并设置操作信息。
function c38522377.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查是否至少存在一只「机皇」怪兽作为目标。
	if chk==0 then return Duel.IsExistingTarget(c38522377.spfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择目标怪兽，数量为1至7只。
	local g=Duel.SelectTarget(tp,c38522377.spfilter,tp,LOCATION_MZONE,0,1,7,e:GetHandler())
	-- 设置操作信息，表示将要将目标怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 过滤函数，用于判断怪兽是否与效果相关且处于表侧表示。
function c38522377.atkfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup()
end
-- 效果处理函数，将目标怪兽送去墓地并改变自身攻击力。
function c38522377.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的目标怪兽，并过滤出与效果相关的怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c38522377.atkfilter,nil,e)
	-- 将目标怪兽送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取实际被送去墓地的怪兽组。
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	local atk=og:GetSum(Card.GetBaseAttack)
	-- 设置自身攻击力为被送去墓地的怪兽攻击力总和。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 伤害触发条件函数，判断是否有同调怪兽被特殊召唤。
function c38522377.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end
-- 设置伤害效果的目标和数量。
function c38522377.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local t1=false
	local t2=false
	local tc=eg:GetFirst()
	while tc do
		if tc:IsType(TYPE_SYNCHRO) then
			if tc:IsSummonPlayer(tp) then t1=true else t2=true end
		end
		tc=eg:GetNext()
	end
	-- 若由自己方召唤的同调怪兽，则对对方造成1000伤害。
	if t1 and not t2 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
	-- 若由对方召唤的同调怪兽，则对自己造成1000伤害。
	elseif not t1 and t2 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	-- 若双方均有召唤，则各自对对方造成1000伤害。
	else Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000) end
end
-- 执行伤害效果，根据设定对玩家造成伤害。
function c38522377.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取操作信息中的伤害目标。
	local ex,g,gc,dp,dv=Duel.GetOperationInfo(0,CATEGORY_DAMAGE)
	-- 若伤害目标非双方，则对单一目标造成伤害。
	if dp~=PLAYER_ALL then Duel.Damage(dp,1000,REASON_EFFECT)
	else
		-- 对玩家造成1000伤害，并触发时点。
		Duel.Damage(tp,1000,REASON_EFFECT,true)
		-- 对对方造成1000伤害，并触发时点。
		Duel.Damage(1-tp,1000,REASON_EFFECT,true)
		-- 完成伤害处理的时点触发。
		Duel.RDComplete()
	end
end
