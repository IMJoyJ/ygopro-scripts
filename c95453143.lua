--ワンハンドレッド・アイ・ドラゴン
-- 效果：
-- 暗属性调整＋调整以外的恶魔族怪兽1只以上
-- ①：1回合1次，从自己墓地把1只6星以下的暗属性效果怪兽除外才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
-- ②：这张卡被破坏送去墓地的场合发动。从卡组把1只「地缚神」怪兽加入手卡。
function c95453143.initial_effect(c)
	-- 设置同调召唤手续：暗属性调整+1只以上调整以外的恶魔族怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(Card.IsRace,RACE_FIEND),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，从自己墓地把1只6星以下的暗属性效果怪兽除外才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95453143,0))  --"获得怪物效果"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c95453143.cost)
	e1:SetOperation(c95453143.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏送去墓地的场合发动。从卡组把1只「地缚神」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95453143,1))  --"从自己卡组把1只名字带有「地缚神」的怪兽加入手卡"
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c95453143.thcon)
	e2:SetTarget(c95453143.thtg)
	e2:SetOperation(c95453143.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：等级6以下、效果怪兽、暗属性且可以作为代价除外的怪兽
function c95453143.filter(c)
	return c:IsLevelBelow(6) and c:IsType(TYPE_EFFECT) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 效果①的启动代价：从自己墓地选择1只满足条件的怪兽除外，并记录其原本卡号
function c95453143.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c95453143.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c95453143.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetOriginalCode())
end
-- 效果①的效果处理：使这张卡直到结束阶段得到被除外怪兽的原本卡名与效果，并注册结束阶段重置效果的延迟事件
function c95453143.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		-- 这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(95453143,2))  --"复制效果结束"
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetLabelObject(e1)
		e2:SetLabel(cid)
		e2:SetOperation(c95453143.rstop)
		c:RegisterEffect(e2)
	end
end
-- 结束阶段重置复制的卡名与效果
function c95453143.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 选中这张卡并显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示“复制效果结束”
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果②的发动条件：这张卡被破坏送去墓地
function c95453143.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 效果②的靶向处理：设置检索卡组怪兽加入手卡的操作信息
function c95453143.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 过滤条件：名字带有「地缚神」的怪兽且可以加入手卡
function c95453143.thfilter(c)
	return c:IsSetCard(0x1021) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的效果处理：从卡组选择1只「地缚神」怪兽加入手卡并给对方确认
function c95453143.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只满足条件的「地缚神」怪兽
	local g=Duel.SelectMatchingCard(tp,c95453143.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
