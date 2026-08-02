--大海の伝説－フィッシャーマン
local s,id,o=GetID()
-- 初始化效果
function s.initial_effect(c)
	-- 记述了卡名：40235813,22702055
	aux.AddCodeList(c,40235813,22702055)
	-- ①：对方把怪兽的效果发动时，或者对方怪兽宣言攻击时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(0)
	e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。这个回合的结束阶段，这张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 用于检查是否有关联卡或海
function s.cfilter(c)
	-- 检查是否为关联卡或海
	return c:IsFaceupEx() and not c:IsCode(id) and (aux.IsCodeOrListed(c,40235813) or c:IsCode(22702055))
end
-- 对方发动怪兽效果时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- 对方怪兽宣言攻击时
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽攻击
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果目标（发动时）：检查是否有空位可以特招
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有怪兽区域的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在关联卡或者当前环境是海
		and (Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsEnvironment(22702055))
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前处理的连锁的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：把这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToChain() then
		-- 把这张卡特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果目标（发动时）：以对方场上1只怪兽为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_MONSTER) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以成为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择目标，内容为：“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标（从满足条件的卡片组中选择1张）
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前处理的连锁的操作信息为破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏目标，并赋予结束阶段回手的效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁的唯一目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 那只怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
	if c:IsRelateToChain() then
		-- 这个回合的结束阶段，这张卡回到手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetOperation(s.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCountLimit(1)
		c:RegisterEffect(e1)
	end
end
-- 效果处理：结束阶段，这张卡回到手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示卡片效果的发动
	Duel.Hint(HINT_CARD,0,id)
	-- 这张卡回到手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
