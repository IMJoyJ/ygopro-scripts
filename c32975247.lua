--神竜 ティタノマキア
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：特殊召唤的这张卡不会被战斗破坏。
-- ②：从自己墓地以及自己场上的表侧表示怪兽之中把包含场上的这张卡的3只「神龙 伟战龙」除外才能发动。对方场上的卡全部破坏。
-- ③：自己·对方的结束阶段才能发动。把自己场上的龙族怪兽数量的卡从自己卡组上面送去墓地。
local s,id,o=GetID()
-- 注册三个效果：①单体永续效果，使特殊召唤的此卡不会被战斗破坏；②起动效果，除外自身及2张同名卡破坏对方全场；③诱发效果，结束阶段从卡组顶送墓龙族数量张卡。
function c32975247.initial_effect(c)
	-- ①：特殊召唤的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c32975247.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这个卡名的②③的效果1回合各能使用1次。②：从自己墓地以及自己场上的表侧表示怪兽之中把包含场上的这张卡的3只「神龙 伟战龙」除外才能发动。对方场上的卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32975247,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,32975247)
	e2:SetCost(c32975247.descost)
	e2:SetTarget(c32975247.destg)
	e2:SetOperation(c32975247.desop)
	c:RegisterEffect(e2)
	-- 这个卡名的②③的效果1回合各能使用1次。③：自己·对方的结束阶段才能发动。把自己场上的龙族怪兽数量的卡从自己卡组上面送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32975247,1))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1,32975247+o)
	e3:SetTarget(c32975247.distg)
	e3:SetOperation(c32975247.disop)
	c:RegisterEffect(e3)
end
-- 判定此卡是否以特殊召唤方式召唤，作为①效果战斗破坏免疫的条件。
function c32975247.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 代价过滤：从自己墓地及场上表侧表示怪兽中选出卡名为「神龙 伟战龙」且可作为代价除外的卡（不包括发动效果的那张自身）。
function c32975247.costfilter(c)
	return c:IsCode(32975247) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 代价处理：获取满足条件的同名卡组，若自身不能除外或可选同名卡不足2张则无法发动；从卡组选2张，再加上效果怪兽自身共3张，表侧表示除外作为代价。
function c32975247.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取从自己场上表侧怪兽和墓地中、除自身外满足代价条件的同名卡集合。
	local g=Duel.GetMatchingGroup(c32975247.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,c)
	if chk==0 then return c:IsAbleToRemoveAsCost() and g:GetCount()>=2 end
	local sg
	if #g==2 then
		sg=g
	else
		-- 弹出选择提示，让玩家选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		sg=g:Select(tp,2,2,nil)
	end
	sg:AddCard(c)
	-- 将选择的2张同名卡与场上的这张卡一起表侧表示除外，作为②效果的发动代价。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- ②效果的目标判定与操作信息设置：确认对方场上存在至少1张卡，并预统计对方场上全部卡的数量用于破坏。
function c32975247.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认对方场上有任意卡可被破坏。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的全部卡，包括怪兽和魔法陷阱。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置本次连锁的操作信息：将对方场上全部卡（数量为g的计数）作为将要被破坏的对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果处理：重新获取对方场上的全部卡，并将其全部破坏。
function c32975247.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次获取对方场上的全部卡，以应对连锁中可能变化的局面。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因将获取到的对方场上所有卡破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 过滤条件：自己场上的表侧表示龙族怪兽，用于③效果的数量计算。
function c32975247.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- ③效果的目标判定与操作信息设置：统计自己场上表侧龙族怪兽数量，确认可把卡组顶端对应数量卡送去墓地，并设置操作信息。
function c32975247.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计自己场上表侧表示的龙族怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c32975247.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 发动条件确认：玩家tp能否从卡组最上方将ct张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,ct) end
	-- 设置操作信息：将卡组顶端ct张卡送去墓地，目标玩家tp，数量ct。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
-- ③效果处理：重新统计龙族怪兽数量，若大于0则从卡组顶端将对应数量的卡送去墓地。
function c32975247.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新统计自己场上表侧龙族怪兽数量，避免因连锁变化导致数量不一致。
	local ct=Duel.GetMatchingGroupCount(c32975247.cfilter,tp,LOCATION_MZONE,0,nil)
	if ct>0 then
		-- 从卡组顶端将ct张卡以效果原因送去墓地。
		Duel.DiscardDeck(tp,ct,REASON_EFFECT)
	end
end
