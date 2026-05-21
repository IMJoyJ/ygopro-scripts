--テスタメント・パラディオン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●这个回合，对方不能对应自己的「圣像骑士」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
-- ●自己的「圣像骑士」连接怪兽战斗破坏对方怪兽的伤害计算后才能发动。自己从卡组抽出那只自己怪兽的连接标记的数量。
function c87497553.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。●这个回合，对方不能对应自己的「圣像骑士」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。●自己的「圣像骑士」连接怪兽战斗破坏对方怪兽的伤害计算后才能发动。自己从卡组抽出那只自己怪兽的连接标记的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_BATTLED,TIMINGS_CHECK_MONSTER+TIMING_BATTLED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,87497553+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c87497553.target)
	e1:SetOperation(c87497553.activate)
	c:RegisterEffect(e1)
end
-- 检查当前是否满足自己的「圣像骑士」连接怪兽战斗破坏对方怪兽的伤害计算后这一条件，并返回该连接怪兽
function c87497553.battlecheck(tp)
	-- 检查当前是否是伤害计算后时点
	if not Duel.CheckEvent(EVENT_BATTLED) then return false end
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	local res=a:IsType(TYPE_LINK) and a:IsSetCard(0x116)
		-- 检查被攻击怪兽是否被战斗破坏，且自己是否可以进行对应数量的抽卡
		and d:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsPlayerCanDraw(tp,a:GetLink())
	return res,a
end
-- 卡片发动时的效果选择与目标确认处理
function c87497553.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前是否不处于伤害步骤
	local b1=Duel.GetCurrentPhase()~=PHASE_DAMAGE
	local b2,a=c87497553.battlecheck(tp)
	if chk==0 then return b1 or b2 end
	if b1 then
		e:SetLabel(1)
		-- 让玩家选择发动第一个效果（不能对应发动）
		Duel.SelectOption(tp,aux.Stringid(87497553,0))  --"不能对应发动"
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	else
		e:SetLabel(2)
		-- 让玩家选择发动第二个效果（抽卡）
		Duel.SelectOption(tp,aux.Stringid(87497553,1))  --"抽卡"
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
		e:SetLabelObject(a)
		-- 设置当前连锁的目标玩家为自己
		Duel.SetTargetPlayer(tp)
		-- 设置当前连锁的目标参数为该连接怪兽的连接标记数量
		Duel.SetTargetParam(a:GetLink())
		-- 设置当前连锁的操作信息为抽卡，数量为该连接怪兽的连接标记数量
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,a:GetLink())
	end
end
-- 卡片发动时的效果处理
function c87497553.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- ●这个回合，对方不能对应自己的「圣像骑士」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。 / 自己从卡组抽出那只自己怪兽的连接标记的数量。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c87497553.actop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将限制对方连锁的永续型效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	else
		-- 获取当前连锁设定的目标玩家和抽卡数量
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		local a=e:GetLabelObject()
		if a:IsRelateToBattle() then
			-- 让目标玩家因效果从卡组抽出该连接怪兽连接标记数量的卡
			Duel.Draw(p,a:GetLink(),REASON_EFFECT)
		end
	end
end
-- 在有效果发动时触发的辅助操作，用于检测是否是自己的「圣像骑士」怪兽发动效果并限制对方连锁
function c87497553.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(0x116) and ep==tp then
		-- 设定连锁限制，使对方不能对应发动效果
		Duel.SetChainLimit(c87497553.chainlm)
	end
end
-- 连锁限制的判定函数，限制对方不能进行连锁
function c87497553.chainlm(e,rp,tp)
	return tp==rp
end
