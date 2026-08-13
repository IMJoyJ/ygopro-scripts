--空牙団の飛哨 リコン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把「空牙团的飞哨 锐康」以外的1只「空牙团」怪兽特殊召唤。
-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合，以场上盖放的1张卡为对象才能发动。那张卡破坏。
function c31467949.initial_effect(c)
	-- ①：自己主要阶段才能发动。从手卡把「空牙团的飞哨 锐康」以外的1只「空牙团」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31467949,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,31467949)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c31467949.sptg)
	e1:SetOperation(c31467949.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合，以场上盖放的1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31467949,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,31467950)
	e2:SetCondition(c31467949.descon)
	e2:SetTarget(c31467949.destg)
	e2:SetOperation(c31467949.desop)
	c:RegisterEffect(e2)
end
-- 筛选可特殊召唤的「空牙团」怪兽：必须是「空牙团」字段、不是本卡（31467949），能满足特殊召唤条件。
function c31467949.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and not c:IsCode(31467949) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：在自己主要阶段且怪兽区域有空位，手牌中存在1只符合条件的「空牙团」怪兽。
function c31467949.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有空位，无空位则不能发动①。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足spfilter过滤条件的「空牙团」怪兽。
		and Duel.IsExistingMatchingCard(c31467949.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向连锁信息登记本次操作是特殊召唤，来源为手牌，预计处理1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的处理：确认仍有空位后，从手牌选择1只符合条件的「空牙团」怪兽，以表侧攻击表示特殊召唤。
function c31467949.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认怪兽区空位，若此时没有空位则本次特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足spfilter条件的「空牙团」怪兽（不能是「空牙团的飞哨 锐康」自身）。
	local g=Duel.SelectMatchingCard(tp,c31467949.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定特殊召唤成功的怪兽是否为「空牙团」怪兽且为我方控制的表侧表示怪兽，用于②的触发条件。
function c31467949.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x114) and c:IsControler(tp)
end
-- ②的发动条件判断：特殊召唤的怪兽集合中不包含本卡，且其中有至少1只我方控制的表侧表示的「空牙团」怪兽。
function c31467949.descon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c31467949.cfilter,1,nil,tp)
end
-- ②的发动目标选择：以场上里侧表示的1张卡为对象；发动时确认场上存在里侧表示卡，然后选择1张并登记破坏。
function c31467949.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFacedown() end
	-- 确认场上（双方）是否存在至少1张符合条件的里侧表示卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，提示玩家选择要破坏的里侧表示卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张里侧表示的卡作为效果对象，并与此效果建立关联。
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 向连锁信息登记本次操作是破坏，对象为选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取出发动时选择的目标，若该卡仍与此效果有关联，则将其破坏。
function c31467949.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
