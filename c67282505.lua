--蟲の忍者－蜜
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「忍者」卡或者里侧守备表示怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：对方把怪兽的效果发动时，以自己场上1只里侧守备表示怪兽为对象才能发动。那只怪兽变成表侧守备表示，这张卡变成里侧守备表示。作为对象的怪兽是「虫之忍者-蜜」以外的「忍者」怪兽的场合，再把那个对方的所发动的效果无效。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡特殊召唤）和②效果（对方发动怪兽效果时改变表示形式并无效效果）。
function s.initial_effect(c)
	-- ①：自己场上有「忍者」卡或者里侧守备表示怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时，以自己场上1只里侧守备表示怪兽为对象才能发动。那只怪兽变成表侧守备表示，这张卡变成里侧守备表示。作为对象的怪兽是「虫之忍者-蜜」以外的「忍者」怪兽的场合，再把那个对方的所发动的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_DISABLE+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「忍者」卡，或者里侧守备表示的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2b) or c:IsLocation(LOCATION_MZONE) and c:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- ①效果的发动条件：自己场上存在满足条件的卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「忍者」卡或里侧守备表示怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果的发动准备（Target）：检查怪兽区域是否有空位，以及这张卡是否能特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示该效果包含特殊召唤自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的效果处理（Operation）：将这张卡从手卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与效果相关联，则将其以表侧表示特殊召唤到自己场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- ②效果的发动条件：对方发动怪兽效果，且该效果可以被无效，同时此卡未被战斗破坏。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的怪兽效果，且该效果可以被无效。
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果的发动准备（Target）：选择自己场上1只里侧守备表示怪兽为对象，并确认自身可以变成里侧表示。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsPosition(POS_FACEDOWN_DEFENSE) end
	local c=e:GetHandler()
	-- 检查自己场上是否存在可以作为对象的里侧守备表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEDOWN_DEFENSE)
		and c:IsCanTurnSet() end
	-- 提示玩家选择里侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 玩家选择自己场上1只里侧守备表示怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsPosition,tp,LOCATION_MZONE,0,1,1,nil,POS_FACEDOWN_DEFENSE)
	g:AddCard(c)
	-- 设置连锁处理的操作信息，表示该效果包含改变2张卡表示形式的操作。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,2,0,0)
end
-- ②效果的效果处理（Operation）：将作为对象的怪兽变成表侧守备表示，这张卡变成里侧守备表示。若对象是「虫之忍者-蜜」以外的「忍者」怪兽，则无效对方发动的效果。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFacedown()
		-- 成功将作为对象的怪兽变成表侧守备表示。
		and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)>0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
			-- 成功将这张卡（虫之忍者-蜜）变成里侧守备表示。
			and Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)>0
			and tc:IsSetCard(0x2b) and not tc:IsCode(id) then
			-- 中断当前效果处理，使后续的无效效果处理与改变表示形式不视为同时进行。
			Duel.BreakEffect()
			-- 无效该对方所发动的效果。
			Duel.NegateEffect(ev)
		end
	end
end
