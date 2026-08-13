--満天禍コルドー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上的表侧表示的风属性怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以选场上1张魔法·陷阱卡回到持有者卡组最上面。
function c19420830.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：自己场上的表侧表示的风属性怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以选场上1张魔法·陷阱卡回到持有者卡组最上面。
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
-- 判断被破坏的怪兽是否为“自己场上表侧表示的风属性怪兽”，且破坏原因为战斗破坏或对方效果破坏（若为效果破坏，还需是对方玩家发动的效果）。
function c19420830.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_WIND)~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 诱发条件检查：被破坏的怪兽集合中存在至少1只满足上述过滤条件的怪兽。
function c19420830.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19420830.cfilter,1,nil,tp)
end
-- 发动时合法性检查：自己主要怪兽区有空位，且手卡中的这张卡能够被特殊召唤。
function c19420830.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息，声明将要进行特殊召唤的对象为这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 筛选场上存在的、可以返回卡组的魔法·陷阱卡。
function c19420830.tdfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 效果处理：若这张卡仍与效果关联，则先将其特殊召唤，成功后选择是否将场上1张魔法·陷阱卡返回持有者卡组最上面。
function c19420830.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得场上所有满足“魔法·陷阱卡且可回卡组”条件的卡片。
	local g=Duel.GetMatchingGroup(c19420830.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将这张卡从手卡特殊召唤到自己的主要怪兽区，返回是否成功。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 确认特殊召唤成功、存在可选卡片，且玩家选择“是”执行回卡组效果。
		and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19420830,1)) then  --"是否选魔法·陷阱卡回到卡组？"
		-- 弹出选择提示，让玩家从候选卡中选择1张要返回卡组的魔法·陷阱卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 中断当前效果链，使后续回卡组的处理与特殊召唤视为不同时处理，避免错失时点。
		Duel.BreakEffect()
		-- 为选中的卡显示被选为对象的动画，并记录其为对象。
		Duel.HintSelection(sg)
		-- 将选中的魔法·陷阱卡送去持有者卡组最顶端（不洗牌）。
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
