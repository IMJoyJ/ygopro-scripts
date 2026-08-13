--イービル・アサルト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。从卡组选1只4星以下的「邪心英雄」怪兽加入手卡或特殊召唤。这张卡的发动后，直到回合结束时自己不是「英雄」怪兽不能从额外卡组特殊召唤。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从自己墓地把1张「暗黑融合」加入手卡。
local s,id,o=GetID()
-- 注册整张卡的效果：①效果为发动型检索/特殊召唤「邪心英雄」并附加额外自肃，②效果为墓地起动回收「暗黑融合」，两个效果1回合各能使用1次。
function s.initial_effect(c)
	-- 向系统登记这张卡文本中记载了卡名「暗黑融合」（卡号94820406）。
	aux.AddCodeList(c,94820406)
	-- 对应①效果：丢弃1张手卡才能发动。从卡组选1只4星以下的「邪心英雄」怪兽加入手卡或特殊召唤。这张卡的发动后，直到回合结束时自己不是「英雄」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 对应②效果：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从自己墓地把1张「暗黑融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动条件：这张卡送去墓地的回合不能发动。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：将墓地中的这张卡从游戏中除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义①效果的代价函数：丢弃1张手卡作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：检查手卡中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行代价：从手卡选择1张卡，以『代价+丢弃』的理由送去墓地。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义①效果检索/召唤目标的筛选条件：是4星以下的「邪心英雄」怪兽，并且可加入手卡或在有可用怪兽区时可特殊召唤。
function s.thfilter(c,e,tp)
	if not (c:IsSetCard(0x6008) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4)) then return false end
	-- 获取自己场上可用主要怪兽区数量，用于判断能否特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 定义①效果的发动判定：若卡组存在1张符合条件的「邪心英雄」怪兽则可发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中存在符合条件的「邪心英雄」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- ①效果处理：从卡组选择1只符合条件的「邪心英雄」怪兽，选择加入手卡或特殊召唤；发动后附加自肃效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1张满足s.thfilter条件的「邪心英雄」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 获取可用怪兽区数量，用于判断是否选择特殊召唤分支。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 分支判断：若该卡可加入手卡且（不能特殊召唤或没有空位或玩家选择加入手卡），则执行加入手卡；否则特殊召唤。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的「邪心英雄」怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方展示这张加入手卡的卡。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的「邪心英雄」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 对应①效果后半句：『这张卡的发动后，直到回合结束时自己不是「英雄」怪兽不能从额外卡组特殊召唤。』；以及②效果：『把这个回合没有送去墓地的这张卡从墓地除外才能发动。从自己墓地把1张「暗黑融合」加入手卡。』
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将自肃效果注册到场上，使该效果影响当前发动玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义自肃过滤：不能从额外卡组特殊召唤不是「英雄」的怪兽。
function s.splimit(e,c)
	return not c:IsSetCard(0x8) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义②效果检索对象过滤：卡名必须是「暗黑融合」且可以加入手卡。
function s.thfilter2(c)
	return c:IsCode(94820406) and c:IsAbleToHand()
end
-- 定义②效果的发动判定：墓地存在1张「暗黑融合」即可发动，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认墓地存在符合条件的「暗黑融合」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本次效果要将1张墓地中的卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：从墓地选择1张「暗黑融合」加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1张满足条件的「暗黑融合」（自动排除因王家长眠之谷无法被检索的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「暗黑融合」加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示这张加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
