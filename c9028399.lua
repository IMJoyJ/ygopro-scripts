--楽天禍カルクラグラ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上的表侧表示的地属性怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1只怪兽送去墓地。
function c9028399.initial_effect(c)
	-- ①：自己场上的表侧表示的地属性怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9028399,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,9028399)
	e1:SetCondition(c9028399.spcon)
	e1:SetTarget(c9028399.sptg)
	e1:SetOperation(c9028399.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的地属性怪兽被战斗或对方的效果破坏
function c9028399.cfilter(c,tp,rp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_EARTH)~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 发动条件：检查是否存在满足条件的被破坏的卡
function c9028399.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c9028399.cfilter,1,nil,tp)
end
-- 效果发动阶段：检查自身是否能特殊召唤以及怪兽区域是否有空位
function c9028399.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置送去墓地的操作信息，表示从卡组将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
-- 过滤条件：卡组中可以送去墓地的怪兽卡
function c9028399.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果处理阶段：将自身特殊召唤，之后可以从卡组选择1只怪兽送去墓地
function c9028399.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取卡组中所有满足送墓条件的怪兽
	local g=Duel.GetMatchingGroup(c9028399.tgfilter,tp,LOCATION_DECK,0,nil)
	-- 尝试将自身特殊召唤，若特殊召唤成功则继续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 若卡组中存在可送墓的怪兽，询问玩家是否选择将怪兽送去墓地
		and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(9028399,1)) then  --"是否从卡组把怪兽送去墓地？"
		-- 中断当前效果处理，使后续的送墓处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
