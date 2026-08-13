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
-- 判断怪兽是否为表侧表示且名字带有「鬼计」字段，用于确认场上是否存在可满足召唤条件的鬼计怪兽。
function c16279989.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 不存在表侧表示且名字带有「鬼计」的怪兽时，此卡的召唤限制效果适用，即不能表侧表示召唤。
function c16279989.sumcon(e)
	-- 以效果控制者为视角检查自己主要怪兽区是否存在至少1只表侧表示且名字带有「鬼计」的怪兽；若不存在则返回true，使禁止召唤效果生效。
	return not Duel.IsExistingMatchingCard(c16279989.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 起动效果的发动条件与操作登记：确认此卡可以变成里侧守备表示且本回合尚未使用过该效果；通过后登记1回合1次的标志，并设置将改变表示形式的操作信息。
function c16279989.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(16279989)==0 end
	c:RegisterFlagEffect(16279989,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 登记操作信息：本次连锁将把此卡（1张怪兽）改变表示形式，用于相关规则检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理：若此卡仍与效果关联且处于表侧表示，则将其变成里侧守备表示。
function c16279989.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将此卡直接变更为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 战斗伤害判定：只有对方基本分受到此卡造成的战斗伤害时，检索效果才满足发动条件。
function c16279989.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 检索候选卡筛选：卡组中1张名字带有「鬼计」的魔法·陷阱卡，且该卡能够加入手卡。
function c16279989.filter(c)
	return c:IsSetCard(0x8d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动合法性检查及操作登记：确认卡组存在至少1张符合条件的「鬼计」魔法·陷阱卡，并登记将1张卡加入手卡的操作信息。
function c16279989.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查卡组是否存在至少1张符合条件的「鬼计」魔法·陷阱卡；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c16279989.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：效果处理时从卡组将1张卡加入手卡（因对象在处理时才选择，此处目标暂为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：提示玩家从卡组选择符合条件的「鬼计」魔法·陷阱卡加入手卡，并向对方展示所选的卡。
function c16279989.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，提示其选择要加入手卡的卡（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选择1张满足filter条件的卡（即符合条件的「鬼计」魔法·陷阱卡）。
	local g=Duel.SelectMatchingCard(tp,c16279989.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
