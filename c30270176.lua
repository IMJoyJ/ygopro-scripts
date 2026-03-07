--暗黒方界神クリムゾン・ノヴァ
-- 效果：
-- 这张卡不能通常召唤。把这张卡以外的手卡的「方界」卡3种类给对方观看的场合才能特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡不受这张卡以外的原本攻击力是3000以下的怪兽发动的效果影响。
-- ②：这张卡的攻击破坏怪兽时才能发动。这次战斗阶段中，这张卡只再1次可以攻击。
-- ③：自己结束阶段发动。双方玩家受到3000伤害。
function c30270176.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把这张卡以外的手卡的「方界」卡3种类给对方观看的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c30270176.spcon)
	e2:SetTarget(c30270176.sptg)
	e2:SetOperation(c30270176.spop)
	c:RegisterEffect(e2)
	-- 这张卡不受这张卡以外的原本攻击力是3000以下的怪兽发动的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c30270176.immval)
	c:RegisterEffect(e3)
	-- 这张卡的攻击破坏怪兽时才能发动。这次战斗阶段中，这张卡只再1次可以攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30270176,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(c30270176.atkcon)
	e4:SetTarget(c30270176.atktg)
	e4:SetOperation(c30270176.atkop)
	c:RegisterEffect(e4)
	-- 自己结束阶段发动。双方玩家受到3000伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(30270176,1))
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,30270176)
	e5:SetCondition(c30270176.damcon)
	e5:SetTarget(c30270176.damtg)
	e5:SetOperation(c30270176.damop)
	c:RegisterEffect(e5)
end
-- 过滤手卡中属于「方界」卡且未公开的卡片。
function c30270176.spcfilter(c)
	return c:IsSetCard(0xe3) and not c:IsPublic()
end
-- 判断是否满足特殊召唤条件：手卡中存在至少3种不同的「方界」卡，并且场上存在可用空间。
function c30270176.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足条件的「方界」卡组。
	local hg=Duel.GetMatchingGroup(c30270176.spcfilter,tp,LOCATION_HAND,0,c)
	-- 判断场上是否有足够的空间以及手卡中是否有3种不同的「方界」卡。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and hg:GetClassCount(Card.GetCode)>=3
end
-- 设置特殊召唤时的选择逻辑：选择3张不同种类的「方界」卡并确认给对方观看。
function c30270176.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的「方界」卡组。
	local g=Duel.GetMatchingGroup(c30270176.spcfilter,tp,LOCATION_HAND,0,c)
	-- 提示玩家选择要确认给对方的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 设置额外检查条件为卡名不同。
	aux.GCheckAdditional=aux.dncheck
	-- 从符合条件的卡中选择3张不同种类的卡。
	local sg=g:SelectSubGroup(tp,aux.TRUE,true,3,3)
	-- 取消额外检查条件。
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤后的处理：确认对方观看所选卡并洗切手牌。
function c30270176.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=e:GetLabelObject()
	-- 向对方确认所选的卡。
	Duel.ConfirmCards(1-tp,rg)
	-- 将玩家的手牌洗切。
	Duel.ShuffleHand(tp)
	rg:DeleteGroup()
end
-- 设置效果免疫条件：当对方发动的怪兽效果满足条件时，该效果对本卡无效。
function c30270176.immval(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and te:GetOwner():GetBaseAttack()<=3000 and te:GetOwner():GetBaseAttack()>=0
end
-- 判断是否为本卡攻击破坏怪兽时触发。
function c30270176.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前攻击怪兽是否为本卡，并且该怪兽处于战斗状态。
	return Duel.GetAttacker()==e:GetHandler() and aux.bdcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 设置攻击破坏后效果的处理条件。
function c30270176.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToBattle() and not e:GetHandler():IsHasEffect(EFFECT_EXTRA_ATTACK) end
end
-- 执行攻击破坏后效果：为本卡增加一次攻击机会。
function c30270176.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	-- 为本卡增加一次攻击机会。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
end
-- 判断是否为自己的结束阶段。
function c30270176.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为本卡控制者。
	return Duel.GetTurnPlayer()==tp
end
-- 设置伤害效果的目标与数量。
function c30270176.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：双方各受到3000伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,3000)
end
-- 执行伤害效果：给双方玩家造成3000伤害。
function c30270176.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给本卡控制者造成3000伤害。
	Duel.Damage(tp,3000,REASON_EFFECT,true)
	-- 给对方玩家造成3000伤害。
	Duel.Damage(1-tp,3000,REASON_EFFECT,true)
	-- 完成伤害处理的时点触发。
	Duel.RDComplete()
end
