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
	-- ①：这张卡不受这张卡以外的原本攻击力是3000以下的怪兽发动的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c30270176.immval)
	c:RegisterEffect(e3)
	-- ②：这张卡的攻击破坏怪兽时才能发动。这次战斗阶段中，这张卡只再1次可以攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30270176,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(c30270176.atkcon)
	e4:SetTarget(c30270176.atktg)
	e4:SetOperation(c30270176.atkop)
	c:RegisterEffect(e4)
	-- 这个卡名的③的效果1回合只能使用1次。③：自己结束阶段发动。双方玩家受到3000伤害。
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
-- 选择手牌中未公开且带有「方界」字段的卡，作为展示给对方确认的候选卡。
function c30270176.spcfilter(c)
	return c:IsSetCard(0xe3) and not c:IsPublic()
end
-- 特殊召唤条件判定：当怪兽需要特殊召唤时，检查主要怪兽区是否有空位，以及手牌中可展示的「方界」卡种类数是否至少为3种。
function c30270176.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取这张卡以外的手牌中所有未公开的「方界」卡。
	local hg=Duel.GetMatchingGroup(c30270176.spcfilter,tp,LOCATION_HAND,0,c)
	-- 返回主要怪兽区空位数大于0，且手牌中「方界」卡的不同卡名种类数不少于3。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and hg:GetClassCount(Card.GetCode)>=3
end
-- 特殊召唤的目标选择：从候选的「方界」卡中选择3张卡名互不相同的卡，并保存到效果对象中，用于处理时给对方确认。
function c30270176.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手牌中所有可作为展示代价的「方界」卡。
	local g=Duel.GetMatchingGroup(c30270176.spcfilter,tp,LOCATION_HAND,0,c)
	-- 提示当前玩家选择要展示给对方确认的「方界」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 设置额外的选择条件，要求选出的卡片卡名互不相同。
	aux.GCheckAdditional=aux.dncheck
	-- 从候选组中选出3张满足条件的「方界」卡；若选择成功则返回true。
	local sg=g:SelectSubGroup(tp,aux.TRUE,true,3,3)
	-- 清除额外选择条件，避免影响后续处理。
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤处理：将选出的「方界」卡给对方确认，然后洗切手牌。
function c30270176.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=e:GetLabelObject()
	-- 将选定的3张「方界」卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,rg)
	-- 洗切手牌，以隐藏已展示过的卡牌顺序信息。
	Duel.ShuffleHand(tp)
	rg:DeleteGroup()
end
-- 判断一个效果是否为这张卡以外的原本攻击力为0～3000的怪兽发动的已生效效果；若满足则使这张卡不受该效果影响。
function c30270176.immval(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and te:GetOwner():GetBaseAttack()<=3000 and te:GetOwner():GetBaseAttack()>=0
end
-- ②效果的发动条件：本卡作为攻击者，且在本回合战斗中破坏了对方怪兽。
function c30270176.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认攻击者是这张卡，并且这张卡与本次战斗破坏事件相关。
	return Duel.GetAttacker()==e:GetHandler() and aux.bdcon(e,tp,eg,ep,ev,re,r,rp)
end
-- ②效果发动前检查：这张卡仍与战斗相关，且自身尚未获得额外攻击次数效果，避免重复追加攻击。
function c30270176.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToBattle() and not e:GetHandler():IsHasEffect(EFFECT_EXTRA_ATTACK) end
end
-- ②效果处理：给这张卡赋予1次额外攻击次数，该效果在战斗阶段结束时重置。
function c30270176.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	-- 这次战斗阶段中，这张卡只再1次可以攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
end
-- ③效果的发动条件：当前回合玩家是这张卡的控制者，即自己结束阶段。
function c30270176.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者（tp）。
	return Duel.GetTurnPlayer()==tp
end
-- ③效果发动时无需选择对象，直接返回true并设置伤害信息。
function c30270176.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对双方玩家各造成3000点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,3000)
end
-- ③效果处理：对双方玩家各造成3000点效果伤害，并完成伤害时点处理。
function c30270176.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 对这张卡的控制者造成3000点效果伤害（以伤害步骤分解形式处理）。
	Duel.Damage(tp,3000,REASON_EFFECT,true)
	-- 对对方玩家造成3000点效果伤害（以伤害步骤分解形式处理）。
	Duel.Damage(1-tp,3000,REASON_EFFECT,true)
	-- 完成伤害处理，触发与此伤害相关的时点（如伤害后诱发的效果）。
	Duel.RDComplete()
end
