--剛鬼マシン・スープレックス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和手卡1只「刚鬼」怪兽给对方观看才能发动。那2只特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「刚鬼」怪兽不能特殊召唤。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 魔神风车过肩摔霸王龙」以外的1张「刚鬼」卡加入手卡。
local s,id,o=GetID()
-- 创建两个效果，①为起动效果，②为诱发效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡和手卡1只「刚鬼」怪兽给对方观看才能发动。那2只特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「刚鬼」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 魔神风车过肩摔霸王龙」以外的1张「刚鬼」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义用于判断是否满足特殊召唤条件的过滤函数
function s.costfilter(c,e,tp)
	return c:IsSetCard(0xfc) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理①效果的费用，需要选择一张手卡中的「刚鬼」怪兽作为费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足①效果的费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张满足条件的卡作为费用
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c,e,tp):GetFirst()
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,sc)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"因「刚鬼 魔神风车过肩摔霸王龙」的效果被观看"
	sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"因「刚鬼 魔神风车过肩摔霸王龙」的效果被观看"
end
-- 判断①效果是否可以发动，检查是否受到青眼精灵龙影响、是否能特殊召唤、场上是否有足够空间
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not e:GetHandler():IsPublic() end
	-- 设置操作信息，表示将要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 执行①效果的处理，将选中的2只怪兽特殊召唤，并设置限制非刚鬼怪兽不能特殊召唤的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(Card.IsRelateToChain,nil)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) or not sc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	if fg:GetCount()~=2 then return end
	-- 执行特殊召唤操作
	if Duel.SpecialSummon(fg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 遍历特殊召唤的怪兽，为每只怪兽设置限制效果
		for tc in aux.Next(fg) do
			-- 「刚鬼 魔神风车过肩摔霸王龙」的效果特殊召唤
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,3))  --"「刚鬼 魔神风车过肩摔霸王龙」的效果特殊召唤"
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
			tc:RegisterEffect(e1,true)
		end
	end
end
-- 限制非刚鬼怪兽不能特殊召唤的效果函数
function s.splimit(e,c)
	return not c:IsSetCard(0xfc)
end
-- 判断②效果是否可以发动，检查该卡是否从场上送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义用于检索的过滤函数
function s.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 设置②效果的目标，准备从卡组检索一张「刚鬼」卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足②效果的发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行②效果的处理，从卡组检索一张「刚鬼」卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
