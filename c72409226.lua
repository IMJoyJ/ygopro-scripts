--マテリアクトル・エクサガルド
-- 效果：
-- 3星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1只「原质炉」怪兽特殊召唤或把1张「原质炉」魔法·陷阱卡加入手卡。
-- ②：对方把怪兽召唤·特殊召唤的场合才能发动。这张卡作为超量素材中的包含「原质炉」卡的最多2张卡加入手卡。自己墓地有通常怪兽存在的场合，可以再让场上1张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 添加超量召唤手续：3星怪兽×2只以上
	aux.AddXyzProcedure(c,nil,3,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。从卡组把1只「原质炉」怪兽特殊召唤或把1张「原质炉」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组操作"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thorspcost)
	e1:SetTarget(s.thorsptg)
	e1:SetOperation(s.thorspop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽召唤·特殊召唤的场合才能发动。这张卡作为超量素材中的包含「原质炉」卡的最多2张卡加入手卡。自己墓地有通常怪兽存在的场合，可以再让场上1张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"超量素材回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 取除这张卡1个超量素材的发动代价
function s.thorspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤可从卡组特殊召唤的「原质炉」怪兽或加入手卡的「原质炉」魔法·陷阱卡
function s.thorspfilter(c,e,tp)
	if not c:IsSetCard(0x160) then return false end
	if c:IsType(TYPE_MONSTER) then
		-- 判断怪兽区是否有空位且该怪兽能否特殊召唤
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	elseif c:IsType(TYPE_SPELL+TYPE_TRAP) then
		return c:IsAbleToHand()
	end
	return false
end
-- 特殊召唤或检索效果的发动目标判定
function s.thorsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「原质炉」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thorspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 特殊召唤「原质炉」怪兽或检索「原质炉」魔法·陷阱卡效果处理
function s.thorspop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1张满足条件的「原质炉」卡
	local g=Duel.SelectMatchingCard(tp,s.thorspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		if tc:IsType(TYPE_MONSTER) then
			-- 将选中的「原质炉」怪兽表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif tc:IsType(TYPE_SPELL+TYPE_TRAP) then
			-- 将选中的「原质炉」魔法·陷阱卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方展示加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
-- 过滤由指定玩家召唤·特殊召唤的怪兽
function s.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 对方把怪兽召唤·特殊召唤的发动条件判定
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 过滤「原质炉」卡
function s.cthfilter(c)
	return c:IsSetCard(0x160)
end
-- 检查卡片组中是否包含「原质炉」卡
function s.thcheck(g)
	return g:IsExists(s.cthfilter,1,nil)
end
-- 超量素材回收效果的发动目标判定
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	if chk==0 then return g:CheckSubGroup(s.thcheck,1,2) end
end
-- 超量素材回收与弹回场上卡片效果处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return false end
	local g=c:GetOverlayGroup()
	if g:CheckSubGroup(s.thcheck,1)==false then return end
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local tg=g:SelectSubGroup(tp,s.thcheck,false,1,2)
	-- 将选中的超量素材加入手卡并确认是否成功加入手卡
	if tg and Duel.SendtoHand(tg,nil,REASON_EFFECT)~=0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		local sg=tg:Filter(Card.IsControler,nil,tp)
		if sg:GetCount()>0 then
			-- 向对方展示加入己方手卡的卡片
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切己方手卡
			Duel.ShuffleHand(tp)
		end
		local og=tg:Filter(Card.IsControler,nil,1-tp)
		if og:GetCount()>0 then
			-- 向己方展示加入对方手卡的卡片
			Duel.ConfirmCards(tp,og)
			-- 洗切对方手卡
			Duel.ShuffleHand(1-tp)
		end
		-- 判断自己墓地是否存在通常怪兽
		if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_NORMAL)
			-- 判断场上是否存在可以回到手卡的卡
			and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			-- 提示玩家选择是否让场上的卡回到手卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让场上的卡回到手卡？"
			-- 中断当前效果处理（使后续处理不同步）
			Duel.BreakEffect()
			-- 提示选择要返回手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 选择场上1张可以回到手卡的卡
			local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #rg>0 then
				-- 设置选中卡片的视觉提示动画
				Duel.HintSelection(rg)
				-- 将选中的卡送回手卡
				Duel.SendtoHand(rg,nil,REASON_EFFECT)
			end
		end
	end
end
