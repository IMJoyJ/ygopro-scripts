--地縛神の咆哮
-- 效果：
-- 对方怪兽的攻击宣言时，攻击怪兽的攻击力比自己场上表侧表示存在的名字带有「地缚神」的怪兽的攻击力低的场合，把那1只攻击怪兽破坏，给与对方基本分破坏怪兽的攻击力一半数值的伤害。这个效果1回合只能使用1次。
function c56339050.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方怪兽的攻击宣言时，攻击怪兽的攻击力比自己场上表侧表示存在的名字带有「地缚神」的怪兽的攻击力低的场合，把那1只攻击怪兽破坏，给与对方基本分破坏怪兽的攻击力一半数值的伤害。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56339050,0))  --"破坏并伤害"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1)
	e2:SetCondition(c56339050.condition)
	e2:SetTarget(c56339050.target)
	e2:SetOperation(c56339050.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示存在且攻击力大于指定数值（攻击怪兽攻击力）的「地缚神」怪兽
function c56339050.cfilter(c,atk)
	return c:IsFaceup() and c:IsSetCard(0x1021) and c:GetAttack()>atk
end
-- 发动条件：对方怪兽攻击宣言时，且自己场上存在攻击力比该攻击怪兽高的表侧表示「地缚神」怪兽
function c56339050.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local tc=Duel.GetAttacker()
	-- 检查当前回合玩家是否为对方，且自己场上是否存在满足过滤条件的「地缚神」怪兽
	return Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(c56339050.cfilter,tp,LOCATION_MZONE,0,1,nil,tc:GetAttack())
end
-- 效果发动时的目标选择与操作信息设置：将攻击怪兽设为效果处理对象，计算伤害数值，并设置破坏与伤害的操作信息
function c56339050.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local tc=Duel.GetAttacker()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsOnField() and tc:IsCanBeEffectTarget(e) end
	-- 将该攻击怪兽设为当前效果的处理对象（取对象）
	Duel.SetTargetCard(tc)
	local dam=math.floor(tc:GetAttack()/2)
	-- 将计算出的伤害数值（攻击力的一半）保存为效果参数
	Duel.SetTargetParam(dam)
	-- 设置破坏操作信息：破坏1只目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设置伤害操作信息：给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理：若目标怪兽仍合法，则将其破坏，并给与对方其攻击力一半数值的伤害
function c56339050.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时设定的效果处理对象（即攻击怪兽）
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackable() then
		local atk=math.floor(tc:GetAttack()/2)
		-- 尝试以效果破坏目标怪兽，若成功破坏则执行后续处理
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给与对方玩家相当于该怪兽攻击力一半数值的效果伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
