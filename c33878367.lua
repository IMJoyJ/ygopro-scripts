--壱世壊に渦巻く反響
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的卡组·墓地选1只「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」特殊召唤。那之后，选种族或者属性和这个效果特殊召唤的怪兽相同的自己场上1只怪兽送去墓地。
-- ②：这张卡被效果送去墓地的场合，以除外的1张自己的「珠泪哀歌族」陷阱卡为对象才能发动。那张卡加入手卡。
function c33878367.initial_effect(c)
	-- 注册卡片代码列表，记录该卡与「维萨斯-斯塔弗罗斯特」（56099748）的关联
	aux.AddCodeList(c,56099748)
	-- ①：从自己的卡组·墓地选1只「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」特殊召唤。那之后，选种族或者属性和这个效果特殊召唤的怪兽相同的自己场上1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,33878367)
	e1:SetTarget(c33878367.sptg)
	e1:SetOperation(c33878367.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合，以除外的1张自己的「珠泪哀歌族」陷阱卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,33878367)
	e2:SetCondition(c33878367.thcon)
	e2:SetTarget(c33878367.thtg)
	e2:SetOperation(c33878367.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为「珠泪哀歌族」怪兽或「维萨斯-斯塔弗罗斯特」且可特殊召唤
function c33878367.spfilter(c,e,tp)
	return (c:IsSetCard(0x181) or c:IsCode(56099748)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时的条件判断，检查是否有满足条件的怪兽可特殊召唤
function c33878367.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组或墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c33878367.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从卡组或墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 设置操作信息，表示将从场上送去墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
-- 效果处理函数，执行特殊召唤及后续送去墓地操作
function c33878367.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33878367.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤操作
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取与特殊召唤怪兽种族或属性相同的场上怪兽
		local sg=Duel.GetMatchingGroup(c33878367.tgfilter,tp,LOCATION_MZONE,0,nil,tc:GetRace(),tc:GetAttribute())
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续处理错开时点
			Duel.BreakEffect()
			-- 提示玩家选择要送去墓地的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local sc=sg:Select(tp,1,1,nil)
			-- 将选中的怪兽送去墓地
			Duel.SendtoGrave(sc,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于判断场上怪兽是否与特殊召唤怪兽种族或属性相同且可送去墓地
function c33878367.tgfilter(c,race,attr)
	return c:IsFaceup() and (c:IsRace(race) or c:IsAttribute(attr)) and c:IsAbleToGrave()
end
-- 判断该卡是否因效果被送去墓地
function c33878367.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数，用于判断除外的陷阱卡是否为「珠泪哀歌族」陷阱卡
function c33878367.thfilter(c)
	return c:IsSetCard(0x181) and c:IsType(TYPE_TRAP) and c:IsFaceup() and c:IsAbleToHand()
end
-- 设置效果处理时的条件判断，检查是否有满足条件的除外陷阱卡
function c33878367.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c33878367.thfilter(chkc) end
	-- 检查是否有满足条件的除外陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c33878367.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的陷阱卡加入手牌
	local g=Duel.SelectTarget(tp,c33878367.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息，表示将陷阱卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，执行将陷阱卡加入手牌操作
function c33878367.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标陷阱卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
