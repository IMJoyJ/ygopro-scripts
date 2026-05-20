--マテリアクトル・エクサガルド
-- 效果：
-- 3星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1只「原质炉」怪兽特殊召唤或把1张「原质炉」魔法·陷阱卡加入手卡。
-- ②：对方把怪兽召唤·特殊召唤的场合才能发动。这张卡作为超量素材中的包含「原质炉」卡的最多2张卡加入手卡。自己墓地有通常怪兽存在的场合，可以再让场上1张卡回到手卡。
local s,id,o=GetID()
-- 初始化函数，注册XYZ召唤手续以及①、②两个效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续：3星怪兽2只以上
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
-- ①效果的发动代价：取除这张卡的1个超量素材
function s.thorspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤卡组中属于「原质炉」字段且能特召的怪兽或能加入手卡的魔陷卡
function s.thorspfilter(c,e,tp)
	if not c:IsSetCard(0x160) then return false end
	if c:IsType(TYPE_MONSTER) then
		-- 检查自己场上是否有空余的怪兽区域，且该怪兽是否可以进行特殊召唤
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	elseif c:IsType(TYPE_SPELL+TYPE_TRAP) then
		return c:IsAbleToHand()
	end
	return false
end
-- ①效果的发动准备：检查卡组中是否存在可操作的「原质炉」卡
function s.thorsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，确认卡组中是否存在至少1张符合条件的「原质炉」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thorspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- ①效果的效果处理：从卡组选择1张「原质炉」卡，怪兽则特殊召唤，魔陷则加入手卡
function s.thorspop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送系统提示：请选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1张满足条件的「原质炉」卡
	local g=Duel.SelectMatchingCard(tp,s.thorspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		if tc:IsType(TYPE_MONSTER) then
			-- 将选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif tc:IsType(TYPE_SPELL+TYPE_TRAP) then
			-- 将选中的魔法·陷阱卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
-- 过滤由对方玩家召唤·特殊召唤的怪兽
function s.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- ②效果的发动条件：对方成功召唤·特殊召唤了怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 过滤属于「原质炉」字段的卡片
function s.cthfilter(c)
	return c:IsSetCard(0x160)
end
-- 检查选中的超量素材卡片组中是否至少包含1张「原质炉」卡
function s.thcheck(g)
	return g:IsExists(s.cthfilter,1,nil)
end
-- ②效果的发动准备：检查超量素材中是否存在包含「原质炉」卡的1到2张卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	if chk==0 then return g:CheckSubGroup(s.thcheck,1,2) end
end
-- ②效果的效果处理：将超量素材中包含「原质炉」卡的最多2张卡加入手卡，若自己墓地有通常怪兽存在，可选择让场上1张卡回到手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return false end
	local g=c:GetOverlayGroup()
	if g:CheckSubGroup(s.thcheck,1)==false then return end
	-- 发送系统提示：请选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local tg=g:SelectSubGroup(tp,s.thcheck,false,1,2)
	-- 如果选择了卡片，且成功将这些卡片送回手卡，并且其中至少有1张卡确实到达了手卡
	if #tg>0 and Duel.SendtoHand(tg,nil,REASON_EFFECT)~=0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		local sg=tg:Filter(Card.IsControler,nil,tp)
		if sg:GetCount()>0 then
			-- 让对方玩家确认自己加入手卡的卡片
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切自己的手卡
			Duel.ShuffleHand(tp)
		end
		local og=tg:Filter(Card.IsControler,nil,1-tp)
		if og:GetCount()>0 then
			-- 让自己确认对方加入手卡的卡片（处理素材中原本属于对方的卡片回到对方手卡的情况）
			Duel.ConfirmCards(tp,og)
			-- 洗切对方的手卡
			Duel.ShuffleHand(1-tp)
		end
		-- 检查自己墓地是否存在通常怪兽
		if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_NORMAL)
			-- 检查场上是否存在可以回到手卡的卡
			and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否发动追加效果，让场上1张卡回到手卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让场上的卡回到手卡？"
			-- 中断当前效果处理，使后续的“让场上的卡回到手卡”与前面的“素材加入手卡”不视为同时处理
			Duel.BreakEffect()
			-- 发送系统提示：请选择要返回手牌的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 让玩家选择场上1张可以回到手卡的卡
			local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #rg>0 then
				-- 在场上对选中的卡片进行闪烁提示
				Duel.HintSelection(rg)
				-- 将选中的场上的卡送回持有者手卡
				Duel.SendtoHand(rg,nil,REASON_EFFECT)
			end
		end
	end
end
