--大進化薬
-- 效果：
-- 把自己场上1只恐龙族怪兽解放才能把这张卡发动。这张卡发动后继续留在场上，用对方回合计算的第3回合的对方结束阶段破坏。
-- ①：只要这张卡在魔法与陷阱区域存在，自己在5星以上的恐龙族怪兽召唤的场合需要的解放可以不用。
function c84808313.initial_effect(c)
	-- 把自己场上1只恐龙族怪兽解放才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c84808313.cost)
	e1:SetTarget(c84808313.target)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己在5星以上的恐龙族怪兽召唤的场合需要的解放可以不用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84808313,0))  --"使用「大进化药」的效果不用解放召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCondition(c84808313.ntcon)
	e2:SetTarget(c84808313.nttg)
	c:RegisterEffect(e2)
	-- 这张卡发动后继续留在场上
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e3)
end
-- 检查并执行发动代价：解放自己场上1只恐龙族怪兽
function c84808313.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否存在至少1只可解放的恐龙族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_DINOSAUR) end
	-- 让玩家选择自己场上1只可解放的恐龙族怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_DINOSAUR)
	-- 将选中的怪兽解放作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 发动时的效果处理：初始化回合计数器，并注册在对方结束阶段累计回合数并破坏自身的效果
function c84808313.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	-- 用对方回合计算的第3回合的对方结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c84808313.descon)
	e1:SetOperation(c84808313.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 判断是否在对方回合的结束阶段触发效果
function c84808313.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 在对方结束阶段使回合计数器加1，并在达到第3个回合时将此卡破坏
function c84808313.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 根据规则将这张卡破坏
		Duel.Destroy(c,REASON_RULE)
	end
end
-- 检查不用解放召唤的条件：此卡在魔陷区、召唤不需要解放且怪兽区域有空位
function c84808313.ntcon(e,c,minc)
	if c==nil then return true end
	return e:GetHandler():GetType()==TYPE_SPELL
		-- 检查是否为0解放召唤，且自己场上有可使用的怪兽区域空位
		and minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤出等级5以上且是恐龙族的怪兽
function c84808313.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_DINOSAUR)
end
