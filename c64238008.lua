--リニアキャノン
-- 效果：
-- 把自己场上存在的1只怪兽作为祭品，给与对方基本分那只怪兽的原本攻击力一半数值的伤害。这张卡发动的场合，这个回合中不能发动其他魔法卡。
function c64238008.initial_effect(c)
	-- 把自己场上存在的1只怪兽作为祭品，给与对方基本分那只怪兽的原本攻击力一半数值的伤害。这张卡发动的场合，这个回合中不能发动其他魔法卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c64238008.cost)
	e1:SetTarget(c64238008.target)
	e1:SetOperation(c64238008.activate)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于检测玩家发动魔法卡的操作
	Duel.AddCustomActivityCounter(64238008,ACTIVITY_CHAIN,c64238008.chainfilter)
end
-- 过滤函数，用于判定发动的卡是否为魔法卡（若为魔法卡则计数器增加）
function c64238008.chainfilter(re,tp,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL))
end
-- 效果发动的代价（Cost）处理函数，包含检查是否发动过其他魔法卡、解放怪兽以及注册本回合不能发动其他魔法卡的效果
function c64238008.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查本回合是否未发动过其他魔法卡，且场上是否存在可解放的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(64238008,tp,ACTIVITY_CHAIN)==0 and Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 让玩家选择场上1只怪兽作为解放
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	local atk=math.floor(g:GetFirst():GetTextAttack()/2)
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
	-- 这张卡发动的场合，这个回合中不能发动其他魔法卡。给与对方基本分那只怪兽的原本攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c64238008.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将不能发动其他魔法卡的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的过滤函数，指定不能发动的卡片类型为魔法卡
function c64238008.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
-- 效果的目标处理函数，设置伤害的对象玩家和伤害数值
function c64238008.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()~=0
		e:SetLabel(0)
		return res
	end
	-- 设置伤害的对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将解放怪兽原本攻击力一半的数值设为伤害参数
	Duel.SetTargetParam(e:GetLabel())
	-- 设置效果处理的操作信息为给与对方玩家对应数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
	e:SetLabel(0)
end
-- 效果的运行（Activate）处理函数，执行伤害计算
function c64238008.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应数值的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
