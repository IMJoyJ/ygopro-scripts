--隠し砦 ストロング・ホールド
-- 效果：
-- ①：这张卡发动后变成持有以下效果的效果怪兽（机械族·地·4星·攻0/守2000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ●这张卡的攻击力上升自己场上的「光之黄金柜」以及有那个卡名记述的怪兽数量×1000。
-- ●1回合1次，自己场上有「光之黄金柜」存在的场合，对方怪兽的攻击宣言时才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：特殊召唤、攻击力上升、攻击宣言时破坏效果
function s.initial_effect(c)
	-- 记录该卡效果文本中记载着「光之黄金柜」（卡号79791878）
	aux.AddCodeList(c,79791878)
	-- ①：这张卡发动后变成持有以下效果的效果怪兽（机械族·地·4星·攻0/守2000）在怪兽区域特殊召唤（也当作陷阱卡使用）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ●这张卡的攻击力上升自己场上的「光之黄金柜」以及有那个卡名记述的怪兽数量×1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- ●1回合1次，自己场上有「光之黄金柜」存在的场合，对方怪兽的攻击宣言时才能发动。那只怪兽破坏
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 判断是否可以发动特殊召唤效果，检查场上是否有空位且是否可以特殊召唤该怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤该怪兽（指定参数为怪兽属性）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置操作信息，表示将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 发动效果时执行的操作，检查是否可以特殊召唤并执行特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否可以特殊召唤该怪兽（指定参数为怪兽属性）
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,4,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将该卡以特殊召唤方式（SUMMON_VALUE_SELF）特殊召唤到场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 定义攻击力计算的过滤函数，用于判断是否为「光之黄金柜」或记载有其卡名的怪兽
function s.atkfilter(c)
	-- 判断是否为「光之黄金柜」或记载有其卡名的怪兽且在场上表侧表示
	return (c:IsCode(79791878) or (aux.IsCodeListed(c,79791878) and c:IsLocation(LOCATION_MZONE))) and c:IsFaceup()
end
-- 定义攻击力上升效果的触发条件，判断该卡是否为特殊召唤（SUMMON_VALUE_SELF）
function s.atkcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 定义攻击力上升效果的计算函数，计算场上符合条件的怪兽数量并乘以1000
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	-- 获取场上符合条件的怪兽数量并乘以1000作为攻击力上升值
	return Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_ONFIELD,0,nil)*1000
end
-- 定义攻击宣言时破坏效果的过滤函数，用于判断是否为「光之黄金柜」且在场上表侧表示
function s.filter(c)
	return c:IsCode(79791878) and c:IsFaceup()
end
-- 定义攻击宣言时破坏效果的触发条件，判断攻击方是否为对方且己方场上有「光之黄金柜」
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上有「光之黄金柜」存在
	return Duel.GetAttacker():IsControler(1-tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
		and e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 设置攻击宣言时破坏效果的目标和操作信息，确定目标为攻击怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击怪兽作为目标
	local tg=Duel.GetAttacker()
	if chk==0 then return tg:IsOnField() end
	-- 设置当前连锁处理的目标为攻击怪兽
	Duel.SetTargetCard(tg)
	-- 设置操作信息，表示将要破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 执行攻击宣言时破坏效果，若目标怪兽存在则将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
