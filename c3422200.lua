--水晶機巧－サルファフナー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，从手卡把「水晶机巧-柠晶龙」以外的1张「水晶机巧」卡丢弃才能发动。这张卡守备表示特殊召唤。那之后，自己场上1张卡破坏。
-- ②：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「水晶机巧」怪兽守备表示特殊召唤。
function c3422200.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，从手卡把「水晶机巧-柠晶龙」以外的1张「水晶机巧」卡丢弃才能发动。这张卡守备表示特殊召唤。那之后，自己场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3422200,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,3422200)
	e1:SetCost(c3422200.spcost)
	e1:SetTarget(c3422200.sptg)
	e1:SetOperation(c3422200.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「水晶机巧」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3422200,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,3422201)
	e2:SetCondition(c3422200.spcon2)
	e2:SetTarget(c3422200.sptg2)
	e2:SetOperation(c3422200.spop2)
	c:RegisterEffect(e2)
end
-- 定义代价筛选函数：判断手卡中的卡是否可作为发动代价丢弃，要求是「水晶机巧」卡、不是这张卡自身，并且可以被丢弃。
function c3422200.cfilter(c)
	return c:IsSetCard(0xea) and not c:IsCode(3422200) and c:IsDiscardable()
end
-- 第①效果的代价处理：发动前检查手卡存在可丢弃的「水晶机巧」卡（非本卡），满足后执行丢弃1张作为发动代价，丢弃原因包含COST与DISCARD。
function c3422200.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检测：手卡中是否存在至少1张满足筛选条件的「水晶机巧」卡可作为代价丢弃，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c3422200.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手卡选择并丢弃1张满足筛选条件的「水晶机巧」卡，丢弃原因设为代价（REASON_COST）并计入丢弃事件（REASON_DISCARD）。
	Duel.DiscardHand(tp,c3422200.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 第①效果的发动条件/目标设定：检查自己怪兽区域是否有空位，并且这张卡能够被表侧守备表示特殊召唤，满足条件后才允许发动。
function c3422200.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格，若没有则无法把这张卡特殊召唤，不能发动效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 登记操作信息：效果包含特殊召唤，预定将这张卡特殊召唤，数量为1，为后续相关卡片的发动检测提供信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 获取自己场上（怪兽区域和魔法陷阱区域）的全部卡片，作为可能被破坏的候选集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	if g:GetCount()>0 then
		-- 登记操作信息：效果还包含破坏，破坏候选为自己场上的全部卡，预定破坏数量为1，用于连锁中后续的破坏检测。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 第①效果的处理（实际解决）：先检查这张卡是否仍与效果关联，若是则将其表侧守备表示特殊召唤；特殊召唤成功后，中断连锁处理，再选择并破坏自己场上1张卡。
function c3422200.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤，将这张卡以表侧守备表示特殊召唤；返回值为特殊召唤成功的数量，若非0说明召唤成功。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 中断当前效果的处理，使特殊召唤与后续破坏效果不在同一时点处理（“那之后”的效果另行处理）。
		Duel.BreakEffect()
		-- 给玩家显示“请选择要破坏的卡”的提示信息，用于后续选择破坏对象时的界面提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从自己场上选择1张卡（无其他筛选条件）作为破坏对象，因为‘那之后’的破坏不取对象，所以在效果处理时选择。
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡片以效果破坏（REASON_EFFECT），完成“……自己场上1张卡破坏”。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 第②效果的发动条件：这张卡被战斗或效果破坏，且破坏之前位于场上（从场上被破坏）时，满足发动条件。
function c3422200.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义第②效果特殊召唤的筛选函数：检查卡组中的卡是否为「水晶机巧」怪兽，并且能被当前玩家以表侧守备表示特殊召唤。
function c3422200.spfilter(c,e,tp)
	return c:IsSetCard(0xea) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 第②效果的发动条件/目标设定：检查自己怪兽区域有空位，且卡组中存在符合条件的「水晶机巧」怪兽，满足条件才允许发动。
function c3422200.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格，若没有空位则不能从卡组特殊召唤，不能发动效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「水晶机巧」怪兽，若不存在则不能发动。
		and Duel.IsExistingMatchingCard(c3422200.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：效果包含从卡组特殊召唤，预定从卡组特殊召唤1只怪兽（不取对象，所以目标设为nil），位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 第②效果的处理（实际解决）：处理时再次检查怪兽区域空位，若有空位，则从卡组选择1只符合条件的「水晶机巧」怪兽，以表侧守备表示特殊召唤。
function c3422200.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时检查怪兽区域空位，若已无空位则直接结束，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示信息，用于从卡组选择特殊召唤对象时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足筛选条件的「水晶机巧」怪兽，作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c3422200.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择到的怪兽以表侧守备表示特殊召唤到自己场上，完成第②效果。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
