--マスターフレア・ヒュペリオン
-- 效果：
-- 调整＋调整以外的天使族怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把1只「代行者」怪兽或者1只有「天空的圣域」的卡名记述的怪兽从手卡·卡组·额外卡组送去墓地才能发动。直到结束阶段，这张卡当作和那只怪兽同名卡使用，得到相同效果。
-- ②：对方把卡的效果发动时，从自己的手卡·墓地把1只天使族怪兽除外，以场上1张卡为对象才能发动。那张卡除外。
function c63101468.initial_effect(c)
	-- 注册卡片效果中记述了「天空的圣域」的卡片密码
	aux.AddCodeList(c,56433456)
	-- 添加同调召唤手续：调整＋调整以外的天使族怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_FAIRY),1)
	c:EnableReviveLimit()
	-- ①：把1只「代行者」怪兽或者1只有「天空的圣域」的卡名记述的怪兽从手卡·卡组·额外卡组送去墓地才能发动。直到结束阶段，这张卡当作和那只怪兽同名卡使用，得到相同效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63101468,0))  --"复制效果"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,63101468)
	e1:SetCost(c63101468.copycost)
	e1:SetOperation(c63101468.copyop)
	c:RegisterEffect(e1)
	-- ②：对方把卡的效果发动时，从自己的手卡·墓地把1只天使族怪兽除外，以场上1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63101468,1))  --"卡片除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,63101469)
	e2:SetCondition(c63101468.rmcon)
	e2:SetCost(c63101468.rmcost)
	e2:SetTarget(c63101468.rmtg)
	e2:SetOperation(c63101468.rmop)
	c:RegisterEffect(e2)
end
-- 过滤满足「代行者」怪兽或有「天空的圣域」卡名记述的怪兽，且能作为代价送去墓地的卡片
function c63101468.copyfilter(c)
	-- 检查卡片是否为「代行者」怪兽或有「天空的圣域」卡名记述的怪兽，且是怪兽卡并能作为代价送去墓地
	return (c:IsSetCard(0x44) or aux.IsCodeListed(c,56433456)) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 复制效果（①号效果）的发动代价与可行性检测函数
function c63101468.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡、卡组、额外卡组是否存在满足条件的卡，且本回合尚未发动过此效果
	if chk==0 then return Duel.IsExistingMatchingCard(c63101468.copyfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil) and c:GetFlagEffect(63101468)==0 end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡、卡组、额外卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c63101468.copyfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetOriginalCode())
	c:RegisterFlagEffect(63101468,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 复制效果（①号效果）的效果处理函数
function c63101468.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 直到结束阶段，这张卡当作和那只怪兽同名卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		-- 直到结束阶段，这张卡当作和那只怪兽同名卡使用，得到相同效果。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(63101468,2))  --"结束复制效果"
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetLabelObject(e1)
		e2:SetLabel(cid)
		e2:SetOperation(c63101468.rstop)
		c:RegisterEffect(e2)
	end
end
-- 结束阶段重置复制卡名与效果的函数
function c63101468.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 选中自身并显示卡片被选中的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示“结束复制效果”的操作
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 检查是否为对方发动卡的效果时
function c63101468.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
-- 过滤满足天使族且能作为代价除外的卡片
function c63101468.cfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToRemoveAsCost()
end
-- 除外效果（②号效果）的发动代价与可行性检测函数
function c63101468.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡或墓地是否存在至少1只天使族怪兽可以除外
	if chk==0 then return Duel.IsExistingMatchingCard(c63101468.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡或墓地选择1只天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c63101468.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的天使族怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 除外效果（②号效果）的目标选择与效果分类注册函数
function c63101468.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 检查场上是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡片作为效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择场上1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为“除外场上的1张卡”
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 除外效果（②号效果）的效果处理函数
function c63101468.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
