--アビス・オーパー
-- 效果：
-- 水属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。这张卡在连接召唤的回合不能作为连接素材。
-- ①：这张卡连接召唤成功的场合才能发动。从手卡把1只鱼族怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ②：以这张卡以外的自己场上1只鱼族怪兽和对方场上1张卡为对象才能发动。那些卡除外。
function c82184400.initial_effect(c)
	-- 设置连接召唤的手续为2只水属性怪兽。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WATER),2,2)
	c:EnableReviveLimit()
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetCondition(c82184400.linkcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡连接召唤成功的场合才能发动。从手卡把1只鱼族怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82184400,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,82184400)
	e2:SetCondition(c82184400.condition)
	e2:SetTarget(c82184400.target)
	e2:SetOperation(c82184400.operation)
	c:RegisterEffect(e2)
	-- ②：以这张卡以外的自己场上1只鱼族怪兽和对方场上1张卡为对象才能发动。那些卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82184400,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,82184401)
	e3:SetTarget(c82184400.rmtg)
	e3:SetOperation(c82184400.rmop)
	c:RegisterEffect(e3)
end
-- 判定自身是否在连接召唤的回合。
function c82184400.linkcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 判定此卡是否为连接召唤成功。
function c82184400.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤手卡中可以特殊召唤到此卡连接区的鱼族怪兽。
function c82184400.filter(c,e,tp,zone)
	return c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果①的发动准备与合法性检测，并设置特殊召唤的操作信息。
function c82184400.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone(tp)
		-- 检查手卡中是否存在至少1只可以特殊召唤到此卡连接区的鱼族怪兽。
		return Duel.IsExistingMatchingCard(c82184400.filter,tp,LOCATION_HAND,0,1,nil,e,tp,zone)
	end
	-- 设置连锁处理中的操作信息为从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的实际处理：从手卡选择1只鱼族怪兽特殊召唤到此卡的连接区。
function c82184400.operation(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 检查此卡连接区在自己场上是否有可用的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手卡选择1只满足条件的鱼族怪兽。
		local g=Duel.SelectMatchingCard(tp,c82184400.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到指定的连接区。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
		end
	end
end
-- 过滤自己场上表侧表示的鱼族怪兽，且对方场上存在可除外的卡。
function c82184400.rmfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:IsAbleToRemove()
		-- 检查对方场上是否存在至少1张可以除外的卡。
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,c)
end
-- 效果②的发动准备，选择自己场上1只鱼族怪兽和对方场上1张卡作为对象，并设置除外的操作信息。
function c82184400.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在除这张卡以外的鱼族怪兽，且对方场上存在可除外的卡。
	if chk==0 then return Duel.IsExistingTarget(c82184400.rmfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要除外的自己场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只除这张卡以外的鱼族怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,c82184400.rmfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),tp)
	-- 提示玩家选择要除外的对方场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张卡作为效果对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,g1)
	g1:Merge(g2)
	-- 设置连锁处理中的操作信息为除外选中的2张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,#g1,0,0)
end
-- 效果②的实际处理：将作为对象的卡除外。
function c82184400.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 将仍与效果相关的对象卡片表侧表示除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
