--死製棺サルコファガス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡被和对方怪兽的战斗破坏时才能发动。得到那只对方怪兽的控制权。那只怪兽变成不死族，攻击力·守备力变成0。
-- ②：这张卡在墓地存在的状态，自己的不死族怪兽被和对方怪兽的战斗破坏时，把这张卡除外才能发动。得到那只对方怪兽的控制权。那只怪兽变成不死族，攻击力·守备力变成0。
local s,id,o=GetID()
-- 注册两个触发效果，分别对应卡片效果①和②
function s.initial_effect(c)
	-- ①：这张卡被和对方怪兽的战斗破坏时才能发动。得到那只对方怪兽的控制权。那只怪兽变成不死族，攻击力·守备力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的不死族怪兽被和对方怪兽的战斗破坏时，把这张卡除外才能发动。得到那只对方怪兽的控制权。那只怪兽变成不死族，攻击力·守备力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition2)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 设置效果目标为对方战斗中的怪兽，并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方战斗中的怪兽
	local bc=Duel.GetBattleMonster(1-tp)
	if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsControlerCanBeChanged() end
	-- 将目标怪兽设置为连锁处理对象
	Duel.SetTargetCard(bc)
	-- 设置操作信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,bc,1,0,0)
end
-- 执行效果操作，获得目标怪兽控制权并将其变为不死族，攻击力守备力归零
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁处理的目标怪兽
	local bc=Duel.GetFirstTarget()
	if bc:IsRelateToBattle() then
		-- 获得目标怪兽的控制权
		Duel.GetControl(bc,tp)
		-- 将目标怪兽种族变为不死族
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_ZOMBIE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(0)
		bc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
		bc:RegisterEffect(e3)
	end
end
-- 过滤条件函数，用于判断是否为己方不死族怪兽被战斗破坏
function s.cfilter(c,tp)
	return c:GetPreviousRaceOnField()==RACE_ZOMBIE and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
end
-- 条件函数，判断是否满足效果②发动条件
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then return false end
	local ac=eg:Filter(s.cfilter,nil,tp):GetFirst()
	if not ac then return false end
	local bc=ac:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp)
end
-- 设置效果目标为对方战斗中的怪兽，并设置操作信息
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsControlerCanBeChanged() end
	-- 将目标怪兽设置为连锁处理对象
	Duel.SetTargetCard(bc)
	-- 设置操作信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,bc,1,0,0)
end
