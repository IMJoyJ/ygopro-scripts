--ヴァレット・トレーサー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方回合，以自己场上1张表侧表示卡为对象才能发动。那张卡破坏，从卡组把「弹丸曳光龙」以外的1只「弹丸」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
function c68464358.initial_effect(c)
	-- ①：自己·对方回合，以自己场上1张表侧表示卡为对象才能发动。那张卡破坏，从卡组把「弹丸曳光龙」以外的1只「弹丸」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68464358,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,68464358)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c68464358.sptg)
	e1:SetOperation(c68464358.spop)
	c:RegisterEffect(e1)
end
-- 定义作为破坏对象的卡片的过滤条件（必须是表侧表示，且该卡离开场上后能空出至少1个怪兽区域）
function c68464358.tgfilter(c,tp)
	-- 过滤条件为：卡片在场上表侧表示，且该卡离开场上后能让玩家有可用的怪兽区域
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
end
-- 定义从卡组特殊召唤的怪兽的过滤条件（不能是「弹丸曳光龙」，必须是「弹丸」怪兽，且可以被特殊召唤）
function c68464358.spfilter(c,e,tp)
	return not c:IsCode(68464358) and c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的发动准备（Target阶段），包含合法对象判定和发动条件的检查
function c68464358.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c68464358.tgfilter(chkc,tp) end
	-- 在发动阶段的检查中，判断自己场上是否存在至少1张满足条件的表侧表示卡片作为对象
	if chk==0 then return Duel.IsExistingTarget(c68464358.tgfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		-- 同时判断卡组中是否存在至少1只可以特殊召唤的「弹丸」怪兽
		and Duel.IsExistingMatchingCard(c68464358.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1张表侧表示的卡作为效果的对象
	local g=Duel.SelectTarget(tp,c68464358.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置效果处理信息，表明此效果包含破坏选定卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息，表明此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果的处理（Operation阶段），执行破坏和特殊召唤，并适用后续的特殊召唤限制
function c68464358.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的作为对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡片是否仍与效果相关，若是则将其破坏；在成功破坏且自己场上有可用怪兽区域时，继续执行后续处理
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家发送提示信息，要求选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选择1只满足条件的「弹丸」怪兽
		local g=Duel.SelectMatchingCard(tp,c68464358.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c68464358.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能从额外卡组特殊召唤非暗属性怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义特殊召唤限制的过滤条件（不能特殊召唤从额外卡组出场的非暗属性怪兽）
function c68464358.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end
