--暗黒界の魔神王 レイン
-- 效果：
-- ①：这张卡可以让自己场上1只7星以下的「暗黑界」怪兽回到持有者手卡，从墓地特殊召唤。
-- ②：这张卡被效果从手卡丢弃去墓地的场合才能发动。从卡组把「暗黑界的魔神王 雷恩」以外的1只5星以上的「暗黑界」怪兽加入手卡。被对方的效果丢弃的场合，可以再从自己的卡组·墓地选1只4星以下的「暗黑界」怪兽在自己或者对方场上特殊召唤。
function c41406613.initial_effect(c)
	-- 效果原文内容：①：这张卡可以让自己场上1只7星以下的「暗黑界」怪兽回到持有者手卡，从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41406613,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c41406613.spcon)
	e1:SetTarget(c41406613.sptg)
	e1:SetOperation(c41406613.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡被效果从手卡丢弃去墓地的场合才能发动。从卡组把「暗黑界的魔神王 雷恩」以外的1只5星以上的「暗黑界」怪兽加入手卡。被对方的效果丢弃的场合，可以再从自己的卡组·墓地选1只4星以下的「暗黑界」怪兽在自己或者对方场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41406613,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c41406613.condition)
	e2:SetTarget(c41406613.target)
	e2:SetOperation(c41406613.operation)
	c:RegisterEffect(e2)
end
-- 规则层面作用：过滤满足条件的场上怪兽，包括：表侧表示、暗黑界卡组、7星以下、可以送入手牌作为费用
function c41406613.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x6) and c:IsLevelBelow(7) and c:IsAbleToHandAsCost()
		-- 规则层面作用：检查目标怪兽所在玩家场上是否有可用怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 规则层面作用：判断特殊召唤条件是否满足，即场上有符合条件的怪兽
function c41406613.spcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 规则层面作用：检查场上是否存在满足特殊召唤条件的怪兽
	return Duel.IsExistingMatchingCard(c41406613.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 规则层面作用：选择要送回手牌的怪兽，用于特殊召唤
function c41406613.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 规则层面作用：获取满足特殊召唤条件的怪兽组
	local g=Duel.GetMatchingGroup(c41406613.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 规则层面作用：提示玩家选择要送回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 规则层面作用：将选中的怪兽送回手牌
function c41406613.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 规则层面作用：将怪兽送回手牌作为特殊召唤的费用
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 规则层面作用：判断是否满足效果发动条件，即该卡从手牌被丢弃到墓地
function c41406613.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	e:SetLabel(c:GetPreviousControler())
	return c:IsPreviousLocation(LOCATION_HAND) and (r&(REASON_EFFECT+REASON_DISCARD))==REASON_EFFECT+REASON_DISCARD
end
-- 规则层面作用：过滤满足条件的5星以上暗黑界怪兽，不包括雷恩本人
function c41406613.filter1(c)
	return c:IsSetCard(0x6) and c:IsAbleToHand() and c:IsLevelAbove(5) and not c:IsCode(41406613)
end
-- 规则层面作用：设置效果处理时要处理的分类，包括加入手牌、搜索、特殊召唤等
function c41406613.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否卡组中存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41406613.filter1,tp,LOCATION_DECK,0,1,nil) end
	if rp==1-tp and tp==e:GetLabel() then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	end
	-- 规则层面作用：设置效果处理信息，指定要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：过滤满足条件的4星以下暗黑界怪兽，可特殊召唤到自己或对方场上
function c41406613.filter2(c,e,tp,ft,ft2)
	return c:IsSetCard(0x6) and c:IsLevelBelow(4)
		and ((ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP))
			or (ft2>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
-- 规则层面作用：处理效果发动后的完整流程，包括检索、确认、选择是否特殊召唤
function c41406613.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取自己场上可用怪兽区域数量
	local ft=Duel.GetMZoneCount(tp)
	-- 规则层面作用：获取对方场上可用怪兽区域数量
	local ft2=Duel.GetMZoneCount(1-tp)
	-- 规则层面作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面作用：选择要加入手牌的卡
	local g=Duel.SelectMatchingCard(tp,c41406613.filter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 规则层面作用：判断是否成功将卡加入手牌
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 规则层面作用：确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		if rp==1-tp and tp==e:GetLabel()
			-- 规则层面作用：检查卡组或墓地中是否存在满足特殊召唤条件的怪兽
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c41406613.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,ft,ft2)
			-- 规则层面作用：询问玩家是否发动特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(41406613,2)) then  --"是否特殊召唤？"
			-- 规则层面作用：提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 规则层面作用：选择要特殊召唤的卡
			local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41406613.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,ft,ft2)
			-- 规则层面作用：中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			local tc=tg:GetFirst()
			local o1=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
			local o2=ft2>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
			local opt=0
			if o1 and o2 then
				-- 规则层面作用：选择将怪兽特殊召唤到自己场上还是对方场上
				opt=Duel.SelectOption(tp,aux.Stringid(41406613,3),aux.Stringid(41406613,4))  --"在自己场上特殊召唤/在对方场上特殊召唤"
			elseif o1 then
				opt=0
			else
				opt=1
			end
			local p=tp
			if opt==1 then p=1-tp end
			-- 规则层面作用：将选中的怪兽特殊召唤到指定场上
			Duel.SpecialSummon(tc,0,tp,p,false,false,POS_FACEUP)
		end
	end
end
