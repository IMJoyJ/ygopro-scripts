--ゴーストリック・シュタイン
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，这张卡给与对方基本分战斗伤害时，可以从卡组把1张名字带有「鬼计」的魔法·陷阱卡加入手卡。「鬼计科学怪人」的这个效果1回合只能使用1次。
function c16279989.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c16279989.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16279989,0))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c16279989.postg)
	e2:SetOperation(c16279989.posop)
	c:RegisterEffect(e2)
	-- 此外，这张卡给与对方基本分战斗伤害时，可以从卡组把1张名字带有「鬼计」的魔法·陷阱卡加入手卡。「鬼计科学怪人」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16279989,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCountLimit(1,16279989)
	e3:SetCondition(c16279989.thcon)
	e3:SetTarget(c16279989.thtg)
	e3:SetOperation(c16279989.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在名字带有「鬼计」的表侧表示怪兽。
function c16279989.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤条件函数，判断自己场上是否不存在名字带有「鬼计」的怪兽。
function c16279989.sumcon(e)
	-- 判断自己场上是否不存在名字带有「鬼计」的怪兽。
	return not Duel.IsExistingMatchingCard(c16279989.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 设置里侧守备表示效果的发动条件和处理函数。
function c16279989.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(16279989)==0 end
	c:RegisterFlagEffect(16279989,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁操作信息，表示将要改变这张卡的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 里侧守备表示效果的处理函数，将卡变为里侧守备表示。
function c16279989.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 战斗伤害效果的发动条件，判断造成战斗伤害的玩家是否为对方。
function c16279989.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤函数，用于检索卡组中名字带有「鬼计」的魔法或陷阱卡。
function c16279989.filter(c)
	return c:IsSetCard(0x8d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果的发动条件和处理函数。
function c16279989.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的魔法或陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c16279989.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要将卡从卡组加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，选择并加入手牌，然后确认对方看到该卡。
function c16279989.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的魔法或陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c16279989.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
