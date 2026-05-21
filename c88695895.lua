--罪宝の咎人
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「迪亚贝尔斯塔尔」怪兽卡存在，对方从卡组·额外卡组把怪兽特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽回到卡组。
-- ②：自己的「迪亚贝尔斯塔尔」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把墓地的这张卡除外才能发动。那只对方怪兽的攻击力直到回合结束时变成一半。
local s,id,o=GetID()
-- 注册卡片效果：①效果（对方从卡组·额外卡组特召时让场上1只怪兽回卡组）和②效果（墓地除外让与「迪亚贝尔斯塔尔」战斗的对方怪兽攻击力减半）
function s.initial_effect(c)
	-- ①：自己场上有「迪亚贝尔斯塔尔」怪兽卡存在，对方从卡组·额外卡组把怪兽特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「迪亚贝尔斯塔尔」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，把墓地的这张卡除外才能发动。那只对方怪兽的攻击力直到回合结束时变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力变成一半"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.atkcon)
	-- 设置发动cost为：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：由对方玩家从卡组或额外卡组特殊召唤成功的怪兽
function s.cfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤条件：自己场上表侧表示的「迪亚贝尔斯塔尔」怪兽卡（包括视为怪兽卡的魔陷）
function s.confilter(c)
	return c:IsSetCard(0x119b) and c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0
end
-- ①效果的发动条件：自己场上有「迪亚贝尔斯塔尔」怪兽卡存在，且对方从卡组·额外卡组把怪兽特殊召唤
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「迪亚贝尔斯塔尔」怪兽卡
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_ONFIELD,0,1,nil)
		and eg:IsExists(s.cfilter,1,nil,e,tp)
end
-- 过滤条件：可以回到卡组的卡
function s.tdfilter(c)
	return c:IsAbleToDeck()
end
-- ①效果的靶向处理：检查并选择对方场上1只可以回到卡组的怪兽作为对象，并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tdfilter(chkc) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以回到卡组的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送“选择要返回卡组的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择对方场上1只可以回到卡组的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的操作信息为：将选中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ①效果的运行处理：将作为对象的怪兽回到持有者卡组并洗牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的发动条件：自己的「迪亚贝尔斯塔尔」怪兽和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local phase=Duel.GetCurrentPhase()
	-- 限制只能在伤害步骤且未进行伤害计算前发动
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽（防守方）
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if not a:IsControler(tp) then a,d=d,a end
	e:SetLabelObject(d)
	return a:IsControler(tp) and a:IsFaceup() and a:IsSetCard(0x119b) and d:IsControler(1-tp) and d:IsFaceup() and d:IsRelateToBattle()
end
-- ②效果的靶向处理：获取在发动条件中保存的对方怪兽，并确认其存在
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=e:GetLabelObject()
	if chk==0 then return d end
end
-- ②效果的运行处理：使该对方怪兽的攻击力直到回合结束时变成一半
function s.atkop(e,tp,ep,ev,re,r,rp)
	local d=e:GetLabelObject()
	if d and d:IsFaceup() and d:IsType(TYPE_MONSTER) then
		local atk=d:GetAttack()
		-- 那只对方怪兽的攻击力直到回合结束时变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		d:RegisterEffect(e1)
	end
end
