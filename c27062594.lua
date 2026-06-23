--運命の扉
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能把这张卡发动。那次攻击无效。那之后，这张卡变成效果怪兽（恶魔族·光·1星·攻/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果让这张卡已特殊召唤的场合，自己准备阶段从自己墓地把「希望皇 霍普」怪兽任意数量除外才能发动（同名卡最多1张）。给与对方除外数量×500伤害，这张卡的攻击力上升那次伤害的数值。
function c27062594.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能把这张卡发动。那次攻击无效。那之后，这张卡变成效果怪兽（恶魔族·光·1星·攻/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c27062594.condition)
	e1:SetTarget(c27062594.target)
	e1:SetOperation(c27062594.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果让这张卡已特殊召唤的场合，自己准备阶段从自己墓地把「希望皇 霍普」怪兽任意数量除外才能发动（同名卡最多1张）。给与对方除外数量×500伤害，这张卡的攻击力上升那次伤害的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27062594,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c27062594.damcon)
	e2:SetCost(c27062594.damcost)
	e2:SetTarget(c27062594.damtg)
	e2:SetOperation(c27062594.damop)
	c:RegisterEffect(e2)
end
-- 判断是否为对方怪兽的直接攻击宣言
function c27062594.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽控制者为对方且攻击目标为空
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 判断是否满足特殊召唤条件
function c27062594.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 判断场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤此卡为效果怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,27062594,0,TYPES_EFFECT_TRAP_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_LIGHT) end
	-- 设置特殊召唤此卡为效果怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果发动后的操作
function c27062594.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击
	if not Duel.NegateAttack() then return end
	-- 中断当前效果处理
	Duel.BreakEffect()
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e)
		-- 判断是否可以将此卡特殊召唤为效果怪兽
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,27062594,0,TYPES_EFFECT_TRAP_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 判断是否为特殊召唤且为己方准备阶段
function c27062594.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断召唤方式为特殊召唤且为己方回合
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and Duel.GetTurnPlayer()==tp
end
-- 过滤墓地中的「希望皇 霍普」怪兽
function c27062594.cfilter(c)
	return c:IsSetCard(0x107f) and c:IsAbleToRemoveAsCost()
end
-- 设置发动效果的费用
function c27062594.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的墓地卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c27062594.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取满足条件的墓地卡片组
	local g=Duel.GetMatchingGroup(c27062594.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的卡片组（卡名各不相同）
	local rg=g:SelectSubGroup(tp,aux.dncheck,false,1,g:GetCount())
	-- 将选中的卡片除外作为费用
	local ct=Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(ct)
end
-- 设置发动效果的目标和伤害值
function c27062594.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害值为除外卡片数乘以500
	Duel.SetTargetParam(e:GetLabel()*500)
	-- 设置发动效果的伤害操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel()*500)
end
-- 处理伤害效果并提升攻击力
function c27062594.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	local val=Duel.Damage(p,d,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将攻击力提升与造成伤害相同的数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
