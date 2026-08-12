--マテリアクトル・ゼプトウィング
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「原质炉」卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤·反转的场合才能发动。从卡组把「原质炉仄普托翼鸟」以外的1张「原质炉」卡加入手卡。那之后，可以从自己墓地把1只3星通常怪兽加入手卡或特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：自己场上有「原质炉」卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤·反转的场合才能发动。从卡组把「原质炉仄普托翼鸟」以外的1张「原质炉」卡加入手卡。那之后，可以从自己墓地把1只3星通常怪兽加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上表侧表示的「原质炉」卡片
function s.cfilter(c)
	return c:IsSetCard(0x160) and c:IsFaceup()
end
-- 效果①的发动条件：检查自己场上是否存在「原质炉」卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「原质炉」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的发动准备与可行性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：特殊召唤自身
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中「原质炉仄普托翼鸟」以外的「原质炉」卡片
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x160) and c:IsAbleToHand()
end
-- 效果②的发动准备与可行性检查
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「原质炉」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：墓地中可以加入手牌或特殊召唤的3星通常怪兽
function s.thorspfilter(c,e,tp)
	if not c:IsType(TYPE_NORMAL) or not c:IsLevel(3) then return false end
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果②的效果处理：检索「原质炉」卡，并可选从墓地回收或特召3星通常怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足条件的「原质炉」卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 如果成功将选中的卡片加入手牌
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
		-- 检查自己墓地是否存在满足条件的3星通常怪兽（受王家长眠之谷影响）
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thorspfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
			-- 询问玩家是否发动后续效果（从墓地将1只3星通常怪兽加入手卡或特殊召唤）
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选通常怪兽？"
			-- 中断当前效果处理，使后续处理与检索不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要操作的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			-- 玩家从墓地选择1只满足条件的3星通常怪兽
			local gg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thorspfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			-- 获取自己场上可用的怪兽区域空格数
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			local hc=gg:GetFirst()
			if hc then
				-- 判断是否只能加入手牌，或者在可以特殊召唤的情况下让玩家选择加入手牌或特殊召唤
				if hc:IsAbleToHand() and (not hc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
					-- 将选中的怪兽加入手牌
					Duel.SendtoHand(hc,nil,REASON_EFFECT)
					-- 给对方玩家确认加入手牌的怪兽
					Duel.ConfirmCards(1-tp,hc)
				else
					-- 将选中的怪兽在自己场上表侧表示特殊召唤
					Duel.SpecialSummon(hc,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
