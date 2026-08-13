--サイバネット・リグレッション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己对连接怪兽的特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，自己从卡组抽1张。
function c19943114.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己对连接怪兽的特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,19943114+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c19943114.condition)
	e1:SetTarget(c19943114.target)
	e1:SetOperation(c19943114.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：用于判断特殊召唤成功的怪兽是否为连接怪兽，且该怪兽是由tp玩家特殊召唤的。
function c19943114.cfilter(c,tp)
	return c:IsType(TYPE_LINK) and c:IsSummonPlayer(tp)
end
-- 发动条件：当前特殊召唤成功的怪兽组eg中，至少存在1只满足cfilter条件的连接怪兽，即自己成功特殊召唤了连接怪兽。
function c19943114.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19943114.cfilter,1,nil,tp)
end
-- 效果发动时的目标处理：需要选择场上1张卡作为对象（不能选择本卡），同时确认自己可以抽1张卡且场上有可选对象，满足这些条件效果才可发动。
function c19943114.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 检查tp玩家是否可以抽1张卡，即抽卡行为不被“不能抽卡”等效果限制。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查场上是否存在除本卡以外的至少1张卡可以作为效果对象，用于确定破坏对象是否可选。
		and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向tp玩家显示选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让tp玩家从双方场上选择1张卡（本卡除外）作为对象，并将该卡设置为当前连锁处理的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 登记破坏效果的操作信息：对象为已选择的g，数量为1，供后续时点或相关卡（如星尘龙）进行检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记抽卡效果的操作信息：目标玩家为tp，预计抽1张卡（具体抽到哪张不预先确定）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理阶段：先破坏作为对象的那张卡；如果破坏成功，则中断当前处理，再让自己抽1张卡。
function c19943114.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动效果时选择的那张对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与该效果保持关联（即没有因离场等原因失去联系），若是则将其以效果原因破坏，并确认破坏成功（返回值不为0）时才继续执行后续抽卡。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 中断当前效果链处理，使后续的抽卡被视为另一个独立处理，从而避免错时点。
		Duel.BreakEffect()
		-- 让tp玩家以效果原因从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
