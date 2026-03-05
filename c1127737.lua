--異次元の古戦場－サルガッソ
-- 效果：
-- 每次超量召唤成功，那个玩家受到500分伤害。此外，控制超量怪兽的玩家各自在每次自己的结束阶段受到500分伤害。
function c1127737.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：每次超量召唤成功，那个玩家受到500分伤害。
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
	-- 效果原文：此外，控制超量怪兽的玩家各自在每次自己的结束阶段受到500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c1127737.damcon2)
	e2:SetOperation(c1127737.damop2)
	c:RegisterEffect(e2)
end
-- 判断触发效果的条件：确保召唤的是超量怪兽
function c1127737.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 设置效果的目标玩家和参数，并注册操作信息以准备造成伤害
function c1127737.damtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁效果的目标玩家为超量召唤的玩家
	Duel.SetTargetPlayer(eg:GetFirst():GetSummonPlayer())
	-- 设置连锁效果的目标参数为500点伤害
	Duel.SetTargetParam(500)
	-- 注册操作信息，指定将要造成500点伤害给特定玩家
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,eg:GetFirst():GetSummonPlayer(),500)
end
-- 执行伤害效果：若场地卡存在且目标玩家未被免疫，则造成伤害
function c1127737.damop1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 从当前连锁中获取目标玩家和伤害值
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 检查目标玩家是否被免疫效果影响（如王家长眠之谷）
		if not Duel.IsPlayerAffectedByEffect(p,37511832) then
			-- 对目标玩家造成指定点数的伤害
			Duel.Damage(p,d,REASON_EFFECT)
		end
	end
end
-- 过滤函数：检查场上是否有表侧表示的超量怪兽
function c1127737.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 判断结束阶段触发条件：当前回合玩家在场上存在至少1只超量怪兽
function c1127737.damcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家在场上是否存在至少1只超量怪兽
	return Duel.IsExistingMatchingCard(c1127737.cfilter,Duel.GetTurnPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 执行结束阶段伤害效果：若当前回合玩家未被免疫，则造成500点伤害
function c1127737.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家
	local p=Duel.GetTurnPlayer()
	-- 检查当前回合玩家是否被免疫效果影响
	if not Duel.IsPlayerAffectedByEffect(p,37511832) then
		-- 向玩家发送卡片发动提示动画
		Duel.Hint(HINT_CARD,0,1127737)
		-- 对当前回合玩家造成500点伤害
		Duel.Damage(p,500,REASON_EFFECT)
	end
end
