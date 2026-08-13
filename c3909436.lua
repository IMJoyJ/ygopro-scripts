--ヴェンデット・バスタード
-- 效果：
-- 「复仇死者」仪式魔法卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把1张「复仇死者」卡除外，宣言卡的种类（怪兽·魔法·陷阱）才能发动。这个回合，对方不能把宣言的种类的卡的效果发动。
-- ②：仪式召唤的这张卡被送去墓地的场合才能发动。从卡组把1只仪式怪兽加入手卡，从卡组把1只「复仇死者」怪兽送去墓地。
function c3909436.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：从自己墓地把1张「复仇死者」卡除外，宣言卡的种类（怪兽·魔法·陷阱）才能发动。这个回合，对方不能把宣言的种类的卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3909436,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,3909436)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c3909436.cost)
	e1:SetTarget(c3909436.target)
	e1:SetOperation(c3909436.operation)
	c:RegisterEffect(e1)
	-- ②：仪式召唤的这张卡被送去墓地的场合才能发动。从卡组把1只仪式怪兽加入手卡，从卡组把1只「复仇死者」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3909436,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,3909437)
	e2:SetCondition(c3909436.thcon)
	e2:SetTarget(c3909436.thtg)
	e2:SetOperation(c3909436.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断墓地中的卡是否为「复仇死者」字段且可作为代价除外。
function c3909436.cfilter(c)
	return c:IsSetCard(0x106) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：从自己墓地选择1张「复仇死者」卡表侧除外作为发动代价。
function c3909436.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检测：确认自己墓地存在至少1张符合条件的「复仇死者」卡可供除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c3909436.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张符合条件的「复仇死者」卡。
	local g=Duel.SelectMatchingCard(tp,c3909436.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡以表侧表示除外，作为效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 发动时的目标处理：让玩家宣言一个卡的种类（怪兽·魔法·陷阱）并保存，供处理时使用。
function c3909436.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的卡的种类。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 由玩家宣言一个卡的种类（怪兽/魔法/陷阱），并将宣言结果存入效果标签中。
	e:SetLabel(Duel.AnnounceType(tp))
end
-- 效果处理：根据宣言的卡的种类，给对方场上附加“不能发动该种类卡的效果”的封印效果直到回合结束。
function c3909436.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，对方不能把宣言的种类的卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	if e:GetLabel()==0 then
		e1:SetDescription(aux.Stringid(3909436,2))
		e1:SetValue(c3909436.aclimit1)
	elseif e:GetLabel()==1 then
		e1:SetDescription(aux.Stringid(3909436,3))
		e1:SetValue(c3909436.aclimit2)
	else
		e1:SetDescription(aux.Stringid(3909436,4))
		e1:SetValue(c3909436.aclimit3)
	end
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将生成的“不能发动效果”的封印效果注册到场上，使其对对方玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- 限制判定1：对方发动的效果为怪兽卡效果时，不能发动。
function c3909436.aclimit1(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 限制判定2：对方发动的效果为魔法卡效果时，不能发动。
function c3909436.aclimit2(e,re,tp)
	return re:IsActiveType(TYPE_SPELL)
end
-- 限制判定3：对方发动的效果为陷阱卡效果时，不能发动。
function c3909436.aclimit3(e,re,tp)
	return re:IsActiveType(TYPE_TRAP)
end
-- ②效果的发动条件：这张卡是仪式召唤成功后从场上被送去墓地的场合才能发动。
function c3909436.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 检索过滤：从卡组选出1只仪式怪兽（类型包含仪式+怪兽）且能加入手卡，同时卡组中存在可送去墓地的「复仇死者」怪兽。
function c3909436.thfilter(c,tp)
	return bit.band(c:GetType(),TYPE_RITUAL+TYPE_MONSTER)==TYPE_RITUAL+TYPE_MONSTER and c:IsAbleToHand()
		-- 追加条件：保证在检索到仪式怪兽的同时，卡组中还有另一张「复仇死者」怪兽可以被送去墓地（排除刚才选中的那张）。
		and Duel.IsExistingMatchingCard(c3909436.tgfilter,tp,LOCATION_DECK,0,1,c)
end
-- 堆墓过滤：选出卡组中的「复仇死者」怪兽，要求是怪兽、字段为「复仇死者」且可以送去墓地。
function c3909436.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x106) and c:IsAbleToGrave()
end
-- ②发动时的目标处理：确认卡组中存在满足检索/堆墓组合的卡片，并设置操作信息为从卡组检索1张仪式怪兽和从卡组送墓1张「复仇死者」怪兽。
function c3909436.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否存在能够同时完成检索仪式怪兽和堆墓「复仇死者」怪兽的组合。
	if chk==0 then return Duel.IsExistingMatchingCard(c3909436.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：本次效果处理涉及从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本次效果处理涉及从卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：先从卡组选1只仪式怪兽加入手卡并给对手确认，再从卡组选1只「复仇死者」怪兽送去墓地。
function c3909436.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的仪式怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的仪式怪兽（同时保证后续有可堆墓的「复仇死者」怪兽）。
	local hg=Duel.SelectMatchingCard(tp,c3909436.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 若成功选择仪式怪兽并加入手卡，且该卡确实处于手卡，才继续执行堆墓处理。
	if hg:GetCount()>0 and Duel.SendtoHand(hg,tp,REASON_EFFECT)>0
		and hg:GetFirst():IsLocation(LOCATION_HAND) then
		-- 将加入手卡的仪式怪兽展示给对手确认。
		Duel.ConfirmCards(1-tp,hg)
		-- 提示玩家选择要送去墓地的「复仇死者」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1张满足条件的「复仇死者」怪兽。
		local g=Duel.SelectMatchingCard(tp,c3909436.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的「复仇死者」怪兽从卡组送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
