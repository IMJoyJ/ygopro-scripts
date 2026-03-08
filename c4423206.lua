--M.X－セイバー インヴォーカー
-- 效果：
-- 3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。把1只战士族或兽战士族的地属性·4星怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c4423206.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为3且数量为2的怪兽作为素材
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。把1只战士族或兽战士族的地属性·4星怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(4423206,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c4423206.cost)
	e1:SetTarget(c4423206.sptg)
	e1:SetOperation(c4423206.spop)
	c:RegisterEffect(e1)
end
-- 支付效果代价，从场上取除1个超量素材
function c4423206.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选满足条件的怪兽：战士族或兽战士族、地属性、4星且可以特殊召唤
function c4423206.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR+RACE_BEASTWARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果的发动条件：场上存在空位且卡组存在符合条件的怪兽
function c4423206.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c4423206.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，确定将要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动，选择并特殊召唤符合条件的怪兽，并注册结束阶段破坏效果
function c4423206.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c4423206.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽特殊召唤到场上
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(4423206,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 注册结束阶段破坏效果，使特殊召唤的怪兽在结束阶段被破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c4423206.descon)
		e1:SetOperation(c4423206.desop)
		-- 将破坏效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为当前特殊召唤的怪兽，防止其他怪兽触发该破坏效果
function c4423206.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(4423206)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行破坏操作，将怪兽破坏
function c4423206.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将怪兽因效果而破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
