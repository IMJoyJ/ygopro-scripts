--補充部隊
-- 效果：
-- ①：每次对方怪兽的攻击或者对方的效果让自己受到1000以上的伤害发动。那次伤害每有1000，自己从卡组抽1张。
function c28486799.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：每次对方怪兽的攻击或者对方的效果让自己受到1000以上的伤害发动。那次伤害每有1000，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c28486799.drcon)
	e2:SetTarget(c28486799.drtg)
	e2:SetOperation(c28486799.drop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否满足发动条件，即自己受到伤害且伤害来源为对方，伤害值大于等于1000，并且是对方怪兽攻击或对方效果造成的伤害。
function c28486799.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and rp==1-tp and ev>=1000
		-- 规则层面作用：当伤害由对方怪兽攻击造成时，检查该攻击怪兽是否控制者为对方。
		and (re or (Duel.GetAttacker() and Duel.GetAttacker():IsControler(1-tp)))
end
-- 规则层面作用：设置效果的目标和参数，计算应抽取的卡牌数量，并准备后续操作信息。
function c28486799.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=math.floor(ev/1000)
	if chk==0 then return true end
	-- 规则层面作用：设置当前连锁效果的目标玩家为效果使用者。
	Duel.SetTargetPlayer(tp)
	-- 规则层面作用：设置当前连锁效果的目标参数为根据伤害计算出的抽卡数量。
	Duel.SetTargetParam(d)
	-- 规则层面作用：设置当前连锁效果的操作信息，包括抽卡类别、目标玩家及抽卡数量。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,d)
end
-- 规则层面作用：执行效果操作，根据连锁信息获取目标玩家和抽卡数量并执行抽卡。
function c28486799.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：从当前处理的连锁中获取目标玩家和目标参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if d>0 then
		-- 规则层面作用：让指定玩家按照目标参数数量从卡组抽卡，原因设为效果。
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
