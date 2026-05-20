--光征竜－スペクトル
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把1只龙族或光属性的怪兽和这张卡从手卡丢弃才能发动。从卡组把「光征龙-彩龙」以外的2只「征龙」怪兽加入手卡。
-- ②：把1只龙族或光属性的怪兽和这张卡从自己墓地除外，以自己墓地1只「极征龙-烛龙」为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含效果①（检索）和效果②（特殊召唤）的注册
function s.initial_effect(c)
	-- 记录这张卡的效果文本中记载了卡号为4965193的卡片（极征龙-烛龙）
	aux.AddCodeList(c,4965193)
	-- ①：把1只龙族或光属性的怪兽和这张卡从手卡丢弃才能发动。从卡组把「光征龙-彩龙」以外的2只「征龙」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把1只龙族或光属性的怪兽和这张卡从自己墓地除外，以自己墓地1只「极征龙-烛龙」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中可丢弃的龙族或光属性怪兽
function s.dfilter(c)
	return (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsRace(RACE_DRAGON)) and c:IsDiscardable()
end
-- 效果①的发动代价判定：自身可丢弃，且手卡中存在另一张满足过滤条件的怪兽
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		-- 检查手卡中是否存在除这张卡以外的1只龙族或光属性怪兽
		and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 给玩家发送选择要丢弃的手卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家选择手卡中除这张卡以外的1只龙族或光属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的怪兽和这张卡作为发动代价一起丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组中「光征龙-彩龙」以外的「征龙」怪兽，且能加入手卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的靶向处理：检查卡组中是否存在至少2只满足条件的「征龙」怪兽，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少2只「光征龙-彩龙」以外的「征龙」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置当前处理的连锁操作信息：从卡组将2张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择2只「征龙」怪兽加入手卡，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「征龙」怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()<2 then return end
	-- 给玩家发送选择要加入手卡的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local sg=g:Select(tp,2,2,nil)
	if sg:GetCount()>0 then
		-- 将选中的2张卡加入玩家手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤条件：墓地中可作为除外代价的龙族或光属性怪兽，且此时墓地中存在可特殊召唤的「极征龙-烛龙」
function s.costfilter(c,e,tp)
	return (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsRace(RACE_DRAGON)) and c:IsAbleToRemoveAsCost()
		-- 检查墓地中是否存在除该除外代价怪兽以外的、可特殊召唤的「极征龙-烛龙」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
-- 效果②的发动代价处理：将墓地的这张卡和另1只龙族或光属性怪兽除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查墓地中是否存在可作为除外代价的怪兽，且这张卡自身也能除外
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) end
	-- 给玩家发送选择要除外的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择墓地中1只除这张卡以外的龙族或光属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	-- 将选中的怪兽作为发动代价除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 将墓地的这张卡自身作为发动代价除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
end
-- 过滤条件：墓地中可以特殊召唤的「极征龙-烛龙」
function s.spfilter(c,e,tp)
	return c:IsCode(4965193) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向处理：选择墓地1只「极征龙-烛龙」为对象，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在可作为效果对象的「极征龙-烛龙」
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 给玩家发送选择要特殊召唤的怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择墓地中1只「极征龙-烛龙」作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前处理的连锁操作信息：将选中的1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的「极征龙-烛龙」特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关联，且不受「王家长眠之谷」的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
