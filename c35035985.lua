--灰滅せし成れの果て
-- 效果：
-- 炎族怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，以自己墓地1张场地魔法卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡和对方的炎族怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。这个效果在自己回合发动的场合，这张卡只再1次可以继续攻击。
local s,id,o=GetID()
-- 初始化效果函数，设置卡片苏生限制并添加融合召唤手续
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤需要2个炎族怪兽作为素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsRace,RACE_PYRO),2,true)
	-- ①：这张卡融合召唤的场合，以自己墓地1张场地魔法卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方的炎族怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。这个效果在自己回合发动的场合，这张卡只再1次可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 判断是否满足效果②的发动条件，即是否与对方炎族怪兽战斗且对方怪兽存在
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() and bc:IsRace(RACE_PYRO)
end
-- 设置效果②的发动目标，即对方的炎族怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 设置连锁操作信息，指定效果②会破坏对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 效果②的处理函数，执行破坏对方怪兽并可能再攻击一次
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsType(TYPE_MONSTER) and bc:IsControler(1-tp) then
		-- 将对方怪兽因效果破坏
		Duel.Destroy(bc,REASON_EFFECT)
	end
	-- 判断是否在自己回合且该卡能继续攻击
	if Duel.GetTurnPlayer()==tp and c:IsRelateToEffect(e) and c:IsChainAttackable() then
		-- 使该卡可以再进行1次攻击
		Duel.ChainAttack()
	end
end
-- 效果①的发动条件，判断是否为融合召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤满足条件的场地魔法卡
function s.thfilter(c,tp)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 效果①的发动目标选择函数，选择墓地中的场地魔法卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查是否有满足条件的场地魔法卡可选
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标场地魔法卡
	local sg=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，指定效果①会将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- 效果①的处理函数，将目标卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
