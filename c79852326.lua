--死霊ゾーマ
-- 效果：
-- ①：这张卡发动后变成效果怪兽（不死族·暗·4星·攻1800/守500）在怪兽区域守备表示特殊召唤。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果特殊召唤的这张卡被战斗破坏的场合发动。给与对方让这张卡破坏的怪兽的攻击力数值的伤害。
function c79852326.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（不死族·暗·4星·攻1800/守500）在怪兽区域守备表示特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c79852326.target)
	e1:SetOperation(c79852326.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果特殊召唤的这张卡被战斗破坏的场合发动。给与对方让这张卡破坏的怪兽的攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79852326,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c79852326.damcon)
	e2:SetTarget(c79852326.damtg)
	e2:SetOperation(c79852326.damop)
	c:RegisterEffect(e2)
end
-- 检查发动条件，包括怪兽区域空位数以及是否能将该卡作为特定属性、种族的怪兽特殊召唤
function c79852326.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自身怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将该卡作为不死族·暗属性·4星·攻1800/守500的效果怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,79852326,0,TYPES_EFFECT_TRAP_MONSTER,1800,500,4,RACE_ZOMBIE,ATTRIBUTE_DARK) end
	-- 设置连锁的操作信息，表示该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身添加怪兽属性，并以守备表示特殊召唤到怪兽区域
function c79852326.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查是否满足特殊召唤该怪兽的条件，若不满足则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,79852326,0,TYPES_EFFECT_TRAP_MONSTER,1800,500,4,RACE_ZOMBIE,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将自身以表侧守备表示特殊召唤，并标记为自身效果特殊召唤
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP_DEFENSE)
end
-- 触发条件：检查自身是否是由自身效果特殊召唤，并且是被战斗破坏
function c79852326.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and c:IsReason(REASON_BATTLE)
end
-- 效果发动准备：获取战斗破坏自身的怪兽的攻击力，并将其设为伤害数值，设置对方玩家为效果对象
function c79852326.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为伤害数值（破坏该卡的怪兽的攻击力）
	Duel.SetTargetParam(dam)
	-- 设置连锁的操作信息，表示该效果包含给与对方特定数值伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理：获取保存的对象玩家和伤害数值，给与对方该数值的效果伤害
function c79852326.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
