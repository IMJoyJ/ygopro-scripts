--太陽神合一
-- 效果：
-- 这张卡的①②的效果在同一连锁上不能发动，自己场上有原本卡名是「太阳神之翼神龙」的怪兽存在的场合，这张卡在盖放的回合也能发动。
-- ①：自己·对方的主要阶段，把基本分支付到变成100基本分才能发动。选自己场上1只特殊召唤的「太阳神之翼神龙」，那个攻击力·守备力上升支付的数值。
-- ②：1回合1次，把自己场上1只「太阳神之翼神龙」解放才能发动。自己基本分回复那个攻击力的数值。
function c77432167.initial_effect(c)
	-- 注册卡片密码，表示这张卡的效果文本中记载了「太阳神之翼神龙」
	aux.AddCodeList(c,10000010)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 自己场上有原本卡名是「太阳神之翼神龙」的怪兽存在的场合，这张卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77432167,2))  --"适用「太阳神合一」的效果来发动"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCondition(c77432167.actcon)
	c:RegisterEffect(e1)
	-- ①：自己·对方的主要阶段，把基本分支付到变成100基本分才能发动。选自己场上1只特殊召唤的「太阳神之翼神龙」，那个攻击力·守备力上升支付的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77432167,0))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(c77432167.atkcon)
	e2:SetCost(c77432167.atkcost)
	e2:SetTarget(c77432167.atktg)
	e2:SetOperation(c77432167.atkop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把自己场上1只「太阳神之翼神龙」解放才能发动。自己基本分回复那个攻击力的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77432167,1))  --"基本分回复"
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCost(c77432167.reccost)
	e3:SetTarget(c77432167.rectg)
	e3:SetOperation(c77432167.recop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示且原本卡名是「太阳神之翼神龙」的怪兽
function c77432167.actfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(10000010)
end
-- 盖放回合发动的条件：自己场上存在原本卡名是「太阳神之翼神龙」的怪兽
function c77432167.actcon(e)
	-- 检查自己场上是否存在原本卡名是「太阳神之翼神龙」的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c77432167.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动条件：自己或对方的主要阶段
function c77432167.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果①的消耗：支付基本分到变成100，并标记在同一连锁上不能发动另一个效果
function c77432167.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	local c=e:GetHandler()
	-- 获取玩家当前的生命值
	local lp=Duel.GetLP(tp)
	-- 检查是否能支付（当前生命值-100）的生命值，且该卡在同一连锁上未发动过其他效果
	if chk==0 then return Duel.CheckLPCost(tp,lp-100,true) and c:GetFlagEffect(77432167)==0 end
	e:SetLabel(100,lp-100)
	-- 支付生命值，使玩家的生命值减少到100
	Duel.PayLPCost(tp,lp-100,true)
	c:RegisterFlagEffect(77432167,RESET_CHAIN,0,1)
end
-- 过滤条件：自己场上表侧表示、特殊召唤的「太阳神之翼神龙」
function c77432167.atkfilter(c)
	return c:IsFaceup() and c:IsCode(10000010) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果①的目标处理：检查是否存在符合条件的怪兽，并保存支付的生命值数值作为效果参数
function c77432167.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local label,atk=e:GetLabel()
	if chk==0 then
		e:SetLabel(0,0)
		if label~=100 then return false end
		-- 检查自己场上是否存在特殊召唤的「太阳神之翼神龙」
		return Duel.IsExistingMatchingCard(c77432167.atkfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	e:SetLabel(0,0)
	-- 将支付的生命值数值设置为效果处理的参数
	Duel.SetTargetParam(atk)
end
-- 效果①的效果处理：选自己场上1只特殊召唤的「太阳神之翼神龙」，使其攻击力·守备力上升支付的数值
function c77432167.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家选择自己场上1只特殊召唤的「太阳神之翼神龙」
	local g=Duel.SelectMatchingCard(tp,c77432167.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 选中卡片时显示选中动画
		Duel.HintSelection(g)
		-- 获取之前保存的支付生命值数值
		local atk=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		-- 那个攻击力·守备力上升支付的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 过滤条件：场上的「太阳神之翼神龙」且攻击力大于0
function c77432167.recfilter(c)
	return c:IsCode(10000010) and c:GetAttack()>0
end
-- 效果②的消耗：解放自己场上1只「太阳神之翼神龙」，并标记在同一连锁上不能发动另一个效果
function c77432167.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	local c=e:GetHandler()
	-- 检查是否能解放自己场上的「太阳神之翼神龙」，且该卡在同一连锁上未发动过其他效果
	if chk==0 then return Duel.CheckReleaseGroup(tp,c77432167.recfilter,1,nil) and c:GetFlagEffect(77432167)==0 end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择自己场上1只「太阳神之翼神龙」进行解放
	local g=Duel.SelectReleaseGroup(tp,c77432167.recfilter,1,1,nil)
	e:SetLabel(100,g:GetFirst():GetAttack())
	-- 将选中的怪兽作为发动成本解放
	Duel.Release(g,REASON_COST)
	c:RegisterFlagEffect(77432167,RESET_CHAIN,0,1)
end
-- 效果②的目标处理：设置回复生命值的相关参数和操作信息
function c77432167.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local label,rec=e:GetLabel()
	if chk==0 then
		e:SetLabel(0,0)
		if label~=100 then return false end
		return true
	end
	e:SetLabel(0,0)
	-- 设置回复生命值的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复生命值的数值为被解放怪兽的攻击力
	Duel.SetTargetParam(rec)
	-- 设置回复生命值的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果②的效果处理：自己基本分回复被解放怪兽的攻击力数值
function c77432167.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取回复生命值的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复生命值的处理
	Duel.Recover(p,d,REASON_EFFECT)
end
