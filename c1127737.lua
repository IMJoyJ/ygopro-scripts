--異次元の古戦場－サルガッソ
-- 效果：
-- 每次超量召唤成功，那个玩家受到500分伤害。此外，控制超量怪兽的玩家各自在每次自己的结束阶段受到500分伤害。
function c1127737.initial_effect(c)
	-- 卡片效果：每次超量召唤成功，那个玩家受到500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果作用：当有超量怪兽特殊召唤成功时，对召唤玩家造成500分伤害。
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
	-- 效果作用：在结束阶段时，控制超量怪兽的玩家受到500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c1127737.damcon2)
	e2:SetOperation(c1127737.damop2)
	c:RegisterEffect(e2)
end
-- 判断条件：确认特殊召唤的怪兽是否为超量召唤
function c1127737.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 设置目标：设定伤害对象为召唤玩家
function c1127737.damtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置目标玩家：将伤害对象设为召唤玩家
	Duel.SetTargetPlayer(eg:GetFirst():GetSummonPlayer())
	-- 设置伤害值：将伤害值设为500
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息：设定伤害效果的处理对象和伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,eg:GetFirst():GetSummonPlayer(),500)
end
-- 效果处理：执行伤害处理
function c1127737.damop1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 获取连锁信息：获取连锁中设定的目标玩家和伤害值
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 判断玩家是否被免疫：检查目标玩家是否受到免疫效果影响
		if not Duel.IsPlayerAffectedByEffect(p,37511832) then
			-- 造成伤害：对目标玩家造成指定伤害
			Duel.Damage(p,d,REASON_EFFECT)
		end
	end
end
-- 过滤函数：用于判断场上的超量怪兽
function c1127737.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 判断条件：确认当前回合玩家是否控制有超量怪兽
function c1127737.damcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上有无超量怪兽：判断当前回合玩家场上有无超量怪兽
	return Duel.IsExistingMatchingCard(c1127737.cfilter,Duel.GetTurnPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 效果处理：执行结束阶段伤害处理
function c1127737.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家：获取当前回合玩家
	local p=Duel.GetTurnPlayer()
	-- 判断玩家是否被免疫：检查目标玩家是否受到免疫效果影响
	if not Duel.IsPlayerAffectedByEffect(p,37511832) then
		-- 提示发动动画：显示卡片发动动画
		Duel.Hint(HINT_CARD,0,1127737)
		-- 造成伤害：对当前回合玩家造成500分伤害
		Duel.Damage(p,500,REASON_EFFECT)
	end
end
