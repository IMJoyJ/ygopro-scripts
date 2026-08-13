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
-- 检查触发事件中的怪兽是否为表侧表示且为我方场上的「忍者」怪兽，用于判断“自己场上有『忍者』怪兽召唤·反转召唤·特殊召唤”这一条件。
function c26232916.thcfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x2b) and c:IsControler(tp)
end
-- ①效果的发动条件：当召唤/反转召唤/特殊召唤成功的怪兽组中存在满足条件的「忍者」怪兽时，本效果才能发动。
function c26232916.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26232916.thcfilter,1,nil,tp)
end
-- 筛选可作为对象的墓地卡片：是「忍者」怪兽或「忍法」卡，且能加入手卡。
function c26232916.thfilter(c)
	return (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2b) or c:IsSetCard(0x61))
		and c:IsAbleToHand()
end
-- ①效果的发动时处理：从自己墓地选择1只「忍者」怪兽或1张「忍法」卡作为对象，并设置加入手卡的操作信息。
function c26232916.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c26232916.thfilter(chkc) end
	-- 确认自己墓地存在至少1张满足条件的“忍者”怪兽或“忍法”卡，否则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c26232916.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家弹出选择提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张满足条件的“忍者”怪兽或“忍法”卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c26232916.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果将对象卡加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：对象卡加入手卡成功后，如果场地卡和对象卡仍与效果关联，则给当前玩家附加“不能发动该卡及同名卡效果”的封印。
function c26232916.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果对象卡（即被选择的墓地卡片）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 判断条件：本卡和对象卡仍与效果关联，且对象卡确实加入了手卡。
		and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 这个回合，自己不能作这个效果加入手卡的卡以及那些同名卡的效果的发动。②：自己场上的「忍者」怪兽或者「忍法」卡被战斗或者对方的效果破坏的场合，可以作为代替把自己墓地1只「忍者」怪兽除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c26232916.aclimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将“不能发动效果”的封印效果注册给玩家tp，持续到这个回合结束。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 封印效果的判定函数：若尝试发动的卡的效果处理卡与e1记录的卡号相同（即那张卡或其同名卡），则禁止其发动。
function c26232916.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
-- 代替破坏的判定条件：被破坏的卡必须是表侧表示且为我方场上的「忍者」怪兽或「忍法」卡，不是因为代替破坏而破坏，且破坏原因是战斗破坏或对方玩家的效果破坏。
function c26232916.repfilter(c,tp)
	return c:IsFaceup() and (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2b) or c:IsSetCard(0x61))
		and c:IsOnField() and c:IsControler(tp) and not c:IsReason(REASON_REPLACE)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 筛选可以除外的代价卡：我方墓地中存在的「忍者」怪兽，且可以作为代价除外。
function c26232916.rmfilter(c)
	return c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 作为EFFECT_DESTROY_REPLACE的Value函数：判断某张卡是否满足代替破坏条件，实际调用repfilter并传入效果控制者。
function c26232916.repval(e,c)
	return c26232916.repfilter(c,e:GetHandlerPlayer())
end
-- ②代替破坏效果的发动条件：存在满足条件的将被破坏的卡，且我方墓地存在可除外的「忍者」怪兽；满足则进入选择是否发动及选择代价的流程。
function c26232916.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c26232916.repfilter,1,nil,tp)
		-- 额外确认墓地存在至少1只可以除外作为代替的「忍者」怪兽。
		and Duel.IsExistingMatchingCard(c26232916.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动代替破坏效果（选择“是”则继续选择除外代价）。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择用于代替破坏而除外的卡（此处从墓地选择）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 从自己墓地选择1只「忍者」怪兽作为代替除外的代价，并保存到效果标签中。
		local tg=Duel.SelectMatchingCard(tp,c26232916.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		e:SetLabelObject(tg:GetFirst())
		return true
	end
	return false
end
-- 代替破坏效果处理：展示本卡，将选择的「忍者」怪兽除外，以代替原本的破坏。
function c26232916.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示该场地卡，宣告代替破坏效果适用。
	Duel.Hint(HINT_CARD,0,26232916)
	local tc=e:GetLabelObject()
	-- 将选择的「忍者」怪兽以表侧表示除外（原因包含代替），从而代替这次破坏。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
