--驚楽園の助手 ＜Delia＞
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1张「游乐设施」陷阱卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：从手卡以及自己场上的表侧表示的卡之中把1张「游乐设施」陷阱卡送去墓地才能发动。从卡组选1张「游乐设施」陷阱卡在自己的魔法与陷阱区域盖放。
function c22662014.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把手卡1张「游乐设施」陷阱卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22662014,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,22662014)
	e1:SetCost(c22662014.spcost)
	e1:SetTarget(c22662014.sptg)
	e1:SetOperation(c22662014.spop)
	c:RegisterEffect(e1)
	-- ②：从手卡以及自己场上的表侧表示的卡之中把1张「游乐设施」陷阱卡送去墓地才能发动。从卡组选1张「游乐设施」陷阱卡在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22662014,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,22662015)
	e2:SetCost(c22662014.setcost)
	e2:SetTarget(c22662014.settg)
	e2:SetOperation(c22662014.setop)
	c:RegisterEffect(e2)
end
-- 定义①的cost检索过滤器：筛选手牌中非公开状态的「游乐设施」陷阱卡。
function c22662014.cfilter(c)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and not c:IsPublic()
end
-- ①的cost函数：检查手牌存在符合条件的「游乐设施」陷阱卡，选择1张给对方确认，然后洗切手牌。
function c22662014.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：自己手牌中是否存在至少1张符合条件的「游乐设施」陷阱卡（非公开状态）。
	if chk==0 then return Duel.IsExistingMatchingCard(c22662014.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出“请选择给对方确认的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌选择1张符合条件的「游乐设施」陷阱卡作为展示cost。
	local g=Duel.SelectMatchingCard(tp,c22662014.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切自己的手牌（因为展示了手牌，需要重新随机化手牌顺序）。
	Duel.ShuffleHand(tp)
end
-- ①的发动目标条件：自己主要怪兽区有空位，且这张卡自身可以被特殊召唤。
function c22662014.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，声明此次效果将进行1只怪兽的特殊召唤（对象为这张卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：若这张卡仍与效果关联，则将其表侧攻击表示特殊召唤到自己场上。
function c22662014.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到自己的主要怪兽区。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义②的cost过滤器：从手牌或自己场上表侧表示的卡中选出「游乐设施」陷阱卡且可作cost送墓；若魔陷区无空格，则只能选位于魔陷区的表侧表示的卡，送墓后可空出格子用于盖放。
function c22662014.costfilter(c,ft)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_TRAP) and c:IsSetCard(0x15c) and c:IsAbleToGraveAsCost()
		and (ft>0 or c:IsLocation(LOCATION_SZONE) and ft>-1)
end
-- ②的cost函数：检查并选择1张符合条件的「游乐设施」陷阱卡（手牌或自己场上表侧表示）作为cost送去墓地。
function c22662014.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己魔法与陷阱区域当前可用的空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 检查手牌以及自己场上的表侧表示的卡中是否存在至少1张符合条件的「游乐设施」陷阱卡可作为cost。
	if chk==0 then return Duel.IsExistingMatchingCard(c22662014.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,ft) end
	-- 弹出“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌和自己场上表侧表示的卡中选择1张符合条件的「游乐设施」陷阱卡作为cost。
	local g=Duel.SelectMatchingCard(tp,c22662014.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,ft)
	-- 将选择的卡作为cost送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义②的效果处理检索过滤器：从卡组选出可以盖放的「游乐设施」陷阱卡。
function c22662014.setfilter(c,chk)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:IsSSetable(chk)
end
-- ②的发动条件：卡组中存在至少1张可以无视魔陷区空格限制盖放的「游乐设施」陷阱卡。
function c22662014.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张符合条件的「游乐设施」陷阱卡（用ignore_field=true确认存在性，不实际占用空格）。
	if chk==0 then return Duel.IsExistingMatchingCard(c22662014.setfilter,tp,LOCATION_DECK,0,1,nil,true) end
end
-- ②的效果处理：从卡组选1张「游乐设施」陷阱卡盖放到自己的魔法与陷阱区域。
function c22662014.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要盖放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张符合条件的「游乐设施」陷阱卡（此时ignore_field=false，确保实际可以盖放）。
	local g=Duel.SelectMatchingCard(tp,c22662014.setfilter,tp,LOCATION_DECK,0,1,1,nil,false)
	if g:GetCount()>0 then
		-- 将选择的「游乐设施」陷阱卡盖放到自己的魔法与陷阱区域。
		Duel.SSet(tp,g:GetFirst())
	end
end
