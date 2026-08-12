--黎溟界闢
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只爬虫类族怪兽解放才能发动。那只怪兽的等级每2星最多1只的「溟界衍生物」（爬虫类族·暗·2星·攻/守0）在自己场上特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己的除外状态的1只爬虫类族怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从卡组把1只爬虫类族怪兽送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（魔法卡发动）和②效果（墓地起动效果）。
function s.initial_effect(c)
	-- ①：把自己场上1只爬虫类族怪兽解放才能发动。那只怪兽的等级每2星最多1只的「溟界衍生物」（爬虫类族·暗·2星·攻/守0）在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己的除外状态的1只爬虫类族怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从卡组把1只爬虫类族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果②的发动Cost为：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数：用于选择作为解放Cost的、等级在2星以上且解放后能腾出怪兽区域的爬虫类族怪兽。
function s.cfilter(c,tp)
	-- 检查卡片是否为爬虫类族、等级是否在2星以上，以及该卡解放后是否能让玩家拥有可用的怪兽区域。
	return c:IsRace(RACE_REPTILE) and c:IsLevelAbove(2) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的发动Cost：检查并选择场上1只爬虫类族怪兽解放，并记录其等级除以2的数值。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1只满足过滤条件的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp) end
	-- 玩家选择场上1只满足过滤条件的爬虫类族怪兽。
	local tc=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetLevel()//2)
	-- 将选择的怪兽解放。
	Duel.Release(tc,REASON_COST)
end
-- 效果①的发动准备（Target）：检查是否能特殊召唤衍生物，并设置特殊召唤和衍生物生成的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家是否能够特殊召唤「溟界衍生物」（爬虫类族·暗·2星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x161,TYPES_TOKEN_MONSTER,0,0,2,RACE_REPTILE,ATTRIBUTE_DARK) end
	-- 设置当前连锁的操作信息为：生成衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置当前连锁的操作信息为：特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果①的效果处理（Operation）：在自己场上特殊召唤对应数量 of 「溟界衍生物」。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算可特殊召唤的衍生物最大数量（解放怪兽等级除以2的数值与当前可用怪兽区域数量的较小值）。
	local ct=math.min(e:GetLabel(),Duel.GetLocationCount(tp,LOCATION_MZONE))
	-- 如果可特招数量小于等于0，或者玩家无法特殊召唤该衍生物，则不处理效果。
	if ct<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x161,TYPES_TOKEN_MONSTER,0,0,2,RACE_REPTILE,ATTRIBUTE_DARK) then return end
	repeat
		-- 创建「溟界衍生物」卡片数据。
		local tk=Duel.CreateToken(tp,id+o)
		-- 逐步将衍生物以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummonStep(tk,0,tp,tp,false,false,POS_FACEUP)
		ct=ct-1
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	until ct<=0 or Duel.IsPlayerAffectedByEffect(tp,59822133) or not Duel.SelectYesNo(tp,210)
	-- 完成特殊召唤的流程。
	Duel.SpecialSummonComplete()
end
-- 过滤函数：用于选择自己除外状态的、可以回到卡组的爬虫类族怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE) and c:IsAbleToDeck()
end
-- 效果②的发动准备（Target）：选择除外状态的1只爬虫类族怪兽为对象，并设置回卡组的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查自己除外状态的卡中是否存在至少1只满足过滤条件的爬虫类族怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 给玩家发送提示信息：“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择除外状态的1只爬虫类族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 过滤函数：用于选择卡组中可以送去墓地的爬虫类族怪兽。
function s.gfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end
-- 效果②的效果处理（Operation）：使对象怪兽回到卡组，之后可以从卡组将1只爬虫类族怪兽送去墓地。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，并将其送回卡组并洗卡，若操作失败则结束处理。
	if not (tc and tc:IsRelateToEffect(e)) or Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0
		or not tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then return end
	-- 洗切玩家的卡组。
	Duel.ShuffleDeck(tp)
	-- 获取卡组中所有满足条件的爬虫类族怪兽。
	local g=Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_DECK,0,nil)
	-- 如果卡组中存在可送去墓地的爬虫类族怪兽，询问玩家是否要将其送去墓地。
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从卡组把1只爬虫类族怪兽送去墓地？"
		-- 给玩家发送提示信息：“请选择要送去墓地的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 中断当前效果处理，使后续的送去墓地处理与回卡组处理不视为同时进行。
		Duel.BreakEffect()
		-- 将选择的爬虫类族怪兽送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
