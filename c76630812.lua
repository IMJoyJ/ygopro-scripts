--天使と悪魔のサイコロ
local s,id,o=GetID()
-- 初始化卡片效果：注册①魔法发动·掷骰子增减攻守效果、②墓地诱发掷骰子破坏怪兽效果
function s.initial_effect(c)
	-- 注册关联卡名：记有「时间魔术师」卡名
	aux.AddCodeList(c,40235813)
	-- ①：掷2次骰子。直到回合结束时，以下效果分别适用。●记载有「时间魔术师」卡名的自己场上的怪兽的攻击力·守备力上升掷出的出现值的合计×200。●对方场上的怪兽的攻击力·守备力下降掷出的出现值的合计×200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置伤害步骤发动条件限制（伤害计算前）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 注册合并延迟事件：监听对方召唤·特殊召唤怪兽的时点
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS})
	-- ②：这张卡在墓地存在的状态，对方把怪兽召唤·特殊召唤的场合，把墓地的这张卡除外，以那之中的1只为对象才能发动。掷2次骰子。掷出的出现值的合计是6以上的场合，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	-- ②效果发动Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- ①效果发动准备：设置掷骰子操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：掷2次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
-- ①效果处理：掷2次骰子，根据掷出的点数改变自己记有「时间魔术师」的怪兽及对方怪兽的攻守
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家掷2次骰子，获取出现值
	local a,b=Duel.TossDice(tp,2)
	local atk=(a+b)*200
	-- 直到回合结束时，以下效果分别适用。●记载有「时间魔术师」卡名的自己场上的怪兽的攻击力·守备力上升掷出的出现值的合计×200。●对方场上的怪兽的攻击力·守备力下降掷出的出现值的合计×200。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(atk)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册攻击力上升效果：记有「时间魔术师」的己方怪兽攻击力上升
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	-- 注册守备力上升效果：记有「时间魔术师」的己方怪兽守备力上升
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetTargetRange(0,LOCATION_MZONE)
	-- 设置攻击力下降目标：对方场上所有怪兽
	e3:SetTarget(aux.TRUE)
	e3:SetValue(atk*(-1))
	-- 注册攻击力下降效果：对方场上怪兽攻击力下降
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	-- 注册守备力下降效果：对方场上怪兽守备力下降
	Duel.RegisterEffect(e4,tp)
end
-- 己方攻守上升目标过滤：记载有「时间魔术师」卡名的怪兽
function s.atktg(e,c)
	-- 检查怪兽文本中是否记载着「时间魔术师」的卡名
	return aux.IsCodeListed(c,40235813)
end
-- ②效果取对象过滤：对方召唤·特殊召唤的怪兽且可成为效果对象
function s.desfilter(c,tp,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e)
end
-- ②效果发动条件：对方有怪兽召唤·特殊召唤
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- ②效果发动准备：选择对方召唤·特殊召唤的1只怪兽作为对象，设置掷骰子操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.desfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 将单一召唤的怪兽直接设为连锁对象
		Duel.SetTargetCard(sg)
	else
		-- 显示选择破坏目标卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 多个怪兽同时召唤时，选择其中1只作为连锁对象
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
	-- 设置连锁操作信息：掷2次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
-- ②效果处理：掷2次骰子，合计为6以上的场合将对象怪兽破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家掷2次骰子，获取出现值
	local a,b=Duel.TossDice(tp,2)
	-- 获取连锁对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and a+b>5 then
		-- 破坏目标的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
