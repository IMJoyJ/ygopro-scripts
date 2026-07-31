--大海の伝説－フィッシャーマン
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌诱发特召效果、②特召成功破坏对方怪兽及结束阶段回手效果
function s.initial_effect(c)
	-- 注册关联卡名：记有「时间魔术师」、「海」卡名
	aux.AddCodeList(c,40235813,22702055)
	-- ①：对方在场上的怪兽的效果发动的场合，或者对方怪兽的攻击宣言时，场上有「大海的传说-渔夫」以外的记载有「时间魔术师」卡名的卡或者「海」存在的场合才能发动。这张卡从手牌特殊召唤。
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
	-- ②：这张卡特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。这个回合的结束阶段，场上的这张卡回到手牌。
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
-- 场上卡片过滤条件：除自身外记有「时间魔术师」卡名的卡或「海」
function s.cfilter(c)
	-- 检查卡片是否非自身且为记有「时间魔术师」的卡或「海」
	return c:IsFaceupEx() and not c:IsCode(id) and (aux.IsCodeOrListed(c,40235813) or c:IsCode(22702055))
end
-- ①效果触发表条件1：对方在场上发动怪兽效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- ①效果触发表条件2：对方怪兽攻击宣言
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否由对方控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- ①效果发动准备：检查场上卡片条件，设置特殊召唤自身的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：场上是否存在满足条件的卡或场地为「海」
		and (Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsEnvironment(22702055))
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：将手牌的这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToChain() then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果发动准备：选择对方场上1只怪兽作为对象，设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_MONSTER) and chkc:IsControler(1-tp) end
	-- 发动条件检查：对方场上是否存在怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择破坏目标卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：破坏选中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：破坏选中的怪兽，并注册结束阶段自身返回手牌的效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将选中的对象怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
	if c:IsRelateToChain() then
		-- 这个回合的结束阶段，场上的这张卡回到手牌。
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
-- 结束阶段效果处理：将场上的这张卡返回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动提示
	Duel.Hint(HINT_CARD,0,id)
	-- 将自身的卡片返回手牌
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
