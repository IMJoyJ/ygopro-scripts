--炎王獣 キリン
-- 效果：
-- ①：自己场上的表侧表示的「炎王」怪兽被效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被破坏送去墓地的场合才能发动。从卡组把1只炎属性怪兽送去墓地。
function c96594609.initial_effect(c)
	-- ①：自己场上的表侧表示的「炎王」怪兽被效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96594609,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c96594609.spcon)
	e1:SetTarget(c96594609.sptg)
	e1:SetOperation(c96594609.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏送去墓地的场合才能发动。从卡组把1只炎属性怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96594609,1))  --"送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c96594609.tgcon)
	e2:SetTarget(c96594609.tgtg)
	e2:SetOperation(c96594609.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「炎王」怪兽被效果破坏
function c96594609.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:IsSetCard(0x81)
end
-- 效果①的发动条件：检查是否有满足条件的卡被破坏
function c96594609.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c96594609.cfilter,1,nil,tp)
end
-- 效果①的发动准备：检查怪兽区域空位与自身能否特殊召唤，并设置特殊召唤的操作信息
function c96594609.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将手卡中的这张卡特殊召唤
function c96594609.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动条件：检查这张卡是否因破坏而送去墓地
function c96594609.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤条件：卡组中可以送去墓地的炎属性怪兽
function c96594609.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGrave()
end
-- 效果②的发动准备：检查卡组中是否存在可送去墓地的炎属性怪兽，并设置送去墓地的操作信息
function c96594609.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96594609.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组选择1只炎属性怪兽送去墓地
function c96594609.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c96594609.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
