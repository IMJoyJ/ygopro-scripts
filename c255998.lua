--ラピッド・ウォリアー
-- 效果：
-- 主要阶段1才能发动。这个回合这张卡可以直接攻击对方玩家。这个效果发动的回合，这张卡以外的怪兽不能攻击。
function c255998.initial_effect(c)
	-- 创建一个起动效果，效果描述为“直接攻击”，效果类型为起动效果，适用区域为主要怪兽区，条件为满足发动条件且自身未获得直接攻击效果，费用为cost函数，效果为operation函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(255998,0))  --"直接攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c255998.condition)
	e1:SetCost(c255998.cost)
	e1:SetOperation(c255998.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：回合玩家可以进入战斗阶段且自身未获得直接攻击效果
function c255998.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段且自身未获得直接攻击效果
	return Duel.IsAbleToEnterBP() and not e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 攻击限制目标函数：排除与效果标签相同的怪兽
function c255998.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 费用函数：创建一个字段效果，使所有怪兽不能攻击，该效果为誓约效果，影响我方主要怪兽区，目标为ftarget函数，标签为自身场ID，结束阶段重置
function c255998.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 注册字段效果，使所有怪兽不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c255998.ftarget)
	e1:SetLabel(e:GetHandler():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 效果处理函数：若自身表侧表示且与效果相关，则获得直接攻击效果
function c255998.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 创建一个永续效果，使自身可以进行直接攻击，该效果不能被无效，结束阶段重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
