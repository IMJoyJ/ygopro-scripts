--破械童子アルハ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张卡为对象才能发动。那张卡破坏，这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
-- ②：场上的这张卡被战斗或者「破械童子 阿罗汉」以外的卡的效果破坏的场合才能发动。从手卡·卡组把「破械童子 阿罗汉」以外的1只「破械」怪兽特殊召唤。
function c26236560.initial_effect(c)
	-- ①：以自己场上1张卡为对象才能发动。那张卡破坏，这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26236560,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,26236560)
	e1:SetTarget(c26236560.destg)
	e1:SetOperation(c26236560.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗或者「破械童子 阿罗汉」以外的卡的效果破坏的场合才能发动。从手卡·卡组把「破械童子 阿罗汉」以外的1只「破械」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26236560,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,26236561)
	e2:SetCondition(c26236560.spcon)
	e2:SetTarget(c26236560.sptg)
	e2:SetOperation(c26236560.spop)
	c:RegisterEffect(e2)
end
-- 用于判断目标怪兽是否能被破坏并特殊召唤
function c26236560.desfilter(c,tp)
	-- 判断目标怪兽是否能被破坏并特殊召唤
	return Duel.GetMZoneCount(tp,c)>0
end
-- 设置效果目标，选择场上自己控制的卡作为破坏对象
function c26236560.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c26236560.desfilter(chkc,tp) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否满足发动条件，即场上有自己控制的卡可以被破坏
		and Duel.IsExistingTarget(c26236560.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上自己控制的卡作为破坏对象
	local g=Duel.SelectTarget(tp,c26236560.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置操作信息，记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，记录将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果的发动，破坏目标卡并特殊召唤自身，同时设置不能特殊召唤恶魔族怪兽的效果
function c26236560.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然有效，是否成功破坏，自身是否仍然有效
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 将自身从手卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建并注册一个持续到回合结束的不能特殊召唤恶魔族怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c26236560.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家环境中
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤恶魔族怪兽的效果函数
function c26236560.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- 判断该卡是否因战斗或非阿罗汉的效果被破坏
function c26236560.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(26236560))) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选可以特殊召唤的「破械」怪兽
function c26236560.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(26236560) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，选择可以特殊召唤的「破械」怪兽
function c26236560.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即场上是否有空位且手卡或卡组有符合条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足发动条件，即场上有空位且手卡或卡组有符合条件的怪兽
		and Duel.IsExistingMatchingCard(c26236560.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，记录将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 处理效果的发动，从手卡或卡组特殊召唤符合条件的怪兽
function c26236560.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的「破械」怪兽
	local g=Duel.SelectMatchingCard(tp,c26236560.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
