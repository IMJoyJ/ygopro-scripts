--超重武者カゲボウ－C
-- 效果：
-- 「超重武者 影法师-C」的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从手卡把1只「超重武者」怪兽特殊召唤。
-- ②：自己场上的「超重武者」怪兽成为效果的对象时，把墓地的这张卡除外才能发动。那个发动无效并破坏。这个效果在对方回合也能发动。
function c27978707.initial_effect(c)
	-- ①：把这张卡解放才能发动。从手卡把1只「超重武者」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27978707,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,27978707)
	e1:SetCost(c27978707.spcost)
	e1:SetTarget(c27978707.sptg)
	e1:SetOperation(c27978707.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「超重武者」怪兽成为效果的对象时，把墓地的这张卡除外才能发动。那个发动无效并破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27978707,1))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27978708)
	e2:SetCondition(c27978707.negcon)
	-- 设置②效果发动时的代价：把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27978707.negtg)
	e2:SetOperation(c27978707.negop)
	c:RegisterEffect(e2)
end
-- 定义①效果的代价函数：在发动时判定此卡是否可以解放，若可以则将此卡解放作为代价。
function c27978707.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将效果持有者（这张卡）解放，作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义手卡中可作为特殊召唤对象的「超重武者」怪兽的过滤条件：属于「超重武者」系列，且能够被此效果特殊召唤。
function c27978707.filter(c,e,tp)
	return c:IsSetCard(0x9a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义①效果发动时的目标合法性检查：确认我方主要怪兽区有可用空位（考虑解放此卡后腾出位置），且手卡中存在符合条件的「超重武者」怪兽。
function c27978707.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否存在可用空格（由于发动代价会解放此卡腾出1格，因此当前空格为0时也允许发动）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 同时检查手卡中是否存在至少1张满足c27978707.filter条件的「超重武者」怪兽。
		and Duel.IsExistingMatchingCard(c27978707.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：此连锁的效果将从手卡特殊召唤1只怪兽（分类为特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义①效果的处理流程：若处理时我方主要怪兽区仍有空位，则从手卡选择1只符合条件的「超重武者」怪兽，表侧表示特殊召唤。
function c27978707.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若我方主要怪兽区已没有空位，则直接终止，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1张满足c27978707.filter条件的「超重武者」怪兽。
	local g=Duel.SelectMatchingCard(tp,c27978707.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果中“自己场上的「超重武者」怪兽”的判定条件：该怪兽为我方场上的表侧表示「超重武者」怪兽，且位于主要怪兽区。
function c27978707.negfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x9a) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
-- 定义②效果的发动条件：对方发动的效果为取对象效果，且其对象包含我方场上的「超重武者」怪兽，并且该连锁的发动可以被无效。
function c27978707.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取被连锁的效果所指向的对象卡集合（用于判断是否存在我方超重武者）。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判定对象卡集合中是否存在满足条件的我方「超重武者」怪兽，且该连锁的发动能够被无效。
	return g and g:IsExists(c27978707.negfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 定义②效果的target：无条件允许发动，并设置操作信息为无效该连锁；若被无效连锁的发动卡可被破坏且与该效果仍有关联，则同时设置破坏该卡。
function c27978707.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理将无效该效果的发动的对应连锁，对象为被连锁的卡集合eg。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：本次处理将破坏被连锁的发动卡，对象为eg。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义②效果的处理流程：无效被连锁的效果的发动；如果其发动卡仍与该效果关联，则将其破坏。
function c27978707.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若该连锁的发动被成功无效，且其发动卡仍与该效果存在关联，则进入破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏被无效的连锁的发动卡（即eg）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
