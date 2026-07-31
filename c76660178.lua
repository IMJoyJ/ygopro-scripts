--大海の伝説－フィッシャーマン
local s,id,o=GetID()
-- 初始化卡片效果：注册关联卡名列表、注册①对方怪兽发效果/攻击宣言时手牌特召效果、②特召成功破坏对方怪兽并在结束阶段回手效果
function s.initial_effect(c)
	-- 注册关联卡名列表：「时间魔术师」(40235813)、「海」(22702055)
	aux.AddCodeList(c,40235813,22702055)
	-- ①：对方场上的怪兽的效果发动时，或者对方怪兽的攻击宣言时，自己场上有「时间魔术师」的卡名记载的怪兽（「大海之传说-渔夫」除外）存在或场地处于「海」环境的场合才能发动。这张卡从手牌特殊召唤。
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
	-- ②：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。那之后，在这个回合的结束阶段，这张卡回到持有者手牌。
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
-- 前提卡片过滤条件：自己场上表侧存在记载有「时间魔术师」卡名且非自身的怪兽，或卡名为「海」
function s.cfilter(c)
	-- 判断是否满足卡名记载或特定卡名条件
	return c:IsFaceupEx() and not c:IsCode(id) and (aux.IsCodeOrListed(c,40235813) or c:IsCode(22702055))
end
-- ①效果（连锁对方怪兽效果）发动条件检查：对方在场上发动怪兽效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- ①效果（连锁对方攻击宣言）发动条件检查：对方怪兽宣言攻击
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击者是否为对方玩家
	return Duel.GetAttacker():IsControler(1-tp)
end
-- ①效果发动准备与条件检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己场上有指定关联卡存在或处于「海」场地环境
		and (Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsEnvironment(22702055))
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：从手牌特殊召唤自身
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToChain() then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果发动准备与目标选择
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_MONSTER) and chkc:IsControler(1-tp) end
	-- 发动条件检查：对方怪兽区域存在可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：破坏目标怪兽1张
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：破坏目标怪兽，并注册结束阶段自身返回手牌的延迟效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
	if c:IsRelateToChain() then
		-- 注册延迟效果：回合结束阶段触发，将自身返回手牌
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
-- 结束阶段延迟效果处理：将此卡返回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示发动效果的卡片提示
	Duel.Hint(HINT_CARD,0,id)
	-- 将此卡返回手牌
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
