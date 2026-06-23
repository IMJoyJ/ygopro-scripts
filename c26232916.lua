--隠れ里－忍法修練の地
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「忍者」怪兽召唤·反转召唤·特殊召唤的场合，以自己墓地1只「忍者」怪兽或者1张「忍法」卡为对象才能发动。那张卡加入手卡。这个回合，自己不能作这个效果加入手卡的卡以及那些同名卡的效果的发动。
-- ②：自己场上的「忍者」怪兽或者「忍法」卡被战斗或者对方的效果破坏的场合，可以作为代替把自己墓地1只「忍者」怪兽除外。
function c26232916.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有「忍者」怪兽召唤·反转召唤·特殊召唤的场合，以自己墓地1只「忍者」怪兽或者1张「忍法」卡为对象才能发动。那张卡加入手卡。这个回合，自己不能作这个效果加入手卡的卡以及那些同名卡的效果的发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26232916,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,26232916)
	e2:SetCondition(c26232916.thcon)
	e2:SetTarget(c26232916.thtg)
	e2:SetOperation(c26232916.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ②：自己场上的「忍者」怪兽或者「忍法」卡被战斗或者对方的效果破坏的场合，可以作为代替把自己墓地1只「忍者」怪兽除外。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,26232917)
	e5:SetTarget(c26232916.reptg)
	e5:SetValue(c26232916.repval)
	e5:SetOperation(c26232916.repop)
	c:RegisterEffect(e5)
end
-- 过滤函数，用于判断场上是否有「忍者」怪兽
function c26232916.thcfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x2b) and c:IsControler(tp)
end
-- 效果条件函数，判断是否满足①效果的发动条件
function c26232916.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26232916.thcfilter,1,nil,tp)
end
-- 过滤函数，用于选择可以加入手牌的墓地「忍者」怪兽或「忍法」卡
function c26232916.thfilter(c)
	return (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2b) or c:IsSetCard(0x61))
		and c:IsAbleToHand()
end
-- 效果处理函数，选择目标并设置操作信息
function c26232916.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c26232916.thfilter(chkc) end
	-- 检查是否有满足条件的墓地目标卡
	if chk==0 then return Duel.IsExistingTarget(c26232916.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地目标卡
	local g=Duel.SelectTarget(tp,c26232916.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，指定将卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，执行将卡送入手牌并设置不能发动同名卡效果的限制
function c26232916.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 判断是否成功将卡送入手牌
		and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 创建并注册一个效果，使本回合不能发动与目标卡同名的卡
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c26232916.aclimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果发动的判断函数，判断是否为同名卡
function c26232916.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
-- 过滤函数，用于判断场上被破坏的「忍者」怪兽或「忍法」卡
function c26232916.repfilter(c,tp)
	return c:IsFaceup() and (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2b) or c:IsSetCard(0x61))
		and c:IsOnField() and c:IsControler(tp) and not c:IsReason(REASON_REPLACE)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 过滤函数，用于选择可以除外的墓地「忍者」怪兽
function c26232916.rmfilter(c)
	return c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 代替破坏效果的值函数，返回是否满足代替破坏条件
function c26232916.repval(e,c)
	return c26232916.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理函数，判断是否满足代替破坏条件
function c26232916.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c26232916.repfilter,1,nil,tp)
		-- 检查是否有满足条件的墓地除外卡
		and Duel.IsExistingMatchingCard(c26232916.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择满足条件的墓地除外卡
		local tg=Duel.SelectMatchingCard(tp,c26232916.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		e:SetLabelObject(tg:GetFirst())
		return true
	end
	return false
end
-- 代替破坏效果的处理函数，执行将卡除外
function c26232916.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动卡片的动画
	Duel.Hint(HINT_CARD,0,26232916)
	local tc=e:GetLabelObject()
	-- 将卡以除外形式移除
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
