--影六武衆－フウマ
-- 效果：
-- ①：这张卡被战斗·效果破坏的场合才能发动。从卡组把「影六武众-风魔」以外的1只「六武众」怪兽特殊召唤。
-- ②：只让自己场上的「六武众」怪兽1只被效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c71207871.initial_effect(c)
	-- ①：这张卡被战斗·效果破坏的场合才能发动。从卡组把「影六武众-风魔」以外的1只「六武众」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71207871,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c71207871.spcon)
	e1:SetTarget(c71207871.sptg)
	e1:SetOperation(c71207871.spop)
	c:RegisterEffect(e1)
	-- ②：只让自己场上的「六武众」怪兽1只被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c71207871.reptg)
	e2:SetValue(c71207871.repval)
	e2:SetOperation(c71207871.repop)
	c:RegisterEffect(e2)
end
-- 检查破坏原因是否为战斗或效果
function c71207871.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤卡组中除「影六武众-风魔」以外且可以特殊召唤的「六武众」怪兽
function c71207871.spfilter(c,e,tp)
	return c:IsSetCard(0x103d) and not c:IsCode(71207871) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域是否有空位，以及卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息）
function c71207871.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c71207871.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为“从卡组特殊召唤1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（从卡组选择1只符合条件的「六武众」怪兽特殊召唤）
function c71207871.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 玩家从卡组选择1只符合条件的「六武众」怪兽
	local tg=Duel.SelectMatchingCard(tp,c71207871.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tg then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示、因效果被破坏且非代替破坏的「六武众」怪兽
function c71207871.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动准备（检查墓地的此卡是否可以除外，以及被破坏的卡是否仅有1只且符合过滤条件）
function c71207871.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c71207871.repfilter,1,nil,tp)
	and eg:GetCount()==1
	end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏的适用对象（即符合过滤条件的怪兽）
function c71207871.repval(e,c)
	return c71207871.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的效果处理（将墓地的此卡除外）
function c71207871.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的此卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
