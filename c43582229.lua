--氷結界の晶壁
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡的发动时，可以以自己墓地1只4星以下的「冰结界」怪兽为对象。那个场合，那只怪兽特殊召唤。
-- ②：只要这张卡在魔法与陷阱区域存在并在自己场上有「冰结界」怪兽3只以上存在，自己场上的「冰结界」怪兽不受从额外卡组特殊召唤的对方怪兽发动的效果影响。
function c43582229.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡的发动时，可以以自己墓地1只4星以下的「冰结界」怪兽为对象。那个场合，那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,43582229+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c43582229.target)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在并在自己场上有「冰结界」怪兽3只以上存在，自己场上的「冰结界」怪兽不受从额外卡组特殊召唤的对方怪兽发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置免疫效果的作用对象为持有者场上表侧表示的「冰结界」怪兽（SetTargetRange已限定自己怪兽区，再通过SetTarget筛选字段）。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2f))
	e2:SetCondition(c43582229.condition)
	e2:SetValue(c43582229.efilter)
	c:RegisterEffect(e2)
end
-- 特殊召唤对象的筛选函数：等级4以下、是「冰结界」怪兽、且能被效果e由tp玩家特殊召唤（检查苏生限制和召唤条件）。
function c43582229.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标处理函数：先判定指定对象是否合法；发动判定直接通过；若主怪兽区有空位、墓地有符合条件的对象且玩家选择是，则将效果改为取对象特殊召唤并选择对象、登记操作信息；否则清空效果类别、属性和处理函数，仅作为通常发动。
function c43582229.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43582229.filter(chkc) end
	if chk==0 then return true end
	-- 检查自己主要怪兽区是否存在空格，以决定能否特殊召唤墓地怪兽。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足filter条件且能成为效果对象的「冰结界」怪兽。
		and Duel.IsExistingTarget(c43582229.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 弹出询问，让玩家选择是否发动“将墓地怪兽特殊召唤”的处理，选择“是”才进入后续特殊召唤分支。
		and Duel.SelectYesNo(tp,aux.Stringid(43582229,0)) then  --"是否把墓地怪兽特殊召唤？"
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c43582229.activate)
		-- 发送选择提示消息，告知玩家“请选择要特殊召唤的卡”，用于选择卡片的UI显示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只满足条件的「冰结界」怪兽作为效果对象，并自动与当前连锁关联。
		local g=Duel.SelectTarget(tp,c43582229.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 登记本次连锁的操作信息：包含特殊召唤分类、对象为g（1只怪兽），供其他卡效果检测。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 效果处理时的执行函数：取得效果对象，若对象仍与效果关联，则将其正面表示特殊召唤到自己场上。
function c43582229.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时所选择的对象卡（墓地那只「冰结界」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 由tp玩家将对象怪兽以表侧攻击表示特殊召唤到自己场上（仍需满足召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定用过滤函数：怪兽需表侧表示且为「冰结界」字段，用于②效果的条件统计。
function c43582229.imfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- ②效果的发动条件函数：自己场上存在3只以上表侧表示的「冰结界」怪兽时条件满足。
function c43582229.condition(e)
	-- 检查效果持有者（自己）的怪兽区是否存在至少3只表侧表示的「冰结界」怪兽。
	return Duel.IsExistingMatchingCard(c43582229.imfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,3,nil)
end
-- 免疫效果过滤器：对方怪兽在怪兽区发动的、从额外卡组特殊召唤的怪兽的发动效果，给予免疫。
function c43582229.efilter(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and te:GetOwnerPlayer()==1-e:GetHandlerPlayer()
		and te:GetActivateLocation()==LOCATION_MZONE and tc:IsSummonLocation(LOCATION_EXTRA)
end
