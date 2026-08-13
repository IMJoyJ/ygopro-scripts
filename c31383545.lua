--XX－セイバー ダークソウル
-- 效果：
-- ①：这张卡从自己场上送去墓地的回合的结束阶段才能发动。从卡组把1只「X-剑士」怪兽加入手卡。
function c31383545.initial_effect(c)
	-- ①：这张卡从自己场上送去墓地的回合的结束阶段才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c31383545.regop)
	c:RegisterEffect(e1)
end
-- 这张卡被送去墓地时，若其之前由我方控制且位于场上，则满足“从自己场上送去墓地”的条件，在墓地内注册一个可在结束阶段发动的诱发选发效果；该效果1回合1次，到结束阶段时重置。
function c31383545.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- 从卡组把1只「X-剑士」怪兽加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(31383545,0))  --"卡组检索"
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c31383545.thtg)
		e1:SetOperation(c31383545.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 检索对象必须为含有「X-剑士」字段的怪兽，并且不能被“不能加入手卡”的效果限制。
function c31383545.filter(c)
	return c:IsSetCard(0x100d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动判定与处理信息登记：若卡组存在符合条件的检索对象则允许发动，并预先告知系统本效果将从卡组把1张卡加入手卡。
function c31383545.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检测：己方卡组中是否存在至少1张满足c31383545.filter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c31383545.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果属于回手牌/检索，将处理1张卡，来源为tp的卡组；因具体卡片在效果处理时才确定，所以目标暂设为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的「X-剑士」怪兽加入持有者手卡，并让对方确认加入手卡的卡。
function c31383545.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作玩家弹出选择提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选出1张满足c31383545.filter的卡，作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c31383545.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（nil表示加入持有者手卡），送入原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
