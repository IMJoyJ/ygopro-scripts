--トワイライトロード・シャーマン ルミナス
-- 效果：
-- ①：1回合1次，从自己的手卡·墓地把1只「光道」怪兽除外，以「暮光道萨满 露米娜丝」以外的自己的除外状态的1只「光道」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：1回合1次，其他的自己的「光道」怪兽的效果发动的场合发动。从自己卡组上面把3张卡送去墓地。
function c56166150.initial_effect(c)
	-- ①：1回合1次，从自己的手卡·墓地把1只「光道」怪兽除外，以「暮光道萨满 露米娜丝」以外的自己的除外状态的1只「光道」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56166150,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(c56166150.spcost)
	e1:SetTarget(c56166150.sptg)
	e1:SetOperation(c56166150.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，其他的自己的「光道」怪兽的效果发动的场合发动。从自己卡组上面把3张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56166150,1))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c56166150.ddcon)
	e2:SetTarget(c56166150.ddtg)
	e2:SetOperation(c56166150.ddop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡·墓地中可作为代价除外的「光道」怪兽
function c56166150.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x38) and c:IsAbleToRemoveAsCost()
end
-- 效果①的代价：从自己的手卡·墓地把1只「光道」怪兽除外
function c56166150.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或墓地是否存在至少1只满足过滤条件的「光道」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56166150.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1只手卡或墓地的「光道」怪兽
	local g=Duel.SelectMatchingCard(tp,c56166150.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：除外状态的「暮光道萨满 露米娜丝」以外的「光道」怪兽，且可以特殊召唤
function c56166150.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x38) and not c:IsCode(56166150)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的靶向/发动准备：检查怪兽区域空位并选择除外状态的1只「光道」怪兽作为对象
function c56166150.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c56166150.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在至少1只满足条件的「光道」怪兽作为对象
		and Duel.IsExistingTarget(c56166150.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择除外状态的1只「光道」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c56166150.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的怪兽特殊召唤
function c56166150.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：其他的自己的「光道」怪兽的效果发动
function c56166150.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc~=c
		and rc:IsSetCard(0x38) and rc:IsControler(tp)
end
-- 效果②的靶向/发动准备：设置卡组送去墓地的操作信息
function c56166150.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为从自己卡组上方将3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 效果②的效果处理：从自己卡组上面把3张卡送去墓地
function c56166150.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己卡组最上方的3张卡送去墓地
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
