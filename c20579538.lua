--森羅の姫芽君 スプラウト
-- 效果：
-- 「森罗的姬芽君 幼芽」的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。自己卡组最上面的卡翻开送去墓地。那之后，可以选自己墓地1只「幼芽」怪兽在自己卡组最上面放置。
-- ②：卡组的这张卡被效果翻开送去墓地的场合，宣言1～8的任意等级才能发动。这张卡从墓地特殊召唤，这张卡的等级变成宣言的等级。
function c20579538.initial_effect(c)
	-- ①：把这张卡解放才能发动。自己卡组最上面的卡翻开送去墓地。那之后，可以选自己墓地1只「幼芽」怪兽在自己卡组最上面放置。
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
	-- ②：卡组的这张卡被效果翻开送去墓地的场合，宣言1～8的任意等级才能发动。这张卡从墓地特殊召唤，这张卡的等级变成宣言的等级。
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
-- 支付效果代价：解放自己
function c20579538.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从场上解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 准备阶段：确认卡组最上方的卡
function c20579538.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将卡组最上方的1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 过滤函数：筛选墓地中的「幼芽」怪兽
function c20579538.tdfilter(c)
	return c:IsSetCard(0xa6) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果处理：翻开卡组最上方的卡并送入墓地，若存在符合条件的墓地怪兽则可选择将其放回卡组最上方
function c20579538.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以将卡组最上方的1张卡送去墓地
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认玩家卡组最上方的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取玩家卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	-- 禁用洗牌检测，防止后续操作自动洗切卡组
	Duel.DisableShuffleCheck()
	-- 将翻开的卡送入墓地
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)==0 then return end
	-- 从墓地中筛选出符合条件的「幼芽」怪兽
	local dg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c20579538.tdfilter),tp,LOCATION_GRAVE,0,nil)
	-- 判断是否有符合条件的墓地怪兽且玩家选择是否发动此效果
	if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(20579538,2)) then  --"是否把自己墓地1只「幼芽」怪兽在卡组最上面放置"
		-- 中断当前效果处理流程，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要放回卡组的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local tg=dg:Select(tp,1,1,nil)
		-- 显示所选卡片被选为对象的动画效果
		Duel.HintSelection(tg)
		-- 将选定的怪兽放回卡组最上方
		Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- 判断此卡是否因翻开而送入墓地
function c20579538.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 准备阶段：判断是否可以特殊召唤此卡
function c20579538.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位可进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言一个1~8之间的等级
	local lv=Duel.AnnounceLevel(tp,1,8)
	e:SetLabel(lv)
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡从墓地特殊召唤，并根据宣言的等级改变其等级
function c20579538.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能被特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 将此卡的等级更改为玩家宣言的等级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
