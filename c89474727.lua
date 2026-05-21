--真閃珖竜 スターダスト・クロニクル
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽1只以上
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：1回合1次，把自己墓地1只同调怪兽除外才能发动。这张卡直到回合结束时不受其他卡的效果影响。这个效果在对方回合也能发动。
-- ②：这张卡被对方破坏的场合，以除外的1只自己的龙族同调怪兽为对象才能发动。那只怪兽特殊召唤。
function c89474727.initial_effect(c)
	-- 添加同调召唤手续：同调怪兽调整+调整以外的同调怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1)
	c:EnableReviveLimit()
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置特殊召唤限制为仅能通过同调召唤特殊召唤
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把自己墓地1只同调怪兽除外才能发动。这张卡直到回合结束时不受其他卡的效果影响。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89474727,0))  --"是否发动「真闪珖龙 星尘·录」的效果？"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c89474727.immcost)
	e2:SetOperation(c89474727.immop)
	c:RegisterEffect(e2)
	-- ②：这张卡被对方破坏的场合，以除外的1只自己的龙族同调怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89474727,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c89474727.spcon)
	e3:SetTarget(c89474727.sptg)
	e3:SetOperation(c89474727.spop)
	c:RegisterEffect(e3)
end
c89474727.material_type=TYPE_SYNCHRO
-- 过滤条件：自己墓地的同调怪兽且可以作为除外Cost
function c89474727.cfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost()
end
-- 效果①的发动代价（Cost）：把自己墓地1只同调怪兽除外
function c89474727.immcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足过滤条件的同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89474727.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只满足过滤条件的同调怪兽
	local g=Duel.SelectMatchingCard(tp,c89474727.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的效果处理：使自身直到回合结束时不受其他卡的效果影响
function c89474727.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡直到回合结束时不受其他卡的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c89474727.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤不受影响的效果：排除自身（及自身控制者）以外的卡片效果
function c89474727.efilter(e,re)
	return re:GetOwner()~=e:GetOwner()
end
-- 效果②的发动条件：这张卡被对方破坏并送去墓地或除外
function c89474727.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤条件：除外状态的、可以特殊召唤的龙族同调怪兽
function c89474727.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向（Target）处理：检查怪兽区域空位并选择除外的1只龙族同调怪兽作为对象
function c89474727.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c89474727.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在至少1只满足过滤条件的龙族同调怪兽
		and Duel.IsExistingTarget(c89474727.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外的1只满足过滤条件的龙族同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c89474727.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含特殊召唤分类，操作对象为选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的怪兽特殊召唤
function c89474727.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
