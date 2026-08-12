--炎王妃 ウルカニクス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏，「炎王妃 火神不死鸟」以外的1只兽族·兽战士族·鸟兽族的炎属性怪兽从卡组加入手卡。那之后，可以把这张卡的等级变成和这个效果加入手卡的怪兽相同。
-- ②：这张卡被破坏送去墓地的场合才能发动。从卡组把1只「炎王神兽 大鹏不死鸟」守备表示特殊召唤。
local s,id,o=GetID()
-- 创建并注册三个效果：①通常召唤成功时发动的效果、②特殊召唤成功时发动的效果、③被破坏送入墓地时发动的效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被破坏送去墓地的场合才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断是否为炎属性且在手牌或场上表侧表示的怪兽
function s.dfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 过滤函数：判断是否为炎属性且为兽族·兽战士族·鸟兽族且能加入手牌的怪兽
function s.thfilter(c)
	return not c:IsCode(id) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
-- 效果发动时的检查函数：确认场上或手牌有炎属性怪兽，卡组有符合条件的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上或手牌是否有炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,e:GetHandler())
		-- 检查卡组是否有符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 获取满足条件的怪兽数组
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,e:GetHandler())
	-- 设置连锁操作信息：破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁操作信息：将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：选择破坏怪兽并检索符合条件的怪兽加入手牌，可选择改变等级
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的怪兽进行破坏
	local dg=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,aux.ExceptThisCard(e))
	-- 若成功破坏怪兽，则继续处理后续效果
	if dg:GetCount()>0 and Duel.Destroy(dg,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的怪兽加入手牌
		local thg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if thg:GetCount()>0 then
			-- 将怪兽加入手牌
			local th=Duel.SendtoHand(thg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的怪兽
			Duel.ConfirmCards(1-tp,thg)
			if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
			local lv=thg:GetFirst():GetLevel()
			-- 判断是否改变等级并询问玩家
			if th*lv>0 and c:GetLevel()~=lv and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否变成相同等级？"
				-- 中断当前效果处理，使等级改变效果生效
				Duel.BreakEffect()
				-- 创建等级改变效果
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
			end
		end
	end
end
-- 效果发动条件：该卡因破坏而进入墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤函数：判断是否为「炎王神兽 大鹏不死鸟」且能特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCode(23015896) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的检查函数：确认卡组有符合条件的怪兽且场上存在召唤空间
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否有符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组特殊召唤「炎王神兽 大鹏不死鸟」
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
