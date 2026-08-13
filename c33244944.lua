--エクゾディアとの契約
-- 效果：
-- ①：自己墓地有「被封印的艾克佐迪亚」「被封印者的右腕」「被封印者的左腕」「被封印者的右足」「被封印者的左足」存在的场合才能发动。从手卡把1只「艾克佐迪亚的亡灵」特殊召唤。
function c33244944.initial_effect(c)
	-- 登记这张卡效果文中记载的五张“被封印”部件的卡号，便于后续检索与判断。
	aux.AddCodeList(c,8124921,44519536,70903634,7902349,33396948)
	-- ①：自己墓地有「被封印的艾克佐迪亚」「被封印者的右腕」「被封印者的左腕」「被封印者的右足」「被封印者的左足」存在的场合才能发动。从手卡把1只「艾克佐迪亚的亡灵」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c33244944.condition)
	e1:SetTarget(c33244944.target)
	e1:SetOperation(c33244944.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：自己的墓地中必须同时存在被封印的艾克佐迪亚、右腕、左腕、右足、左足这五张卡。
function c33244944.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在1张「被封印的艾克佐迪亚」（卡号8124921）。
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,8124921)
		-- 检查自己墓地是否存在1张「被封印者的右腕」（卡号44519536）。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,44519536)
		-- 检查自己墓地是否存在1张「被封印者的左腕」（卡号70903634）。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,70903634)
		-- 检查自己墓地是否存在1张「被封印者的右足」（卡号7902349）。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,7902349)
		-- 检查自己墓地是否存在1张「被封印者的左足」（卡号33396948）。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,33396948)
end
-- 特殊召唤对象过滤器：选择手牌中的「艾克佐迪亚的亡灵」（卡号12600382），并确认它能被无视召唤条件与苏生限制地特殊召唤。
function c33244944.filter(c,e,tp)
	return c:IsCode(12600382) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 发动时的target处理：确认自己主要怪兽区有空位，且手牌中存在满足条件的「艾克佐迪亚的亡灵」，以此判断是否能够发动。
function c33244944.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查自己主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动前检查手牌是否存在1张可被特殊召唤的「艾克佐迪亚的亡灵」。
		and Duel.IsExistingMatchingCard(c33244944.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果的操作信息：将从手牌特殊召唤1只怪兽到己方场上，供相关连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时的操作：若主要怪兽区仍无空位则直接终止；否则让玩家从手牌选择1只「艾克佐迪亚的亡灵」，将其特殊召唤并完成正规召唤手续。
function c33244944.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区仍有空位，防止卡场导致无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给操作玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张满足条件的「艾克佐迪亚的亡灵」作为特殊召唤对象。
	local tg=Duel.SelectMatchingCard(tp,c33244944.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if tg:GetCount()>0 then
		local tc=tg:GetFirst()
		-- 将选中的「艾克佐迪亚的亡灵」以表侧攻击表示特殊召唤到己方场上，无视召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
