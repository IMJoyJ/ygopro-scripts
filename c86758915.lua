--魔神儀の祝誕
-- 效果：
-- 仪式怪兽的降临必需。这个卡名的②的效果1回合只能使用1次。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的「魔神仪」怪兽解放，从手卡把1只仪式怪兽仪式召唤。
-- ②：这张卡在墓地存在的场合，从手卡以及自己场上的表侧表示的卡之中把「魔神仪的祝诞」以外的1张「魔神仪」卡送去墓地才能发动。从卡组把1只「魔神仪」怪兽特殊召唤。那之后，墓地的这张卡加入手卡。
function c86758915.initial_effect(c)
	-- 注册仪式召唤效果：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的「魔神仪」怪兽解放，从手卡把1只仪式怪兽仪式召唤
	local e1=aux.AddRitualProcGreater2(c,nil,nil,nil,c86758915.mfilter,true)
	e1:SetDescription(aux.Stringid(86758915,0))
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从手卡以及自己场上的表侧表示的卡之中把「魔神仪的祝诞」以外的1张「魔神仪」卡送去墓地才能发动。从卡组把1只「魔神仪」怪兽特殊召唤。那之后，墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86758915,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,86758915)
	e2:SetCost(c86758915.thcost)
	e2:SetTarget(c86758915.thtg)
	e2:SetOperation(c86758915.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选「魔神仪」怪兽（作为仪式解放素材）
function c86758915.mfilter(c)
	return c:IsSetCard(0x117)
end
-- 过滤函数：筛选手卡或场上表侧表示的、「魔神仪的祝诞」以外的「魔神仪」卡（用于送去墓地的发动代价）
function c86758915.cfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsSetCard(0x117) and not c:IsCode(86758915)
		-- 检查该卡送去墓地后是否有可用的怪兽区域，且该卡能作为代价送去墓地
		and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
end
-- 效果②的发动代价处理函数
function c86758915.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手卡或场上是否存在可以作为代价送去墓地的「魔神仪」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c86758915.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡或场上表侧表示的「魔神仪」卡
	local g=Duel.SelectMatchingCard(tp,c86758915.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数：筛选卡组中可以特殊召唤的「魔神仪」怪兽
function c86758915.spfilter(c,e,tp)
	return c:IsSetCard(0x117) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动目标检查与操作信息设置函数
function c86758915.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查卡组中是否存在可以特殊召唤的「魔神仪」怪兽
		and Duel.IsExistingMatchingCard(c86758915.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果②的效果处理（特殊召唤并回收自身）函数
function c86758915.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若满则无法特殊召唤，直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只「魔神仪」怪兽
	local g=Duel.SelectMatchingCard(tp,c86758915.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 如果成功将选中的怪兽以表侧表示特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			-- 中断当前效果处理，使后续的回收手卡处理与特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 将墓地的这张卡加入手卡
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		end
	end
end
