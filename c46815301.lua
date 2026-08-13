--ゴーティスの双角アスカーン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，以自己场上1只鱼族怪兽和对方场上1张卡为对象才能发动。那些卡除外。
-- ②：这张卡被除外的场合，从自己墓地把1只鱼族怪兽除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化函数：设置同调召唤手续（调整+调整以外的怪兽1只以上），并注册①效果（同调召唤成功时除外自己场上1只鱼族怪兽和对方场上1张卡）和②效果（这张卡被除外时，除外自己墓地1只鱼族怪兽为代价，特殊召唤自身）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽和1只以上调整以外的怪兽作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：这张卡同调召唤的场合，以自己场上1只鱼族怪兽和对方场上1张卡为对象才能发动。那些卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，从自己墓地把1只鱼族怪兽除外才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡为同调召唤成功（召唤类型包含同调召唤）。
function s.rmcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的对象选择过滤器：自己场上表侧表示且种族为鱼族、可以被除外的怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:IsAbleToRemove()
end
-- 效果①的target函数：连锁处理时不能选对象；发动合法性检查时确认自己场上有符合条件的鱼族怪兽且对方场上有可除外的卡。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：自己主要怪兽区是否存在1张满足s.filter（表侧表示鱼族且可除外）的卡。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动合法性检查：对方场上是否存在1张可被除外的卡。
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家发出选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只满足s.filter的鱼族怪兽作为①效果的对象（同时加入连锁对象）。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向操作玩家发出选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张可除外的卡作为①效果的对象（同时加入连锁对象）。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	g:Merge(g2)
	-- 设置操作信息：本次效果处理将把2张对象卡除外（分类为除外）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- 效果①处理：取得连锁记录的对象卡组，过滤出仍与效果关联的卡，将它们以表侧表示除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g then
		local rg=g:Filter(Card.IsRelateToEffect,nil,e)
		-- 将过滤后仍关联的对象卡以表侧表示除外，理由是效果处理。
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的费用过滤器：选择自己墓地1只怪兽且种族为鱼族、可以被除外的卡作为发动代价。
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FISH) and c:IsAbleToRemoveAsCost()
end
-- ②效果的cost处理：从自己墓地选择1只满足s.cfilter的鱼族怪兽除外作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用合法性检查：自己墓地是否存在1张满足s.cfilter的鱼族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家发出选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只满足s.cfilter的鱼族怪兽作为cost。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的鱼族怪兽以表侧表示除外，作为②效果的发动cost。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的target函数：确认自己主要怪兽区有空位，且这张卡可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性检查：自己主要怪兽区是否有空闲区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次处理将把这张卡特殊召唤（分类为特殊召唤，对象为这张卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则将其特殊召唤到自己场上表侧表示。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与②效果关联，若是则将其以表侧表示特殊召唤到自己场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
