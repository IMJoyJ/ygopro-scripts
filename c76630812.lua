--天使と悪魔のサイコロ
local s,id,o=GetID()
-- 初始化卡片效果：注册记述列表、①掷骰子增减双方攻击力·守备力效果、②墓地除外掷骰子破坏对方召唤怪兽效果
function s.initial_effect(c)
	-- 注册卡片记述列表：记述「天使的骰子」（40235813）
	aux.AddCodeList(c,40235813)
	-- ①：掷2次骰子。直到回合结束时，自己场上有「天使的骰子」或「恶魔的骰子」记述的怪兽的攻击力·守备力上升掷出数值之和×200，对方场上的怪兽的攻击力·守备力下降掷出数值之和×200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置伤害步骤发动条件
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 注册合并延迟事件：监听对方怪兽召唤·特殊召唤成功
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS})
	-- ②：对方把怪兽召唤·特殊召唤的场合，把墓地的这张卡除外，以那1只怪兽为对象才能发动。掷2次骰子，掷出的合计是5以上的场合，那只怪兽破坏。
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
-- ①效果发动准备：设置掷2次骰子的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：掷2次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
-- ①效果处理：掷2次骰子，提升己方符合条件怪兽攻守并降低敌方怪兽攻守
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家掷2次骰子
	local a,b=Duel.TossDice(tp,2)
	local atk=(a+b)*200
	-- 注册直到回合结束时双方场上怪兽攻击力·守备力增减变化的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(atk)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：提升己方记述怪兽的攻击力
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	-- 注册全局效果：提升己方记述怪兽的守备力
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetTargetRange(0,LOCATION_MZONE)
	-- 攻击力下降对象过滤：对方场上所有怪兽
	e3:SetTarget(aux.TRUE)
	e3:SetValue(atk*(-1))
	-- 注册全局效果：降低对方场上怪兽的攻击力
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	-- 注册全局效果：降低对方场上怪兽的守备力
	Duel.RegisterEffect(e4,tp)
end
-- 攻守上升对象过滤：记述有「天使的骰子」的怪兽
function s.atktg(e,c)
	-- 检查怪兽是否记述有「天使的骰子」
	return aux.IsCodeListed(c,40235813)
end
-- 破坏对象过滤：对方召唤·特殊召唤成功且可作为效果对象的怪兽
function s.desfilter(c,tp,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e)
end
-- ②效果发动条件：存在对方玩家召唤·特殊召唤的怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- ②效果发动准备：选择对方召唤的怪兽为对象并设置掷骰子操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.desfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 将对方召唤的单只怪兽设为连锁对象
		Duel.SetTargetCard(sg)
	else
		-- 提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方召唤的怪兽中选择1只作为对象
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
	-- 设置连锁操作信息：掷2次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
-- ②效果处理：掷2次骰子，若点数之和大于5则破坏对象怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家掷2次骰子
	local a,b=Duel.TossDice(tp,2)
	-- 获取连锁中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and a+b>5 then
		-- 将对象怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
