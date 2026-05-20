--御巫神舞－二貴子
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把「御巫神舞-二贵子」以外的1张「御巫」卡送去墓地。那之后，可以从卡组把「御巫神舞-二贵子」以外的1张「御巫」魔法·陷阱卡在自己场上盖放。这张卡的发动后，直到回合结束时自己不是「御巫」怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外，把自己场上1个超量素材取除才能发动。从手卡·卡组把1只「御巫」仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片的效果①和效果②
function s.initial_effect(c)
	-- ①：从卡组把「御巫神舞-二贵子」以外的1张「御巫」卡送去墓地。那之后，可以从卡组把「御巫神舞-二贵子」以外的1张「御巫」魔法·陷阱卡在自己场上盖放。这张卡的发动后，直到回合结束时自己不是「御巫」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，把自己场上1个超量素材取除才能发动。从手卡·卡组把1只「御巫」仪式怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「御巫神舞-二贵子」以外的「御巫」卡
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x18d) and c:IsAbleToGrave()
end
-- 效果①的发动准备，检查卡组中是否存在可送墓的卡并设置送墓的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「御巫神舞-二贵子」以外的「御巫」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中「御巫神舞-二贵子」以外的、可盖放的「御巫」魔法·陷阱卡
function s.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x18d) and not c:IsCode(id) and not c:IsForbidden() and c:IsSSetable()
end
-- 效果①的处理，执行送墓、可选盖放以及注册额外卡组特召限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张「御巫神舞-二贵子」以外的「御巫」卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 如果成功将选择的卡送去墓地且该卡已在墓地存在
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 并且卡组中存在可盖放的「御巫」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 并且玩家选择进行盖放
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把「御巫」魔法·陷阱卡盖放？"
		-- 中断当前效果处理，使后续的盖放处理不与送墓同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组选择1张可盖放的「御巫」魔法·陷阱卡
		local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,sg:GetFirst())
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是「御巫」怪兽不能从额外卡组特殊召唤。②：把墓地的这张卡除外，把自己场上1个超量素材取除才能发动。从手卡·卡组把1只「御巫」仪式怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册不能从额外卡组特殊召唤「御巫」以外怪兽的限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制不能从额外卡组特殊召唤「御巫」以外的怪兽
function s.splimit(e,c)
	return not c:IsSetCard(0x18d) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果②的发动代价检查与执行
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1个超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST)
		-- 并且检查墓地的这张卡是否可以除外
		and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) end
	-- 将墓地的这张卡除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取除自己场上1个超量素材
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 过滤手卡·卡组中可以特殊召唤的「御巫」仪式怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18d) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
-- 效果②的发动准备，检查手卡·卡组中是否存在可特召的怪兽、场上是否有空位并设置特召的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组中是否存在可以特殊召唤的「御巫」仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
		-- 并且检查自己场上是否有可用的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置从手卡或卡组特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果②的处理，从手卡或卡组特殊召唤1只「御巫」仪式怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只「御巫」仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,true,POS_FACEUP)
	end
end
