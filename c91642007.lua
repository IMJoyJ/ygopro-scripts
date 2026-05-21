--海造賊－黒翼の水先人
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「海造贼-黑翼水先人」以外的自己墓地1只「海造贼」怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽加入手卡。这个回合，自己不是「海造贼」怪兽不能特殊召唤。
-- ②：这张卡从手卡·怪兽区域送去墓地的场合，以自己的魔法与陷阱区域1张「海造贼」怪兽卡为对象才能发动。那张卡守备表示特殊召唤。
function c91642007.initial_effect(c)
	-- ①：以「海造贼-黑翼水先人」以外的自己墓地1只「海造贼」怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽加入手卡。这个回合，自己不是「海造贼」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91642007,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,91642007)
	e1:SetTarget(c91642007.thtg)
	e1:SetOperation(c91642007.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·怪兽区域送去墓地的场合，以自己的魔法与陷阱区域1张「海造贼」怪兽卡为对象才能发动。那张卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91642007,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,91642008)
	e2:SetCondition(c91642007.spcon)
	e2:SetTarget(c91642007.sptg)
	e2:SetOperation(c91642007.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地「海造贼-黑翼水先人」以外的「海造贼」怪兽且能加入手卡
function c91642007.thfilter(c)
	return c:IsSetCard(0x13f) and c:IsType(TYPE_MONSTER) and not c:IsCode(91642007) and c:IsAbleToHand()
end
-- 效果①的发动准备，检查怪兽区域是否有空位、自身能否特殊召唤以及墓地是否存在合法的「海造贼」怪兽作为对象
function c91642007.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c91642007.thfilter(chkc) end
	-- 在发动效果时，检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 在发动效果时，检查自己墓地是否存在满足条件的「海造贼」怪兽作为对象
		and Duel.IsExistingTarget(c91642007.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地1只满足条件的「海造贼」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c91642007.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表示此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置效果处理信息，表示此效果包含将作为对象的怪兽加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的效果处理，将自身特殊召唤，并将对象怪兽加入手卡，随后适用本回合只能特殊召唤「海造贼」怪兽的限制
function c91642007.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的第一个效果对象（即墓地的「海造贼」怪兽）
	local tc=Duel.GetFirstTarget()
	-- 如果自身仍存在于手卡，则将其特殊召唤，若特殊召唤成功且对象怪兽仍合法，则继续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	-- 这个回合，自己不是「海造贼」怪兽不能特殊召唤。 / ②：这张卡从手卡·怪兽区域送去墓地的场合，以自己的魔法与陷阱区域1张「海造贼」怪兽卡为对象才能发动。那张卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c91642007.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该特殊召唤限制效果，使其对玩家生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能特殊召唤「海造贼」以外的怪兽
function c91642007.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x13f)
end
-- 效果②的发动条件，检查这张卡是否是从手卡或怪兽区域送去墓地
function c91642007.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_MZONE)
end
-- 过滤自己魔法与陷阱区域可以守备表示特殊召唤的「海造贼」怪兽卡
function c91642007.spfilter(c,e,tp)
	return c:IsSetCard(0x13f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备，检查怪兽区域是否有空位，以及魔法与陷阱区域是否存在合法的「海造贼」怪兽卡作为对象
function c91642007.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c91642007.spfilter(chkc,e,tp) end
	-- 在发动效果时，检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动效果时，检查自己魔法与陷阱区域是否存在满足条件的「海造贼」怪兽卡作为对象
		and Duel.IsExistingTarget(c91642007.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己魔法与陷阱区域1张满足条件的「海造贼」怪兽卡作为效果对象
	local g=Duel.SelectTarget(tp,c91642007.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示此效果包含将作为对象的卡片特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理，将作为对象的魔法与陷阱区域的「海造贼」怪兽卡守备表示特殊召唤
function c91642007.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个效果对象（即魔法与陷阱区域的「海造贼」怪兽卡）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片以表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
