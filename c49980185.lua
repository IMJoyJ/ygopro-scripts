--超能力治療
-- 效果：
-- 这张卡在结束阶段时才能发动。自己回复这个回合送去墓地的念动力族怪兽数量×1000的数值的基本分。
function c49980185.initial_effect(c)
	-- 这张卡在结束阶段时才能发动。
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
		-- 自己回复这个回合送去墓地的念动力族怪兽数量×1000的数值的基本分。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c49980185.checkop)
		-- 将效果注册给全局环境
		Duel.RegisterEffect(ge1,0)
		-- 自己回复这个回合送去墓地的念动力族怪兽数量×1000的数值的基本分。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c49980185.clear)
		-- 将效果注册给全局环境
		Duel.RegisterEffect(ge2,0)
	end
end
-- 统计送去墓地的念动力族怪兽数量并累加到全局变量中
function c49980185.checkop(e,tp,eg,ep,ev,re,r,rp)
	c49980185[0]=c49980185[0]+eg:FilterCount(Card.IsRace,nil,RACE_PSYCHO)
end
-- 在每个回合抽卡阶段开始时清空统计数量
function c49980185.clear(e,tp,eg,ep,ev,re,r,rp)
	c49980185[0]=0
end
-- 判断是否处于结束阶段
function c49980185.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于结束阶段
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 设置效果的目标玩家和参数，准备发动回复效果
function c49980185.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c49980185[0]~=0 end
	-- 设置连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为念动力族怪兽数量乘以1000
	Duel.SetTargetParam(c49980185[0]*1000)
	-- 设置操作信息为回复效果，目标玩家为当前玩家，回复数值为念动力族怪兽数量乘以1000
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,c49980185[0]*1000)
end
-- 执行回复效果，恢复指定数量的基本分
function c49980185.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 使目标玩家回复指定数量的基本分
	Duel.Recover(p,c49980185[0]*1000,REASON_EFFECT)
end
