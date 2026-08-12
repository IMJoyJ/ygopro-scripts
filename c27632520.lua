--妖精伝姫－ウィキャット
-- 效果：
-- 魔法师族4星怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的原本属性是光属性的「妖精传姬」怪兽不受对方发动的效果影响。
-- ②：把这张卡最多2个超量素材取除才能发动。把取除数量的「妖精传姬」卡从卡组送去墓地。
-- ③：自己·对方回合，这张卡在墓地存在的场合，以自己场上1只原本属性是光属性的「妖精传姬」怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽送去墓地。
local s,id,o=GetID()
-- 初始化效果，设置XYZ召唤手续、免疫效果、送墓效果和特殊召唤效果
function s.initial_effect(c)
	-- 设置XYZ召唤条件为魔法师族4星怪兽叠放2只以上
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),4,2)
	c:EnableReviveLimit()
	-- 效果①：自己场上的原本属性是光属性的「妖精传姬」怪兽不受对方发动的效果影响
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.etg)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- 效果②：把这张卡最多2个超量素材取除才能发动。把取除数量的「妖精传姬」卡从卡组送去墓地
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
	-- 效果③：自己·对方回合，这张卡在墓地存在的场合，以自己场上1只原本属性是光属性的「妖精传姬」怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽送去墓地
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
-- 过滤条件：场上表侧表示的「妖精传姬」怪兽且原本属性为光属性
function s.etg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1db) and c:GetOriginalAttribute()&ATTRIBUTE_LIGHT~=0
end
-- 过滤条件：对方发动的效果且未被王家长眠之谷影响
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- 效果②的费用：去除1个以上超量素材，最多去除2个
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 获取卡组中满足条件的「妖精传姬」卡数量
	local rt=Duel.GetMatchingGroupCount(s.tgfilter,tp,LOCATION_DECK,0,nil)
	local ct=c:RemoveOverlayCard(tp,1,math.min(2,rt),REASON_COST)
	e:SetLabel(ct)
end
-- 过滤条件：「妖精传姬」卡且能送去墓地
function s.tgfilter(c)
	return c:IsSetCard(0x1db) and c:IsAbleToGrave()
end
-- 效果②的发动条件：已支付费用且卡组中存在满足条件的卡
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否已支付费用且卡组中存在满足条件的卡
	if chk==0 then return e:IsCostChecked() and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果②的处理信息为将指定数量的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,e:GetLabel(),tp,LOCATION_DECK)
end
-- 效果②的处理：选择并送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足条件的「妖精传姬」卡组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	local ct=e:GetLabel()
	if g:GetCount()<ct then return end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:Select(tp,ct,ct,nil)
	if sg:GetCount()>0 then
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 过滤条件：场上表侧表示且能送去墓地的「妖精传姬」怪兽且原本属性为光属性
function s.tfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
		and c:IsSetCard(0x1db) and c:GetOriginalAttribute()&ATTRIBUTE_LIGHT~=0
end
-- 效果③的发动条件：满足特殊召唤条件且场上存在满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断场上是否有足够的召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果③的处理信息为将对象怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置效果③的处理信息为将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果③的处理：特殊召唤自身并送去墓地对象怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否与连锁相关且未受王家长眠之谷影响
	if not c:IsRelateToChain() or not aux.NecroValleyFilter()(c) then return end
	-- 将自身特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前连锁的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
			-- 将对象怪兽送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
