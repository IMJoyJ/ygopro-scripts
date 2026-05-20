--マドルチェ・プティンセスール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己墓地没有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。从手卡·卡组把「魔偶甜点·布丁妹公主」以外的1只「魔偶甜点」怪兽特殊召唤。那只怪兽的等级下降1星。这个回合，自己不是「魔偶甜点」怪兽不能特殊召唤。
-- ③：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
function c77848740.initial_effect(c)
	-- ①：自己墓地没有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77848740,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,77848740)
	e1:SetCondition(c77848740.spcon1)
	e1:SetTarget(c77848740.sptg1)
	e1:SetOperation(c77848740.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。从手卡·卡组把「魔偶甜点·布丁妹公主」以外的1只「魔偶甜点」怪兽特殊召唤。那只怪兽的等级下降1星。这个回合，自己不是「魔偶甜点」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77848740,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,77848741)
	e2:SetTarget(c77848740.sptg2)
	e2:SetOperation(c77848740.spop2)
	c:RegisterEffect(e2)
	-- ③：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77848740,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c77848740.retcon)
	e3:SetTarget(c77848740.rettg)
	e3:SetOperation(c77848740.retop)
	c:RegisterEffect(e3)
end
-- ①号效果的发动条件：自己墓地没有怪兽存在。
function c77848740.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在怪兽，若不存在则返回true。
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_MONSTER)
end
-- ①号效果的发动准备（检查怪兽区域是否有空位，以及自身是否能特殊召唤）。
function c77848740.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的处理：将自身特殊召唤。
function c77848740.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤出「魔偶甜点·布丁妹公主」以外的、可以特殊召唤的「魔偶甜点」怪兽。
function c77848740.spfilter2(c,e,tp)
	return c:IsSetCard(0x71) and not c:IsCode(77848740) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②号效果的发动准备（检查怪兽区域是否有空位，以及手卡·卡组是否存在满足条件的怪兽）。
function c77848740.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1只满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c77848740.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置从手卡或卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②号效果的处理：特殊召唤手卡·卡组的「魔偶甜点」怪兽并使其等级下降1星，并适用特殊召唤限制。
function c77848740.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空格，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的「魔偶甜点」怪兽。
	local g=Duel.SelectMatchingCard(tp,c77848740.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功选择并特殊召唤了该怪兽。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=g:GetFirst()
		-- 那只怪兽的等级下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-1)
		tc:RegisterEffect(e1)
	end
	-- 这个回合，自己不是「魔偶甜点」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c77848740.splimit)
	-- 在全局环境中注册该特殊召唤限制效果。
	Duel.RegisterEffect(e2,tp)
end
-- 限制玩家不能特殊召唤「魔偶甜点」以外的怪兽。
function c77848740.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x71)
end
-- ③号效果的发动条件：这张卡在己方场上被对方破坏并送去墓地。
function c77848740.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- ③号效果的发动准备（此效果为必发效果，直接返回true，并设置回到卡组的操作信息）。
function c77848740.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将自身送回卡组的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ③号效果的处理：将这张卡送回卡组并洗牌。
function c77848740.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡送回持有者的卡组并洗牌。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
