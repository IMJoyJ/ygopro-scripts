--妖精伝姫－ウィキャット
-- 效果：
-- 魔法师族4星怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的原本属性是光属性的「妖精传姬」怪兽不受对方发动的效果影响。
-- ②：把这张卡最多2个超量素材取除才能发动。把取除数量的「妖精传姬」卡从卡组送去墓地。
-- ③：自己·对方回合，这张卡在墓地存在的场合，以自己场上1只原本属性是光属性的「妖精传姬」怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽送去墓地。
local s,id,o=GetID()
-- 初始化函数：给卡片附加XYZ召唤手续、苏生限制，并注册①永续免疫、②起动送墓、③墓地特殊召唤三个效果。
function s.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：把2只魔法师族4星怪兽叠放作为超量素材。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),4,2)
	c:EnableReviveLimit()
	-- ①：自己场上的原本属性是光属性的「妖精传姬」怪兽不受对方发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.etg)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- ②：把这张卡最多2个超量素材取除才能发动。把取除数量的「妖精传姬」卡从卡组送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"送墓效果"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合，这张卡在墓地存在的场合，以自己场上1只原本属性是光属性的「妖精传姬」怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①效果的适用对象筛选：表侧表示、卡名含「妖精传姬」且原本属性为光的怪兽。
function s.etg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1db) and c:GetOriginalAttribute()&ATTRIBUTE_LIGHT~=0
end
-- 免疫判定：只有对方发动的发动型效果（非永续效果）才会被无效/免疫。
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- ②的发动代价：取除1~2个超量素材（取除数量不超过卡组可送墓的「妖精传姬」卡数量），并把实际取除数记录到效果标签。
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 统计卡组中可送墓的「妖精传姬」卡数量，用于限制取除素材的最大数量。
	local rt=Duel.GetMatchingGroupCount(s.tgfilter,tp,LOCATION_DECK,0,nil)
	local ct=c:RemoveOverlayCard(tp,1,math.min(2,rt),REASON_COST)
	e:SetLabel(ct)
end
-- 过滤条件：卡名含「妖精传姬」且可以被送去墓地。
function s.tgfilter(c)
	return c:IsSetCard(0x1db) and c:IsAbleToGrave()
end
-- ②发动条件与操作设定：已支付代价且卡组存在可送墓的「妖精传姬」卡；设置本次操作将把标签数量的卡从卡组送去墓地。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动时能否满足条件：代价已检查过（IsCostChecked）且卡组存在至少1张可送墓的「妖精传姬」卡。
	if chk==0 then return e:IsCostChecked() and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将把e标签数量的「妖精传姬」卡从持有者的卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,e:GetLabel(),tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选出取除数量的「妖精传姬」卡送去墓地；若数量不足则效果不适用。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得卡组中所有可送墓的「妖精传姬」卡的集合。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	local ct=e:GetLabel()
	if g:GetCount()<ct then return end
	-- 向玩家显示选择“送去墓地”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:Select(tp,ct,ct,nil)
	if sg:GetCount()>0 then
		-- 将选中的「妖精传姬」卡以效果原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- ③取对象的目标筛选：自己场上表侧表示、原本属性为光且可送去墓地的「妖精传姬」怪兽。
function s.tfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
		and c:IsSetCard(0x1db) and c:GetOriginalAttribute()&ATTRIBUTE_LIGHT~=0
end
-- ③的发动条件与取对象：检查自身可用效果特殊召唤、场上有空位，并选择场上1只符合条件的「妖精传姬」怪兽为对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 需要自己有可用的主要怪兽区空格，用于特殊召唤这张卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 需要自己场上存在1只可作为对象的符合条件的「妖精传姬」怪兽。
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择“送去墓地”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只符合条件的「妖精传姬」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：将把对象怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置操作信息：将把这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ③效果处理：若这张卡仍可处理且不受王家长眠之谷限制，则将其特殊召唤；成功后将对象怪兽送去墓地。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与当前连锁相关，且不受王家长眠之谷效果影响（墓地效果有效）。
	if not c:IsRelateToChain() or not aux.NecroValleyFilter()(c) then return end
	-- 将这张卡表侧表示特殊召唤，并检查是否成功。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 取得这张卡发动时选择的对象怪兽。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
			-- 将对象怪兽以效果原因送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
