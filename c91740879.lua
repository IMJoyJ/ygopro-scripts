--ご隠居の大釜
-- 效果：
-- ①：作为这张卡的发动时的效果处理，给这张卡放置1个指示物。
-- ②：自己准备阶段发动。给这张卡放置1个指示物。
-- ③：1回合1次，可以从以下效果选择1个发动。
-- ●自己回复这张卡的指示物数量×500基本分。
-- ●给与对方这张卡的指示物数量×300伤害。
function c91740879.initial_effect(c)
	c:EnableCounterPermit(0x55)
	-- ①：作为这张卡的发动时的效果处理，给这张卡放置1个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c91740879.target)
	e1:SetOperation(c91740879.activate)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段发动。给这张卡放置1个指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91740879,0))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c91740879.ctcon)
	e2:SetTarget(c91740879.cttg)
	e2:SetOperation(c91740879.activate)
	c:RegisterEffect(e2)
	-- ③：1回合1次，可以从以下效果选择1个发动。●自己回复这张卡的指示物数量×500基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91740879,1))  --"基本分回复"
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetTarget(c91740879.rectg)
	e3:SetOperation(c91740879.recop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(91740879,2))  --"基本分伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetTarget(c91740879.damtg)
	e4:SetOperation(c91740879.damop)
	c:RegisterEffect(e4)
end
-- 卡片发动时的效果处理（放置指示物）的发动检测函数
function c91740879.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检测是否能向这张卡放置1个指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x55,1,e:GetHandler()) end
	-- 设置操作信息：放置1个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x55)
end
-- 卡片发动以及准备阶段效果处理的执行函数，向自身放置1个指示物
function c91740879.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x55,1)
	end
end
-- 准备阶段放置指示物效果的发动条件函数
function c91740879.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段放置指示物效果的发动检测与操作信息设置函数
function c91740879.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：放置1个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x55)
end
-- 回复基本分效果的发动检测与操作信息设置函数
function c91740879.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetCounter(0x55)
	if chk==0 then return ct>0 end
	-- 向对方玩家提示自己选择了发动“回复基本分”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：使自己回复指示物数量×500的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*500)
end
-- 回复基本分效果的执行函数
function c91740879.recop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x55)
	-- 获取当前连锁设定的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if c:IsRelateToEffect(e) and ct>0 then
		-- 以效果原因使对象玩家回复指示物数量×500的基本分
		Duel.Recover(p,ct*500,REASON_EFFECT)
	end
end
-- 给予伤害效果的发动检测与操作信息设置函数
function c91740879.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetCounter(0x55)
	if chk==0 then return ct>0 end
	-- 向对方玩家提示自己选择了发动“给予伤害”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息：给予对方指示物数量×300的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- 给予伤害效果的执行函数
function c91740879.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x55)
	-- 获取当前连锁设定的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if c:IsRelateToEffect(e) and ct>0 then
		-- 以效果原因给予对象玩家指示物数量×300的伤害
		Duel.Damage(p,ct*300,REASON_EFFECT)
	end
end
