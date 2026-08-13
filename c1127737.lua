--異次元の古戦場－サルガッソ
-- 效果：
-- 每次超量召唤成功，那个玩家受到500分伤害。此外，控制超量怪兽的玩家各自在每次自己的结束阶段受到500分伤害。
function c1127737.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次超量召唤成功，那个玩家受到500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1127737,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c1127737.damcon1)
	e2:SetTarget(c1127737.damtg1)
	e2:SetOperation(c1127737.damop1)
	c:RegisterEffect(e2)
	-- 此外，控制超量怪兽的玩家各自在每次自己的结束阶段受到500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c1127737.damcon2)
	e2:SetOperation(c1127737.damop2)
	c:RegisterEffect(e2)
end
-- 超量召唤成功时，检查成功召唤的怪兽是否为超量召唤，以此作为第一段效果的发动条件。
function c1127737.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 第一段伤害效果发动时，将伤害对象玩家设为超量召唤成功的玩家，伤害值设为500，并登记效果处理信息，使该伤害作为效果伤害被正确识别。
function c1127737.damtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为超量召唤成功的那只怪兽的召唤玩家，即接下来要受到伤害的玩家。
	Duel.SetTargetPlayer(eg:GetFirst():GetSummonPlayer())
	-- 将当前连锁的伤害参数设定为500，表示本次效果给予的伤害数值为500。
	Duel.SetTargetParam(500)
	-- 登记本次操作的伤害信息：对超量召唤成功的玩家造成500点效果伤害，用于后续时点检测与连锁处理。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,eg:GetFirst():GetSummonPlayer(),500)
end
-- 处理第一段伤害：先确认场地上的这张卡仍与效果关联，再读取连锁中记录的对象玩家和伤害数值，若该玩家不受“死域海的灯塔”的伤害无效化效果影响，则给予其对应数值的效果伤害。
function c1127737.damop1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 从当前连锁信息中取出之前记录的对象玩家和伤害参数，分别存入变量p和d，供后续判断与造成伤害使用。
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 判断玩家p是否没有被卡号37511832（死域海的灯塔）的效果影响；如果不受影响，才继续执行伤害处理。
		if not Duel.IsPlayerAffectedByEffect(p,37511832) then
			-- 以效果伤害的形式，给玩家p造成d点伤害。
			Duel.Damage(p,d,REASON_EFFECT)
		end
	end
end
-- 过滤条件：用于筛选场上表侧表示的超量怪兽，作为结束阶段伤害效果的条件判断依据。
function c1127737.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 结束阶段伤害效果的发动条件：当前回合玩家自己场上存在表侧表示的超量怪兽，即该玩家“控制超量怪兽”。
function c1127737.damcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家自己的主要怪兽区是否存在至少1张表侧表示的超量怪兽；存在则满足发动条件。
	return Duel.IsExistingMatchingCard(c1127737.cfilter,Duel.GetTurnPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 处理结束阶段伤害：以当前回合玩家为对象，若其不受“死域海的灯塔”的伤害无效化效果影响，则展示本卡发动动画，并给予该玩家500点效果伤害。
function c1127737.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家作为伤害对象，即“控制超量怪兽的玩家”。
	local p=Duel.GetTurnPlayer()
	-- 判断当前回合玩家是否没有被卡号37511832（死域海的灯塔）的效果影响；不受影响时才继续造成伤害。
	if not Duel.IsPlayerAffectedByEffect(p,37511832) then
		-- 向双方展示卡号1127737（异次元的古战场-死域海）的卡片动画，提示该卡的结束阶段伤害效果正在处理。
		Duel.Hint(HINT_CARD,0,1127737)
		-- 以效果伤害形式，给予当前回合玩家500点伤害。
		Duel.Damage(p,500,REASON_EFFECT)
	end
end
