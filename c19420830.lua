--満天禍コルドー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上的表侧表示的风属性怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以选场上1张魔法·陷阱卡回到持有者卡组最上面。
function c19420830.initial_effect(c)
	-- 创建效果1，用于处理卡片从手卡特殊召唤并可能将魔法·陷阱卡送回卡组的触发效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19420830,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,19420830)
	e1:SetCondition(c19420830.spcon)
	e1:SetTarget(c19420830.sptg)
	e1:SetOperation(c19420830.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件函数，用于判断被破坏的怪兽是否为己方场上表侧表示的风属性怪兽，并且是由战斗或对方效果破坏的
function c19420830.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_WIND)~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 条件函数，判断是否有满足过滤条件的怪兽被破坏
function c19420830.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19420830.cfilter,1,nil,tp)
end
-- 目标函数，判断是否可以将此卡特殊召唤
function c19420830.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于筛选场上的魔法·陷阱卡
function c19420830.tdfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 效果处理函数，执行特殊召唤并询问是否将魔法·陷阱卡送回卡组
function c19420830.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取场上的魔法·陷阱卡作为可选对象
	local g=Duel.GetMatchingGroup(c19420830.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将此卡特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 判断是否有魔法·陷阱卡可选且玩家选择进行操作
		and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19420830,1)) then  --"是否选魔法·陷阱卡回到卡组？"
		-- 提示玩家选择要送回卡组的魔法·陷阱卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 显示所选魔法·陷阱卡被选为对象的动画效果
		Duel.HintSelection(sg)
		-- 将选中的魔法·陷阱卡送回持有者卡组顶端
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
