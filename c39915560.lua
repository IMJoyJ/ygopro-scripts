--スターヴ・ヴェノム・プレデター・フュージョン・ドラゴン
-- 效果：
-- 暗属性融合怪兽＋融合怪兽
-- 这个卡名在规则上也当作「捕食植物」卡使用。这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。自己或者对方场上1只有捕食指示物放置的怪兽解放，那个发动无效。
-- ②：融合召唤的这张卡被对方送去墓地的场合，以自己墓地1只暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
function c39915560.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以暗属性融合怪兽和融合怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,c39915560.fusmatfilter,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),true)
	-- ①：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。自己或者对方场上1只有捕食指示物放置的怪兽解放，那个发动无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39915560,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c39915560.negcon)
	e1:SetTarget(c39915560.negtg)
	e1:SetOperation(c39915560.negop)
	c:RegisterEffect(e1)
	-- ②：融合召唤的这张卡被对方送去墓地的场合，以自己墓地1只暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39915560,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,39915560)
	e2:SetCondition(c39915560.spcon)
	e2:SetTarget(c39915560.sptg)
	e2:SetOperation(c39915560.spop)
	c:RegisterEffect(e2)
end
c39915560.mentioned_counter={
	[0x1041]=true,
}
-- 融合素材过滤函数：要求该怪兽是暗属性融合怪兽（对应素材条件「暗属性融合怪兽＋融合怪兽」中的第一只素材）
function c39915560.fusmatfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsFusionType(TYPE_FUSION)
end
-- ①效果发动条件的判定函数：检查当前连锁的发动能否被无效且这张卡没有被战斗破坏
function c39915560.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的发动能否被无效，且这张卡没有被战斗破坏（被战斗破坏时不能对应发动）
	return Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 解放对象过滤函数：要求是场上表侧表示、放置有捕食指示物（0x1041）且能被效果解放的怪兽
function c39915560.negcfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0 and c:IsReleasableByEffect()
end
-- ①效果的目标设定函数：确认场上存在可解放的怪兽，并设置发动无效与解放的效果操作信息
function c39915560.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动可行性检查：确认双方场上至少存在1只放置有捕食指示物且可解放的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c39915560.negcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得双方场上所有放置有捕食指示物且可解放的怪兽组成卡片组
	local g=Duel.GetMatchingGroup(c39915560.negcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：本次连锁将使发动的那个效果（eg）无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：本次连锁将解放1只满足条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
end
-- ①效果的处理函数：让自己选择1只放置有捕食指示物的怪兽解放，解放成功则将那个效果的发动无效
function c39915560.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家「请选择要解放的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让自己选择双方场上1只放置有捕食指示物且可解放的怪兽
	local g=Duel.SelectMatchingCard(tp,c39915560.negcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 若成功选择了怪兽且以效果原因将其解放成功
	if #g>0 and Duel.Release(g,REASON_EFFECT)~=0 then
		-- 将该连锁的效果发动无效
		Duel.NegateActivation(ev)
	end
end
-- ②效果的发动条件判定函数：要求这张卡是融合召唤、由对方送去墓地、原本持有者是自己且之前在场上
function c39915560.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 特殊召唤对象过滤函数：要求是暗属性且能被特殊召唤的怪兽
function c39915560.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标设定函数：对象必须是己方墓地可特殊召唤的暗属性怪兽，并检查场上空位和对象存在性
function c39915560.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39915560.spfilter(chkc,e,tp) end
	-- 效果发动可行性检查：确认自己的主要怪兽区有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在可以成为对象的暗属性怪兽
		and Duel.IsExistingTarget(c39915560.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以自己墓地1只暗属性怪兽为对象
	local g=Duel.SelectTarget(tp,c39915560.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将特殊召唤1只怪兽（所取的对象）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理函数：取得对象怪兽，若该怪兽仍与本效果关联则将其特殊召唤
function c39915560.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁的对象卡（即被选择的墓地暗属性怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
