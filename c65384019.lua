--アルケミー・サイクル
-- 效果：
-- 直到发动回合的结束阶段时，自己场上表侧表示存在的怪兽全部的原本攻击力变成0。每次被这个效果把原本攻击力变成0的怪兽被战斗破坏送去墓地，从自己卡组抽1张卡。
function c65384019.initial_effect(c)
	-- 直到发动回合的结束阶段时，自己场上表侧表示存在的怪兽全部的原本攻击力变成0。每次被这个效果把原本攻击力变成0的怪兽被战斗破坏送去墓地，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件：不能在伤害计算后发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c65384019.target)
	e1:SetOperation(c65384019.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且原本攻击力不为0的怪兽
function c65384019.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()~=0
end
-- 效果发动的目标选择与合法性检查
function c65384019.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示且原本攻击力不为0的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65384019.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：将符合条件的怪兽原本攻击力变为0，并注册被战斗破坏送去墓地时的抽卡效果
function c65384019.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且原本攻击力不为0的怪兽
	local g=Duel.GetMatchingGroup(c65384019.filter,tp,LOCATION_MZONE,0,nil)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local tc=g:GetFirst()
	while tc do
		if not tc:IsImmuneToEffect(e) then
			-- 直到发动回合的结束阶段时，自己场上表侧表示存在的怪兽全部的原本攻击力变成0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(0)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(65384019,RESET_EVENT+0x17a0000+RESET_PHASE+PHASE_END,0,1,fid)
		end
		tc=g:GetNext()
	end
	-- 每次被这个效果把原本攻击力变成0的怪兽被战斗破坏送去墓地，从自己卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65384019,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c65384019.drcon)
	e2:SetTarget(c65384019.drtg)
	e2:SetOperation(c65384019.drop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetLabel(fid)
	-- 将抽卡效果作为玩家的效果注册给全局环境
	Duel.RegisterEffect(e2,tp)
end
-- 过滤条件：带有当前效果唯一标识（fid）的卡片
function c65384019.drfilter(c,fid)
	return c:GetFlagEffectLabel(65384019)==fid
end
-- 检查被战斗破坏送去墓地的怪兽中是否存在被该效果原本攻击力变成0的怪兽
function c65384019.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c65384019.drfilter,1,nil,e:GetLabel())
end
-- 抽卡效果的目标确定与操作信息设置
function c65384019.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置抽卡效果的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1张
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的具体执行函数
function c65384019.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
