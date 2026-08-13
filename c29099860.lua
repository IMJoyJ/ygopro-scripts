--剛鬼マシン・スープレックス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和手卡1只「刚鬼」怪兽给对方观看才能发动。那2只特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「刚鬼」怪兽不能特殊召唤。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 魔神风车过肩摔霸王龙」以外的1张「刚鬼」卡加入手卡。
local s,id,o=GetID()
-- 注册此卡的两个效果：效果①为手卡起动效果，以展示手卡中自身和另一只「刚鬼」怪兽为代价特殊召唤那2只，并附加后续自肃；效果②为场上送去墓地的诱发检索效果，从卡组将本卡名以外的「刚鬼」卡加入手卡；两个效果均设定了同名卡1回合1次的发动次数限制。
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
-- 费用筛选函数：用于从手牌挑选可作为展示/特殊召唤对象的「刚鬼」怪兽，要求其卡名属于「刚鬼」字段、是怪兽卡、当前不处于公开状态且能够被特殊召唤。
function s.costfilter(c,e,tp)
	return c:IsSetCard(0xfc) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动代价：从手牌中选择自身以外的1只符合条件的「刚鬼」怪兽与自身作为展示对象，向对方展示选择的那只怪兽（发动时自身已在手牌公开），然后洗切手牌，将选择的怪兽与该效果建立关联并存入效果标签，同时给自身和选择的怪兽附加“因本卡效果被观看”的客户端提示标记。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在cost检测阶段（chk==0），检查手牌中是否存在至少1张除自身外满足s.costfilter条件的「刚鬼」怪兽，以决定是否满足发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 弹出选择提示框，标题设为“请选择给对方确认的卡”，引导玩家选择要展示给对方的手牌怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌中选出1张符合条件的「刚鬼」怪兽（自动排除自身），并取得选中的卡作为cost对象。
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c,e,tp):GetFirst()
	-- 将选中的「刚鬼」怪兽给对方玩家确认，对应效果原文中的“给对方观看”。
	Duel.ConfirmCards(1-tp,sc)
	-- 由于手牌曾给对方确认，此操作后洗切自己的手牌，防止手牌顺序信息泄露。
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"因「刚鬼 魔神风车过肩摔霸王龙」的效果被观看"
	sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"因「刚鬼 魔神风车过肩摔霸王龙」的效果被观看"
end
-- ①效果发动目标的合法性检测（chk==0）：确认自己没有被【青眼精灵龙】的“不能同时特殊召唤2只以上怪兽”效果限制，自身能够被特殊召唤，自己场上主要怪兽区空位大于1，且自身当前不处于公开状态，全部满足时效果才能发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认自己的主要怪兽区至少2个空位，用于同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not e:GetHandler():IsPublic() end
	-- 设置操作信息：本次连锁将进行2只怪兽从手牌的特殊召唤，供后续时点判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- ①效果处理：取得自身和cost阶段选择的「刚鬼」怪兽，组成两卡集合；若两张卡仍与本效果关联，且场上空位足够、两张卡均可特殊召唤，则将它们表侧表示同时特殊召唤。成功后，为每只特殊召唤的怪兽各注册一个永续效果：只要该怪兽在自己场上表侧表示存在，自己不能特殊召唤「刚鬼」以外的怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(Card.IsRelateToChain,nil)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 再次确认场上主要怪兽区空位不少于2，若不足则中止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) or not sc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	if fg:GetCount()~=2 then return end
	-- 将两张卡同时表侧表示特殊召唤到自己的主要怪兽区；若特殊召唤成功（返回数量不为0），则继续注册后续自肃效果。
	if Duel.SpecialSummon(fg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 遍历特殊召唤成功的每只怪兽，分别给它们注册后续的召唤限制效果。
		for tc in aux.Next(fg) do
			-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「刚鬼」怪兽不能特殊召唤。
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
-- 自肃效果的目标过滤函数：满足“不是「刚鬼」字段”的怪兽会被禁止特殊召唤。
function s.splimit(e,c)
	return not c:IsSetCard(0xfc)
end
-- ②效果的发动条件：判定此卡被送去墓地前的所在位置为场上（即从场上送入墓地）。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索过滤函数：从卡组筛选「刚鬼」字段、卡名不是本卡（id）自身且能够加入手牌的卡。
function s.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(id) and c:IsAbleToHand()
end
-- ②效果的发动目标和操作信息：在发动时检查卡组是否存在1张符合条件的「刚鬼」卡，并设置本连锁将从卡组把1张卡加入手牌。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在target阶段（chk==0）检查卡组中是否存在至少1张满足s.thfilter的「刚鬼」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次检索效果将把1张卡从卡组加入手牌（CATEGORY_TOHAND+CATEGORY_SEARCH）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张符合条件的「刚鬼」卡加入手牌，并向对方展示加入手牌的卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，标题为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足s.thfilter的「刚鬼」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的那张卡给对方玩家确认，对应检索后展示的效果。
		Duel.ConfirmCards(1-tp,g)
	end
end
