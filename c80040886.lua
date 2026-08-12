--碧鋼の機竜
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡特殊召唤成功的场合，以最多有自己墓地的调整数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果直到回合结束时无效。
-- ②：同调召唤的这张卡被效果破坏送去墓地的场合，以自己墓地1只调整为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片的效果与同调召唤手续
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：这张卡特殊召唤成功的场合，以最多有自己墓地的调整数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被效果破坏送去墓地的场合，以自己墓地1只调整为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 效果①（无效场上卡片效果）的靶向与发动条件判定
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查是否为合法的对方场上可无效的表侧表示卡片对象
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 获取自己墓地中调整怪兽的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_TUNER)
	-- 检查发动条件：自己墓地有调整怪兽，且对方场上存在至少1张可无效的卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择最多等同于自己墓地调整数量的对方场上的表侧表示卡片作为对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置效果处理信息为无效选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
-- 效果①（无效场上卡片效果）的效果处理
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取仍与连锁相关且表侧表示的对象卡片
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsFaceup,nil)
	-- 遍历所有符合条件的对象卡片
	for tc in aux.Next(g) do
		-- 无效与该卡相关的连锁
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那些卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那些卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那些卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- 检查效果②的发动条件：同调召唤的这张卡被效果破坏送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤自己墓地中可以加入手卡的调整怪兽
function s.thfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 效果②（墓地调整回收）的靶向与发动条件判定
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
	-- 检查发动条件：自己墓地是否存在可以加入手卡的调整怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只调整怪兽作为对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②（墓地调整回收）的效果处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的那只调整怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果相关，则将其加入手卡
	if tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
