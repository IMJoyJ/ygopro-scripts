--森羅の姫芽君 スプラウト
-- 效果：
-- 「森罗的姬芽君 幼芽」的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。自己卡组最上面的卡翻开送去墓地。那之后，可以选自己墓地1只「幼芽」怪兽在自己卡组最上面放置。
-- ②：卡组的这张卡被效果翻开送去墓地的场合，宣言1～8的任意等级才能发动。这张卡从墓地特殊召唤，这张卡的等级变成宣言的等级。
function c20579538.initial_effect(c)
	-- 创建效果e1，描述为“翻开卡组”，类别为卡组破坏(CATEGORY_DECKDES)，类型为起动效果(EFFECT_TYPE_IGNITION)，发动条件为在怪兽区(LOCATION_MZONE)，限制每回合使用次数为1次。设置该效果的费用、目标和操作。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20579538,0))  --"翻开卡组"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,20579538)
	e1:SetCost(c20579538.cost)
	e1:SetTarget(c20579538.target)
	e1:SetOperation(c20579538.operation)
	c:RegisterEffect(e1)
	-- 创建效果e2，描述为“特殊召唤”，类别为特殊召唤(CATEGORY_SPECIAL_SUMMON)，类型为单次触发效果(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)，属性为延迟生效(EFFECT_FLAG_DELAY)，触发条件为送入墓地(EVENT_TO_GRAVE)，限制每回合使用次数为1次。设置该效果的条件、目标和操作。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20579538,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,20579539)
	e2:SetCondition(c20579538.spcon)
	e2:SetTarget(c20579538.sptg)
	e2:SetOperation(c20579538.spop)
	c:RegisterEffect(e2)
end
-- 定义c20579538.cost函数，用于处理解放这张卡作为费用的逻辑。如果检查标志chk为0，则返回是否可以解放当前卡片；否则，解放当前卡片并指定理由为REASON_COST。
function c20579538.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以REASON_COST原因解放e:GetHandler()（即当前卡），返回值是实际解放的数量。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义c20579538.target函数，用于处理确认玩家是否可以从卡组顶端送去1张卡的处理逻辑。如果检查标志chk为0，则返回玩家tp是否可以把卡组最上面的1张卡送去墓地。
function c20579538.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果检查标志为0，则判断当前玩家是否可以把卡组顶端1张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 定义c20579538.tdfilter函数，用于过滤墓地的「幼芽」怪兽。返回满足以下条件的卡片：属于卡组0xa6、类型为怪兽(TYPE_MONSTER)并且可以被送入卡组。
function c20579538.tdfilter(c)
	return c:IsSetCard(0xa6) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 定义c20579538.operation函数，用于处理效果e1的操作逻辑。首先检查玩家是否可以从卡组顶端送去1张卡；如果不能则返回。确认卡组最上方1张卡，获取卡组最上方的1张卡，禁用洗切卡组的检测，将卡组最上面的卡送入墓地，然后从墓地选择一只「幼芽」怪兽放置在卡组的最上面。
function c20579538.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果玩家不能把卡组顶端1张卡送去墓地则返回。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认玩家tp的卡组最上方1张卡。
	Duel.ConfirmDecktop(tp,1)
	-- 获取玩家tp卡组最上方的1张卡，并将其存储在局部变量g中。
	local g=Duel.GetDecktopGroup(tp,1)
	-- 禁用洗切卡组检测，防止在效果处理结束后自动洗切卡组。
	Duel.DisableShuffleCheck()
	-- 将卡组顶端的卡送入墓地，理由为效果(REASON_EFFECT)和翻开(REASON_REVEAL)。如果送去墓地的数量为0则返回。
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)==0 then return end
	-- 使用辅助函数aux.NecroValleyFilter和tdfilter过滤墓地中的「幼芽」怪兽，并将结果存储在局部变量dg中。
	local dg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c20579538.tdfilter),tp,LOCATION_GRAVE,0,nil)
	-- 如果墓地存在符合条件的卡片并且玩家选择是（通过Duel.SelectYesNo），则中断当前效果，提示玩家选择要返回卡组的卡片，将选定的卡片送入卡组顶端。
	if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(20579538,2)) then  --"是否把自己墓地1只「幼芽」怪兽在卡组最上面放置"
		-- 中断当前效果，使之后的效果处理视为不同时处理。
		Duel.BreakEffect()
		-- 向玩家tp发送提示信息，要求其选择要返回卡组的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local tg=dg:Select(tp,1,1,nil)
		-- 手动为tg显示被选为对象的动画效果，并记录这些卡被选为对象。
		Duel.HintSelection(tg)
		-- 将选定的卡片tg送入卡组顶端，理由为效果(REASON_EFFECT)。
		Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- 定义c20579538.spcon函数，用于判断是否可以发动特殊召唤效果。返回当前卡是否在卡组并且被翻开。
function c20579538.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 定义c20579538.sptg函数，用于设置特殊召唤的目标。如果检查标志chk为0，则返回怪兽区是否有空位以及当前卡是否可以特殊召唤；否则，返回false。
function c20579538.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果检查标志为0，则判断玩家的怪兽区是否有空位并且当前卡是否可以被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向玩家发送提示信息，要求其宣言等级。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家tp宣言一个1到8之间的等级，并将宣言的等级存储在局部变量lv中。
	local lv=Duel.AnnounceLevel(tp,1,8)
	e:SetLabel(lv)
	-- 设置当前处理的操作信息。类别为特殊召唤(CATEGORY_SPECIAL_SUMMON)，目标卡为e:GetHandler()（即当前卡），数量为1，目标玩家为0，参数为0。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义c20579538.spop函数，用于处理特殊召唤效果的操作逻辑。如果当前卡与效果相关并且成功特殊召唤，则创建一个改变等级的效果并注册到当前卡上。
function c20579538.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果当前卡与效果相关且Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)不等于0（即特殊召唤成功），则执行以下操作。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 创建一个类型为单次(EFFECT_TYPE_SINGLE)的Effect，代码为改变等级(EFFECT_CHANGE_LEVEL)，值为e:GetLabel()（即玩家宣言的等级），重置条件为事件发生+标准重置+禁用重置。将该效果注册到当前卡c上。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
