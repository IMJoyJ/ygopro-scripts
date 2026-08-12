--シュトロームベルクの金の城
-- 效果：
-- 这张卡的控制者在每次自己准备阶段从卡组上面把10张卡里侧表示除外。不能除外的场合这张卡破坏。这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。把有「急流山的金宫」的卡名记述的1只怪兽从卡组特殊召唤。这个效果发动的回合，自己不能通常召唤。
-- ②：对方怪兽的攻击宣言时发动。那只攻击怪兽破坏，给与对方那个攻击力一半数值的伤害。
function c72283691.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这张卡的控制者在每次自己准备阶段从卡组上面把10张卡里侧表示除外。不能除外的场合这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c72283691.mtcon)
	e2:SetOperation(c72283691.mtop)
	c:RegisterEffect(e2)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。把有「急流山的金宫」的卡名记述的1只怪兽从卡组特殊召唤。这个效果发动的回合，自己不能通常召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72283691,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,72283691)
	e3:SetCost(c72283691.spcost)
	e3:SetTarget(c72283691.sptg)
	e3:SetOperation(c72283691.spop)
	c:RegisterEffect(e3)
	-- ②：对方怪兽的攻击宣言时发动。那只攻击怪兽破坏，给与对方那个攻击力一半数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(72283691,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCondition(c72283691.atkcon)
	e4:SetTarget(c72283691.atktg)
	e4:SetOperation(c72283691.atkop)
	c:RegisterEffect(e4)
end
-- 维持费用效果的发动条件函数（自己准备阶段）
function c72283691.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 维持费用效果的处理函数（里侧除外卡组上方10张卡，不能除外则破坏此卡）
function c72283691.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上方的10张卡
	local g=Duel.GetDecktopGroup(tp,10)
	if g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==10 then
		-- 使得接下来的除外操作不触发洗卡检测
		Duel.DisableShuffleCheck()
		-- 作为维持费用，将这10张卡里侧表示除外
		Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	else
		-- 作为维持费用，将这张卡破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 效果①的发动代价与限制函数（本回合不能通常召唤）
function c72283691.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查本回合自己是否进行过通常召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 end
	-- ①：自己主要阶段才能发动。把有「急流山的金宫」的卡名记述的1只怪兽从卡组特殊召唤。这个效果发动的回合，自己不能通常召唤。②：对方怪兽的攻击宣言时发动。那只攻击怪兽破坏，给与对方那个攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给玩家注册“不能召唤”的限制效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 给玩家注册“不能通常召唤的盖放”的限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 过滤卡组中记述了「急流山的金宫」卡名且可以特殊召唤的怪兽
function c72283691.spfilter(c,e,tp)
	-- 检查卡片效果文本是否记述了本卡卡号，且该卡可以被特殊召唤
	return aux.IsCodeListed(c,72283691) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动检测与效果分类注册函数
function c72283691.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己卡组中是否存在至少1张满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c72283691.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为“从卡组特殊召唤1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数（从卡组特殊召唤怪兽）
function c72283691.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否仍在场上，以及自己场上是否有空余的怪兽区域，若无则不处理
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c72283691.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件函数（对方怪兽攻击宣言时）
function c72283691.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方（即对方怪兽宣言攻击）
	return tp~=Duel.GetTurnPlayer()
end
-- 效果②的发动检测与效果分类注册函数
function c72283691.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前进行攻击宣言的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 将该攻击怪兽设为效果处理的对象
	Duel.SetTargetCard(tc)
	-- 设置连锁处理的操作信息为“破坏该攻击怪兽”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设置连锁处理的操作信息为“给与对方该怪兽攻击力一半数值的伤害”
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(tc:GetAttack()/2))
end
-- 效果②的效果处理函数（破坏攻击怪兽并给与伤害）
function c72283691.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果处理对象的攻击怪兽
	local tc=Duel.GetFirstTarget()
	local atk=math.floor(tc:GetAttack()/2)
	-- 检查该怪兽是否仍对应此效果、攻击未被取消，并尝试将其因效果破坏
	if tc:IsRelateToEffect(e) and not tc:IsStatus(STATUS_ATTACK_CANCELED) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给与对方该怪兽攻击力一半数值的伤害
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
