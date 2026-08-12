--アロマセラフィ－スイート・マジョラム
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组把「湿润之风」「干渴之风」「恩惠之风」的其中1张加入手卡。
-- ②：只要自己基本分比对方多并有这张卡在怪兽区域存在，对方不能把自己场上的植物族怪兽作为效果的对象。
-- ③：自己基本分回复的场合，以对方场上1张卡为对象发动。那张卡破坏。
function c79656239.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从卡组把「湿润之风」「干渴之风」「恩惠之风」的其中1张加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79656239,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,79656239)
	e1:SetCondition(c79656239.thcon)
	e1:SetTarget(c79656239.thtg)
	e1:SetOperation(c79656239.thop)
	c:RegisterEffect(e1)
	-- ②：只要自己基本分比对方多并有这张卡在怪兽区域存在，对方不能把自己场上的植物族怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c79656239.tgcon)
	-- 设置效果影响的对象为自己场上的植物族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PLANT))
	-- 设置不能成为对方卡的效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ③：自己基本分回复的场合，以对方场上1张卡为对象发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79656239,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_RECOVER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,79656240)
	e3:SetCondition(c79656239.descon)
	e3:SetTarget(c79656239.destg)
	e3:SetOperation(c79656239.desop)
	c:RegisterEffect(e3)
end
-- 检查是否为这张卡同调召唤成功
function c79656239.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤卡组中「湿润之风」、「干渴之风」或「恩惠之风」且能加入手牌的卡
function c79656239.thfilter(c)
	return c:IsCode(92266279,28265983,15177750) and c:IsAbleToHand()
end
-- 检索效果的发动准备（检查卡组中是否存在目标卡，并设置检索的操作信息）
function c79656239.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c79656239.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行（从卡组选择1张目标卡加入手牌并给对方确认）
function c79656239.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c79656239.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检查是否满足“自己基本分比对方多”的条件
function c79656239.tgcon(e)
	local tp=e:GetHandlerPlayer()
	-- 比较双方玩家的生命值，判断自己的生命值是否大于对方
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- 检查是否为自己回复生命值
function c79656239.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 破坏效果的发动准备（选择对方场上1张卡作为对象，并设置破坏的操作信息）
function c79656239.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理的操作信息为：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行（若对象卡仍存在则将其破坏）
function c79656239.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
