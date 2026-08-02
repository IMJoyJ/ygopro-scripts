--天使と悪魔のサイコロ
local s,id,o=GetID()
-- 初始化效果
function s.initial_effect(c)
	-- 记述了特定卡名：40235813
	aux.AddCodeList(c,40235813)
	-- ①：作为这张卡发动时的效果处理，掷2次骰子。直到回合结束时，自己场上的特定怪兽的攻击力·守备力上升出现的数目的合计×200，对方场上的怪兽的攻击力·守备力下降出现的数目的合计×200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 不在伤害计算后或伤害步骤以外发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 单体注册合并延迟事件，用于检测包含“召唤或特殊召唤成功”的连锁
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS})
	-- ②：对方把怪兽召唤·特殊召唤的场合，把墓地的这张卡除外，以那1只怪兽为对象才能发动。掷2次骰子，出现的数目的合计是6以上的场合，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 效果目标（发动时）：设定将要掷2次骰子
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息为掷2次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
-- 效果处理：掷骰子并改变怪兽攻击力·守备力
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 掷2次骰子
	local a,b=Duel.TossDice(tp,2)
	local atk=(a+b)*200
	-- 直到回合结束时，自己场上的特定怪兽的攻击力·守备力上升出现的数目的合计×200，对方场上的怪兽的攻击力·守备力下降出现的数目的合计×200。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(atk)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetTargetRange(0,LOCATION_MZONE)
	-- 设置作用对象过滤条件（始终为真）
	e3:SetTarget(aux.TRUE)
	e3:SetValue(atk*(-1))
	-- 将效果注册给玩家
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e4,tp)
end
-- 用于过滤自己场上的怪兽：效果文本上记述着指定卡名
function s.atktg(e,c)
	-- 检测卡片是否效果文本记述有40235813这卡名
	return aux.IsCodeListed(c,40235813)
end
-- 用于过滤对方场上召唤·特殊召唤的怪兽
function s.desfilter(c,tp,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e)
end
-- 检查受事件影响的卡中，是否包含对方场上召唤·特殊召唤的怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 效果目标（发动时）：以对方场上的那1只召唤·特殊召唤的怪兽为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.desfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 把当前正在处理的连锁的对象设置成选择的卡
		Duel.SetTargetCard(sg)
	else
		-- 向玩家提示选择目标，内容为：“请选择要破坏的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择目标（从满足条件的卡片组中选择1张）
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
	-- 设置当前处理的连锁的操作信息为掷2次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
-- 效果处理：掷2次骰子并根据结果破坏目标
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 掷2次骰子
	local a,b=Duel.TossDice(tp,2)
	-- 获取连锁的唯一目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and a+b>5 then
		-- 那只怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
