--死製棺サルコファガス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡被和对方怪兽的战斗破坏时才能发动。得到那只对方怪兽的控制权。那只怪兽变成不死族，攻击力·守备力变成0。
-- ②：这张卡在墓地存在的状态，自己的不死族怪兽被和对方怪兽的战斗破坏时，把这张卡除外才能发动。得到那只对方怪兽的控制权。那只怪兽变成不死族，攻击力·守备力变成0。
local s,id,o=GetID()
-- 注册①效果和②效果：①为自身被对方怪兽战斗破坏时发动的诱发效果；②为墓地存在时己方不死族怪兽被对方怪兽战斗破坏时除外自身发动的诱发效果，且②每回合限1次。
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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的状态，自己的不死族怪兽被和对方怪兽的战斗破坏时，把这张卡除外才能发动。得到那只对方怪兽的控制权。那只怪兽变成不死族，攻击力·守备力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition2)
	-- 设置②效果的发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件与取对象处理：检查对方战斗怪兽是否仍与战斗相关且控制权可变更，若是则将其设为对象并登记获得控制权的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取与这张卡战斗的对方怪兽（即对方操控的战斗怪兽）。
	local bc=Duel.GetBattleMonster(1-tp)
	if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsControlerCanBeChanged() end
	-- 将该战斗怪兽设置为当前效果的对象，建立与效果的关联。
	Duel.SetTargetCard(bc)
	-- 登记连锁信息：本效果将变更对象怪兽的控制权，数量为1，供后续时点判定使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,bc,1,0,0)
end
-- 效果处理：取得对象怪兽，若其仍与战斗相关则获得其控制权，并使其变为不死族、攻击力和守备力变成0（效果随怪兽离场等标准情况重置）。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出效果发动时设定的对象怪兽（即被战斗破坏的这张卡的战斗对象）。
	local bc=Duel.GetFirstTarget()
	if bc:IsRelateToBattle() then
		-- 获得对象怪兽的控制权，将其转移到我方场上。
		Duel.GetControl(bc,tp)
		-- 那只怪兽变成不死族。
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
-- 过滤函数：判断怪兽是否在场上时为不死族、是否因战斗破坏、以及是否之前由己方控制。
function s.cfilter(c,tp)
	return c:GetPreviousRaceOnField()==RACE_ZOMBIE and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
end
-- ②效果发动条件：本卡自身不在本次被战斗破坏的怪兽之中，且存在己方不死族怪兽被对方怪兽战斗破坏，记录其战斗对象（对方怪兽）并确认该对象控制权可变更。
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then return false end
	local ac=eg:Filter(s.cfilter,nil,tp):GetFirst()
	if not ac then return false end
	local bc=ac:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp)
end
-- ②效果的对象选择：取条件阶段记录的战斗对象，若其仍与战斗相关且控制权可变更，则将其设为对象并登记获得控制权的操作信息。
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsControlerCanBeChanged() end
	-- 将记录的战斗对象（对方怪兽）设置为当前效果的对象。
	Duel.SetTargetCard(bc)
	-- 登记连锁信息：本效果将变更对象怪兽的控制权，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,bc,1,0,0)
end
