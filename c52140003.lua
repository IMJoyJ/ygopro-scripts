--爆弾ウニ－ボム・アーチン－
-- 效果：
-- 对方把陷阱卡发动时才能发动。自己的准备阶段时，对方场上有陷阱卡表侧表示存在的场合，给与对方基本分1000分伤害。发动后第3次的自己的结束阶段时这张卡送去墓地。
function c52140003.initial_effect(c)
	-- “对方把陷阱卡发动时才能发动。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c52140003.condition)
	e1:SetTarget(c52140003.target)
	c:RegisterEffect(e1)
	-- “自己的准备阶段时，对方场上有陷阱卡表侧表示存在的场合，给与对方基本分1000分伤害。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52140003,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c52140003.damcon)
	e2:SetTarget(c52140003.damtg)
	e2:SetOperation(c52140003.damop)
	c:RegisterEffect(e2)
end
-- 检查发动条件：当前连锁中对方玩家发动了陷阱卡的发动效果（EFFECT_TYPE_ACTIVATE），满足时本卡才能发动。
function c52140003.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==1-tp
end
-- 发动成功时的处理：为这张卡注册一个不可被无效且无视免疫的持续效果，用于在每个结束阶段进行计数；同时把这张卡的回合计数器初始化为0。
function c52140003.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- “发动后第3次的自己的结束阶段时这张卡送去墓地。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c52140003.tgcon)
	e1:SetOperation(c52140003.tgop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	c:SetTurnCounter(0)
end
-- 过滤函数：用于判断卡片是否为表侧表示且为陷阱卡。
function c52140003.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP)
end
-- 伤害效果的诱发条件：当前是自己的准备阶段，且对方场上有表侧表示的陷阱卡存在。
function c52140003.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是自己，并且对方场上有表侧表示的陷阱卡存在。
	return tp==Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(c52140003.cfilter,tp,0,LOCATION_ONFIELD,1,nil)
end
-- 伤害效果的发动目标处理：将对象玩家设为对方，伤害值设为1000，并登记造成1000点伤害的操作信息。
function c52140003.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本连锁效果的对象玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将本连锁效果的对象参数设置为1000（即伤害数值）。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：设定伤害分类，表示效果处理时将给对方造成1000点伤害，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 伤害效果的处理：先确认对方场上仍有表侧表示陷阱卡，否则效果不处理；然后根据连锁信息中保存的对象玩家和伤害数值，给对方造成1000点效果伤害。
function c52140003.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 若对方场上不存在表侧表示的陷阱卡，则本效果不进行伤害处理。
	if not Duel.IsExistingMatchingCard(c52140003.cfilter,tp,0,LOCATION_ONFIELD,1,nil) then return end
	-- 获取当前连锁中通过SetTargetPlayer/SetTargetParam保存的对象玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给对象玩家p造成d点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 计数效果的诱发条件：当前是自己的结束阶段。
function c52140003.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否是自己（即确认是自己的结束阶段）。
	return Duel.GetTurnPlayer()==tp
end
-- 计数效果处理：将这张卡的回合计数器加1；当累计达到3时，把这张卡送去墓地（对应发动后第3次自己的结束阶段）。
function c52140003.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	c:SetTurnCounter(ct+1)
	if ct+1>=3 then
		-- 将这张卡送去墓地。
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
