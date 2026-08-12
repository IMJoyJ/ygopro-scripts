--折々の紙神
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。直到里出现为止进行投掷硬币。表出现的次数每有2次，自己抽1张。
-- ②：这张卡在怪兽区域存在的状态，每次自己·对方进行投掷硬币发动。那些投掷硬币让表出现的次数每有1次，各让这张卡的攻击力变成2倍来对应1次。
local s,id,o=GetID()
-- 初始化效果：注册①效果（起动效果，投硬币抽卡）、②效果（自定义事件诱发，攻击力翻倍）以及用于监听投硬币结果并触发②效果的两个辅助效果
function s.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。直到里出现为止进行投掷硬币。表出现的次数每有2次，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，每次自己·对方进行投掷硬币发动。那些投掷硬币让表出现的次数每有1次，各让这张卡的攻击力变成2倍来对应1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力翻倍"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡在怪兽区域存在的状态，每次自己·对方进行投掷硬币发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TOSS_COIN)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.coincon)
	e3:SetOperation(s.coinop)
	c:RegisterEffect(e3)
	-- ②：这张卡在怪兽区域存在的状态，每次自己·对方进行投掷硬币发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.countcon)
	e4:SetOperation(s.countop)
	c:RegisterEffect(e4)
end
-- ①效果的发动准备：检查玩家是否可以抽卡，并设置投硬币的操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp) end
	-- 设置操作信息，表明此效果包含投硬币的操作
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,0)
end
-- ①效果的处理：进行投硬币直到出现反面，并根据正面出现的次数让玩家抽卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 进行投掷硬币直到出现反面（-1表示直到出现反面为止）
	local res={Duel.TossCoin(tp,-1)}
	local heads=#res-1
	if heads>=5 then
		-- 如果正面次数大于等于5次，向对方玩家提示正面出现的次数
		Duel.Hint(HINT_NUMBER,1-tp,heads)
	end
	if heads>=2 then
		-- 自己抽卡，抽卡数量为正面次数除以2（向下取整）
		Duel.Draw(tp,heads//2,REASON_EFFECT)
	end
end
-- ②效果的发动准备：向对方玩家提示正面出现的次数
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示本次投硬币中正面出现的次数
	Duel.Hint(HINT_NUMBER,1-tp,ev)
end
-- ②效果的处理：根据正面出现的次数，将这张卡的攻击力翻倍对应次数
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if ev==0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=c:GetAttack()
		for i=1,ev do
			if atk<<1 <= 0x7fffffff then
				atk=atk<<1
			else
				break
			end
		end
		-- 各让这张卡的攻击力变成2倍来对应1次。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 检查投硬币事件是否未被无效
function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetCode()~=EVENT_TOSS_COIN_NEGATE
end
-- 统计本次投硬币中正面出现的次数，并将其作为Flag的Label记录在自身卡片上
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前投硬币的结果
	local res={Duel.GetCoinResult()}
	local heads=0
	for _,coin in ipairs(res) do
		if coin==1 then
			heads=heads+1
		end
	end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,heads)
end
-- 检查自身是否记录了投硬币正面次数的Flag
function s.countcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 在连锁处理结束时，累加所有记录的正面次数，重置Flag，并触发自定义事件
function s.countop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res={c:GetFlagEffectLabel(id)}
	local heads=0
	for _,count in ipairs(res) do
		heads=heads+count
	end
	c:ResetFlagEffect(id)
	-- 触发自定义单体事件，将累加的正面次数作为参数传递给②效果
	Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,re,r,rp,ep,heads)
end
