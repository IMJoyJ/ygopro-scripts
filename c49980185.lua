--超能力治療
-- 效果：
-- 这张卡在结束阶段时才能发动。自己回复这个回合送去墓地的念动力族怪兽数量×1000的数值的基本分。
function c49980185.initial_effect(c)
	-- 这张卡在结束阶段时才能发动。自己回复这个回合送去墓地的念动力族怪兽数量×1000的数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCondition(c49980185.reccon)
	e1:SetTarget(c49980185.rectg)
	e1:SetOperation(c49980185.recop)
	c:RegisterEffect(e1)
	if not c49980185.global_check then
		c49980185.global_check=true
		c49980185[0]=0
		-- 中的“这个回合送去墓地的念动力族怪兽数量”：每当有卡送去墓地时，累计其中念动力族怪兽的数量。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c49980185.checkop)
		-- 将监测怪兽送去墓地并累计念动力族怪兽数量的全局效果 ge1 注册到整个决斗中，使任意玩家的怪兽送去墓地时都会触发 checkop 计数。
		Duel.RegisterEffect(ge1,0)
		-- 中的“这个回合”：在抽卡阶段开始时将计数器 c49980185[0] 清零，确保只统计当前回合送去墓地的念动力族怪兽。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c49980185.clear)
		-- 将抽卡阶段开始时清空计数器的全局效果 ge2 注册到决斗中，用于重置上一回合的计数。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 定义 checkop 操作函数：当有卡送去墓地时，用 eg（本次送去墓地的卡组）过滤出念动力族怪兽，将其数量累加到全局计数器 c49980185[0] 中。
function c49980185.checkop(e,tp,eg,ep,ev,re,r,rp)
	c49980185[0]=c49980185[0]+eg:FilterCount(Card.IsRace,nil,RACE_PSYCHO)
end
-- 定义 clear 操作函数：将全局计数器 c49980185[0] 归零，用于在抽卡阶段开始时清空上一回合的计数。
function c49980185.clear(e,tp,eg,ep,ev,re,r,rp)
	c49980185[0]=0
end
-- 定义 reccon 条件函数：判断此卡的效果是否满足发动条件，即必须是结束阶段。
function c49980185.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件判定：当前阶段为结束阶段时返回 true，满足“这张卡在结束阶段时才能发动”。
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 定义 rectg 目标函数：在发动时检查计数器是否不为 0，并设置回复对象玩家和回复数值的操作信息。
function c49980185.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c49980185[0]~=0 end
	-- 将当前连锁的效果对象玩家设为发动者自身（tp），即基本分的回复者。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果对象参数设置为计数器数值×1000，即需要回复的 LP 数值。
	Duel.SetTargetParam(c49980185[0]*1000)
	-- 设置操作信息，声明本次效果为 CATEGORY_RECOVER（回复效果），预计回复量为 c49980185[0]*1000，供其他卡片的连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,c49980185[0]*1000)
end
-- 定义 recop 操作函数：在效果处理时获取对象玩家并实际执行基本分回复。
function c49980185.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前 SetTargetPlayer 设置的对象玩家，作为回复 LP 的玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让玩家 p 回复 c49980185[0]*1000 点基本分，回复原因是卡片效果（REASON_EFFECT）。
	Duel.Recover(p,c49980185[0]*1000,REASON_EFFECT)
end
