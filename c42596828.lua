--龍狸燈
-- 效果：
-- ①：1回合1次，从手卡丢弃1只幻龙族怪兽才能发动。这张卡的守备力直到回合结束时上升1000。这个效果在对方回合也能发动。
-- ②：攻击表示的这张卡和攻击表示怪兽进行战斗的伤害计算时才能发动1次。那次战斗用双方怪兽的守备力当作攻击力使用进行伤害计算。
function c42596828.initial_effect(c)
	-- ①：1回合1次，从手卡丢弃1只幻龙族怪兽才能发动。这张卡的守备力直到回合结束时上升1000。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42596828,0))  --"守备力上升"
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果①的发动条件：限定只能在伤害步骤且尚未进行伤害计算时发动，以符合“这个效果在对方回合也能发动”的时点限制，并避免在伤害计算时及之后发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c42596828.defcost)
	e1:SetOperation(c42596828.defop)
	c:RegisterEffect(e1)
	-- ②：攻击表示的这张卡和攻击表示怪兽进行战斗的伤害计算时才能发动1次。那次战斗用双方怪兽的守备力当作攻击力使用进行伤害计算。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42596828,1))  --"使用守备力进行伤害计算"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(c42596828.atkcon)
	e2:SetCost(c42596828.atkcost)
	e2:SetOperation(c42596828.atkop)
	c:RegisterEffect(e2)
end
-- 定义效果①的代价筛选条件：手卡中可以丢弃且种族为幻龙族的怪兽，才能作为这张卡发动效果的代价。
function c42596828.defcostfilter(c)
	return c:IsDiscardable() and c:IsRace(RACE_WYRM)
end
-- 效果①的代价处理函数：先确认手卡中存在符合条件的幻龙族怪兽，若满足则从手卡丢弃1只幻龙族怪兽作为发动代价。
function c42596828.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手卡中是否存在至少1张可丢弃的幻龙族怪兽，若不存在则无法支付代价，效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c42596828.defcostfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：让玩家tp从手卡选择并丢弃1只满足条件的幻龙族怪兽，丢弃原因标记为代价+丢弃。
	Duel.DiscardHand(tp,c42596828.defcostfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果①的处理：若这张卡仍表侧表示且与发动效果关联，则给它注册一个直到结束阶段守备力上升1000的效果。
function c42596828.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的守备力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件判定：本卡必须参与战斗，且战斗双方怪兽均为攻击表示、守备力大于0，并在伤害计算前满足“攻击表示的这张卡和攻击表示怪兽进行战斗的伤害计算时”的条件。
function c42596828.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家tp操控的战斗怪兽ac以及另一只战斗怪兽bc，用于判断本卡是否参战及双方怪兽的状态；若没有战斗对象则bc为nil。
	local ac,bc=Duel.GetBattleMonster(tp)
	return bc and (ac==c or bc==c)
		and ac:IsPosition(POS_ATTACK) and ac:IsDefenseAbove(0)
		and bc:IsPosition(POS_ATTACK) and bc:IsDefenseAbove(0)
end
-- 效果②的发动限制：通过flag标记检查本卡是否已在本次伤害计算中发动过②效果，未发动过才允许发动，发动后设置标记并在本次伤害计算阶段结束时重置，实现“伤害计算时才能发动1次”。
function c42596828.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(42596828)==0 end
	c:RegisterFlagEffect(42596828,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果②的处理：获取攻击怪兽和攻击对象，若它们仍与本次战斗相关，则分别给双方怪兽设置本次伤害计算中攻击力替换为各自守备力的效果，使该次战斗用守备力当作攻击力进行伤害计算。
function c42596828.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗的攻击怪兽，用于后续给它附加用守备力代替攻击力进行伤害计算的效果。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的攻击对象（被攻击怪兽），用于后续给它附加用守备力代替攻击力进行伤害计算的效果；直接攻击时可能为nil。
	local d=Duel.GetAttackTarget()
	if a:IsRelateToBattle() and d and d:IsRelateToBattle() then
		-- 那次战斗用双方怪兽的守备力当作攻击力使用进行伤害计算。
		local ea=Effect.CreateEffect(c)
		ea:SetType(EFFECT_TYPE_SINGLE)
		ea:SetCode(EFFECT_SET_BATTLE_ATTACK)
		ea:SetReset(RESET_PHASE+PHASE_DAMAGE)
		ea:SetValue(a:GetDefense())
		a:RegisterEffect(ea,true)
		-- 那次战斗用双方怪兽的守备力当作攻击力使用进行伤害计算。
		local ed=Effect.CreateEffect(c)
		ed:SetType(EFFECT_TYPE_SINGLE)
		ed:SetCode(EFFECT_SET_BATTLE_ATTACK)
		ed:SetReset(RESET_PHASE+PHASE_DAMAGE)
		ed:SetValue(d:GetDefense())
		d:RegisterEffect(ed,true)
	end
end
