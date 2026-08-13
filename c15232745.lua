--No.1 ゲート・オブ・ヌメロン－エーカム
-- 效果：
-- 1星怪兽×3
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时，把这张卡1个超量素材取除才能发动。自己场上的全部「源数」怪兽的攻击力直到回合结束时变成2倍。
function c15232745.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续，可用3只1星怪兽作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,1,3)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时，把这张卡1个超量素材取除才能发动。自己场上的全部「源数」怪兽的攻击力直到回合结束时变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15232745,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCost(c15232745.atkcost)
	e2:SetCondition(c15232745.atkcon)
	e2:SetTarget(c15232745.atktg)
	e2:SetOperation(c15232745.atkop)
	c:RegisterEffect(e2)
end
-- 在全局xyz_number表中登记这张卡的No编号为1，用于识别「No.1 源数之门-壹」的序号（配合相关联动判定）。
aux.xyz_number[15232745]=1
-- 效果发动代价：判定并取除这张卡的1个超量素材（以代价方式移除），用于支付效果发动费用。
function c15232745.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动条件：这张卡与对方怪兽进行过战斗（带有STATUS_OPPO_BATTLE状态），且仍与本次战斗关联（未离场导致关系重置）。
function c15232745.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 卡片筛选条件：表侧表示且属于「源数」系列的怪兽。
function c15232745.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14a)
end
-- 效果发动前的目标判定：确认自己场上存在至少1只表侧表示的「源数」怪兽，以满足发动条件（不取对象，处理时选取全部）。
function c15232745.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，检查自己场上是否存在至少1只满足条件的「源数」怪兽；存在则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c15232745.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理时：获取自己场上全部表侧「源数」怪兽，逐只使其攻击力变成当前攻击力的2倍，效果持续到回合结束且不能被无效。
function c15232745.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且属于「源数」系列的怪兽群体，作为后续攻击力变更处理的对象集合。
	local g=Duel.GetMatchingGroup(c15232745.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部「源数」怪兽的攻击力直到回合结束时变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
