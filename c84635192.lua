--ツルプルプルン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己的主要怪兽区域1只水属性怪兽为对象才能发动。那只自己怪兽破坏，这张卡在那只怪兽存在过的区域特殊召唤。那之后，可以把和这张卡相同纵列的对方的表侧表示卡全部破坏。
local s,id,o=GetID()
-- 注册该卡在手牌发动的起动效果，包含破坏和特殊召唤分类，取对象，同名卡一回合只能使用一次。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡存在的场合，以自己的主要怪兽区域1只水属性怪兽为对象才能发动。那只自己怪兽破坏，这张卡在那只怪兽存在过的区域特殊召唤。那之后，可以把和这张卡相同纵列的对方的表侧表示卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 过滤满足以下条件的卡：自己主要怪兽区域表侧表示的水属性怪兽，且该怪兽离开后其所在的怪兽区域可以用于特殊召唤手牌的这张卡。
function s.filter(c,e,tp)
	local seq=c:GetSequence()
	-- 判定目标怪兽是否在主要怪兽区域、表侧表示、水属性，且该怪兽离开后其所在的怪兽区域有空位可供特殊召唤。
	return seq<5 and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_TOFIELD,1<<seq)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果发动的目标选择与判定：选择自己主要怪兽区域的1只水属性怪兽作为对象，并注册破坏该怪兽和特殊召唤手牌此卡的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 在发动阶段的检查：判定场上是否存在可以作为对象的、满足过滤条件的自己主要怪兽区域的水属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己主要怪兽区域的1只满足条件的水属性怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：包含破坏选中的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：包含特殊召唤手牌的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：破坏作为对象的怪兽，并将这张卡特殊召唤到该怪兽存在过的区域，之后可以破坏与这张卡相同纵列的对方场上所有表侧表示的卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local seq=tc:GetSequence()
	-- 判定对象怪兽是否仍由自己控制、是怪兽卡且仍与效果相关，并将其破坏。
	if tc:IsControler(tp) and tc:IsType(TYPE_MONSTER) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		-- 判定手牌的这张卡是否仍与效果相关，并将其特殊召唤到被破坏怪兽原本所在的怪兽区域。
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,1<<seq)~=0 then
		-- 立即刷新场上卡片的状态和位置信息，以便准确获取当前纵列的卡片。
		Duel.AdjustAll()
		-- 获取与这张卡相同纵列的对方场上的表侧表示卡片组。
		local g=c:GetColumnGroup():Filter(aux.AND(Card.IsFaceup,Card.IsControler),nil,1-tp)
		-- 如果相同纵列存在对方的表侧表示卡片，询问玩家是否选择发动破坏效果。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否破坏对方的卡？"
			-- 中断当前效果处理，使后续的破坏处理与前面的特殊召唤不视为同时处理。
			Duel.BreakEffect()
			-- 破坏相同纵列的对方表侧表示卡片。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
