--ヴォルカニック・デビル
-- 效果：
-- 这张卡不能通常召唤。把自己场上1张表侧表示的「烈焰加农炮-三叉戟式」送去墓地的场合可以特殊召唤。
-- ①：对方战斗阶段中，可以攻击的对方的攻击表示怪兽必须向这张卡作出攻击。
-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。对方场上的怪兽全部破坏，给与对方破坏数量×500伤害。
function c32543380.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上1张表侧表示的「烈焰加农炮-三叉戟式」送去墓地的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c32543380.spcon)
	e1:SetTarget(c32543380.sptg)
	e1:SetOperation(c32543380.spop)
	c:RegisterEffect(e1)
	-- ①：对方战斗阶段中，可以攻击的对方的攻击表示怪兽必须向这张卡作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c32543380.bpcon)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(c32543380.atklimit)
	c:RegisterEffect(e3)
	-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。对方场上的怪兽全部破坏，给与对方破坏数量×500伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(32543380,0))  --"对方场上的怪兽全部破坏"
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCondition(c32543380.descon)
	e5:SetTarget(c32543380.destg)
	e5:SetOperation(c32543380.desop)
	c:RegisterEffect(e5)
end
-- 特殊召唤的cost素材筛选：目标必须为表侧表示、卡名为「烈焰加农炮-三叉戟式」且可以作为cost送去墓地。
function c32543380.spfilter(c)
	return c:IsFaceup() and c:IsCode(21420702) and c:IsAbleToGraveAsCost()
end
-- 判定这张卡能否通过自身效果特殊召唤：需要自己的主要怪兽区有空格，且自己场上存在满足spfilter的「烈焰加农炮-三叉戟式」作为代价。
function c32543380.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己的主要怪兽区是否有可用的空格，用于确定能否进行特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张满足spfilter条件的「烈焰加农炮-三叉戟式」，作为特殊召唤所需送去墓地的cost。
		and Duel.IsExistingMatchingCard(c32543380.spfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤手续中的cost选择：从符合条件的「烈焰加农炮-三叉戟式」中选择1张，并存入效果的标签；没有选择则特殊召唤不进行。
function c32543380.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足spfilter条件的「烈焰加农炮-三叉戟式」，作为特殊召唤cost的候选集合。
	local g=Duel.GetMatchingGroup(c32543380.spfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 发送选择提示，让玩家从候选中选择1张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理阶段：将之前选择好的「烈焰加农炮-三叉戟式」送去墓地，以完成特殊召唤的代价。
function c32543380.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的「烈焰加农炮-三叉戟式」送去墓地，作为这次特殊召唤手续所需的cost。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
-- ①效果的适用条件：仅在对方回合的战斗阶段内，强制攻击效果才会生效。
function c32543380.bpcon(e)
	-- 判断当前是否为对方回合的战斗阶段（即对方的战斗阶段）。
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer()) and Duel.IsBattlePhase()
end
-- 指定对方怪兽必须攻击的目标为这张「火山恶魔」本身。
function c32543380.atklimit(e,c)
	return c==e:GetHandler()
end
-- ②效果的触发条件：本卡因战斗破坏怪兽并将其送去墓地，并且本卡仍与本次战斗相关且表侧表示，被破坏的是怪兽。
function c32543380.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗的攻击怪兽（战斗阶段进行攻击的怪兽）。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的攻击目标（被攻击的怪兽）。
	local d=Duel.GetAttackTarget()
	if a~=c then d=a end
	return c:IsRelateToBattle() and c:IsFaceup()
		and d and d:IsLocation(LOCATION_GRAVE) and d:IsType(TYPE_MONSTER)
end
-- 设定②效果的处理信息：将对方场上全部怪兽记录为破坏影响对象（实际不取对象），并登记对应数量×500的伤害信息。
function c32543380.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的全部怪兽，作为可能被破坏的全体对象（不取对象）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 登记破坏效果的操作信息：破坏对象为对方场上全部怪兽，数量为当前怪兽总数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 登记伤害效果的操作信息：预计给与对方破坏数量×500的伤害，具体伤害值在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- ②效果的实际处理：破坏对方场上的全部怪兽，然后根据实际破坏数量给与对方伤害。
function c32543380.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上的全部怪兽（以当前场上实际存在的怪兽为准）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因破坏对方场上全部怪兽，返回实际被破坏的数量ct。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 给与对方玩家ct×500的效果伤害（ct为实际被破坏的怪兽数量）。
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
