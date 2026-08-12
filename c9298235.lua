--ファーニマル・クレーン
-- 效果：
-- ①：自己场上的表侧表示的「毛绒动物」怪兽被对方怪兽的攻击或者对方的效果破坏送去自己墓地时，以破坏的那1只自己怪兽为对象才能发动。那只怪兽加入手卡，自己从卡组抽1张。
function c9298235.initial_effect(c)
	-- ①：自己场上的表侧表示的「毛绒动物」怪兽被对方怪兽的攻击或者对方的效果破坏送去自己墓地时，以破坏的那1只自己怪兽为对象才能发动。那只怪兽加入手卡，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c9298235.condition)
	e1:SetTarget(c9298235.target)
	e1:SetOperation(c9298235.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的卡：自己场上表侧表示的「毛绒动物」怪兽被对方怪兽的攻击或对方的效果破坏送去自己墓地，且能加入手卡
function c9298235.filter(c,tp)
	-- 检查卡片是否因对方效果破坏，或因与对方怪兽战斗而被破坏
	return c:IsReason(REASON_DESTROY) and (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsSetCard(0xa9) and c:IsAbleToHand()
end
-- 发动条件：检查送去墓地的卡中是否存在满足条件的卡
function c9298235.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c9298235.filter,1,nil,tp)
end
-- 效果发动时的对象选择与操作信息设置
function c9298235.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c9298235.filter(chkc,tp) end
	-- 在发动阶段检查自己是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置选择卡片时的提示信息为‘加入手牌’
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g=eg:FilterSelect(tp,c9298235.filter,1,1,nil,tp)
	-- 将选中的卡设为效果的对象
	Duel.SetTargetCard(g)
	-- 设置操作信息：将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：将对象怪兽加入手卡，并从卡组抽1张卡
function c9298235.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关，且成功将其送回手卡
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
