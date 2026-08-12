--亜空間物質回送装置
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：以场上1只怪兽为对象才能发动。那只怪兽除外。那之后，这个效果除外的怪兽回到场上。
-- ②：对方的效果发动的场合，以效果被无效化的1只表侧表示怪兽为对象才能发动。那只怪兽除外。那之后，这个效果除外的怪兽回到场上。
-- ③：场上的这张卡为对象的对方的效果适用之际，这张卡直到下个回合的结束阶段除外。
local s,id,o=GetID()
-- 初始化函数，注册卡片发动、①效果（起动效果）、②效果（诱发即时效果）以及③效果（连锁处理时适用的辅助效果）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以场上1只怪兽为对象才能发动。那只怪兽除外。那之后，这个效果除外的怪兽回到场上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"除外怪兽"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- ②：对方的效果发动的场合，以效果被无效化的1只表侧表示怪兽为对象才能发动。那只怪兽除外。那之后，这个效果除外的怪兽回到场上。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"除外效果无效的怪兽"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.rmcon2)
	e3:SetTarget(s.rmtg2)
	e3:SetOperation(s.rmop2)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡为对象的对方的效果适用之际，这张卡直到下个回合的结束阶段除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_SZONE)
	-- 在连锁发生时，为这张卡注册正在连锁中的标记，用于后续判定是否被对方效果选择为对象。
	e4:SetOperation(aux.chainreg)
	c:RegisterEffect(e4)
	-- ③：场上的这张卡为对象的对方的效果适用之际，这张卡直到下个回合的结束阶段除外。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetCountLimit(1,id+o*2)
	e5:SetCondition(s.rmcon3)
	e5:SetOperation(s.rmop3)
	c:RegisterEffect(e5)
end
-- 过滤函数：筛选可以被除外的怪兽。
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
-- ①效果的发动准备：检查场上是否存在可除外的怪兽，并让玩家选择1只怪兽作为对象，设置除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc) end
	-- 检查场上（双方怪兽区）是否存在至少1只可以被除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 在客户端显示提示信息，要求玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择场上1只可以被除外的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，表明此效果的处理包含将选中的1张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果的处理：将对象怪兽暂时除外，若成功除外则使其回到场上。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍适用此效果且为怪兽，将其以效果原因暂时除外，并确认其成功进入除外区。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and not tc:IsReason(REASON_REDIRECT) and tc:IsLocation(LOCATION_REMOVED) then
		-- 中断当前效果处理，使后续的“回到场上”处理与“除外”不视为同时进行。
		Duel.BreakEffect()
		-- 将被暂时除外的怪兽返回到场上。
		Duel.ReturnToField(tc)
	end
end
-- ②效果的发动条件：对方的效果发动。
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤函数：筛选场上表侧表示、效果被无效化且可以被除外的怪兽。
function s.rmfilter2(c)
	return c:IsAbleToRemove() and c:IsDisabled() and c:IsFaceup()
end
-- ②效果的发动准备：检查场上是否存在符合条件的效果无效怪兽，并让玩家选择1只作为对象，设置除外操作信息。
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rmfilter2(chkc) end
	-- 检查场上是否存在至少1只表侧表示、效果被无效化且可以被除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 在客户端显示提示信息，要求玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择场上1只符合条件的效果无效怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.rmfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，表明此效果的处理包含将选中的1张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果的处理：将对象怪兽暂时除外，若成功除外则使其回到场上。
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍适用此效果且为怪兽，将其以效果原因暂时除外，并确认其成功进入除外区。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and not tc:IsReason(REASON_REDIRECT) and tc:IsLocation(LOCATION_REMOVED) then
		-- 中断当前效果处理，使后续的“回到场上”处理与“除外”不视为同时进行。
		Duel.BreakEffect()
		-- 将被暂时除外的怪兽返回到场上。
		Duel.ReturnToField(tc)
	end
end
-- ③效果的发动条件：对方发动的效果以场上的这张卡为对象。
function s.rmcon3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(FLAG_ID_CHAINING)==0 then return false end
	if ep==tp then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取引发连锁的效果所选择的对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c)then return false end
	return true
end
-- ③效果的处理：将这张卡暂时除外，并注册一个在下个回合结束阶段将其返回场上的延迟效果。
function s.rmop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡可以被除外，将其以效果原因暂时除外，并确认其原本卡号正确。
	if c:IsAbleToRemove() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
	-- ③：场上的这张卡为对象的对方的效果适用之际，这张卡直到下个回合的结束阶段除外。
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将当前回合数记录在效果的Label中，以便后续判断是否已经到了下个回合。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		-- 将用于返回场上的延迟效果注册给玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟返回场上效果的具体处理函数。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 确认当前回合不是除外发生的回合（即已到达下个回合），且该卡仍处于除外状态。
	if Duel.GetTurnCount()~=e:GetLabel() and ec:IsLocation(LOCATION_REMOVED) then
		-- 将被除外的这张卡返回到场上。
		Duel.ReturnToField(e:GetLabelObject())
	end
end
