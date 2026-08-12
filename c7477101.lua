--時空の七皇
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把额外卡组1只「No.101」～「No.107」其中任意种的「No.」超量怪兽给对方观看才能发动。种族或属性和给人观看的怪兽相同而持有和那只怪兽的阶级相同数值的等级的1只怪兽从卡组加入手卡。那之后，选自己1张手卡回到卡组最上面。这张卡的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册这张卡发动时的效果处理。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把额外卡组1只「No.101」～「No.107」其中任意种的「No.」超量怪兽给对方观看才能发动。种族或属性和给人观看的怪兽相同而持有和那只怪兽的阶级相同数值的等级的1只怪兽从卡组加入手卡。那之后，选自己1张手卡回到卡组最上面。这张卡的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
-- 过滤额外卡组中符合条件的「No.101」～「No.107」超量怪兽，且卡组中存在可检索的对应怪兽。
function s.thfilter1(c,tp)
	-- 获取该超量怪兽的「No.」编号。
	local no=aux.GetXyzNumber(c)
	return no and no>=101 and no<=107 and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and not c:IsPublic()
		-- 检查卡组中是否存在满足检索条件的怪兽（与展示怪兽属性或种族相同，且等级与阶级相同）。
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,c:GetAttribute(),c:GetRace(),c:GetRank())
end
-- 过滤卡组中与展示怪兽种族或属性相同、等级与展示怪兽阶级相同且能加入手卡的怪兽。
function s.thfilter2(c,att,race,rk)
	return (c:IsRace(race) or c:IsAttribute(att)) and c:IsLevel(rk)
		and c:IsAbleToHand()
end
-- 效果发动的目标过滤与准备工作（展示额外卡组怪兽并记录其属性、种族、阶级，设置操作信息）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：额外卡组是否存在可展示的「No.101」～「No.107」超量怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 提示玩家选择要给对方确认（展示）的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从额外卡组选择1只满足条件的「No.101」～「No.107」超量怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 给对方玩家确认（展示）选中的额外卡组怪兽。
	Duel.ConfirmCards(1-tp,tc)
	e:SetLabel(tc:GetAttribute(),tc:GetRace(),tc:GetRank())
	-- 设置连锁信息：预计将1张手卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置连锁信息：预计从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：将符合条件的怪兽加入手卡，然后将1张手卡放回卡组最上面，并适用额外卡组特殊召唤限制。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local att,race,rk=e:GetLabel()
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只与展示怪兽种族或属性相同、等级与阶级相同的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,att,race,rk)
	local tc2=g:GetFirst()
	-- 如果成功将选中的怪兽加入手卡。
	if tc2 and Duel.SendtoHand(tc2,nil,REASON_EFFECT)~=0 and tc2:IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,tc2)
		-- 提示玩家选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从手卡中选择1张卡。
		local dg=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Select(tp,1,1,nil)
		-- 洗切卡组（在将手卡放回卡组最上面之前，先洗切卡组以防泄露卡组顺序）。
		Duel.ShuffleDeck(tp)
		-- 洗切手卡。
		Duel.ShuffleHand(tp)
		if dg:GetCount()>0 then
			-- 中断当前效果处理，使后续的“放回卡组最上面”与“加入手卡”不视为同时处理。
			Duel.BreakEffect()
			-- 将选中的手卡送回卡组最上面。
			Duel.SendtoDeck(dg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
	-- 这张卡的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该不能从额外卡组特殊召唤超量怪兽以外怪兽的玩家限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能从额外卡组特殊召唤超量怪兽。
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
