--ティオの蟲惑魔
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，以自己墓地1只「虫惑魔」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：这张卡特殊召唤成功时，以自己墓地1张「洞」通常陷阱卡或者「落穴」通常陷阱卡为对象才能发动。那张卡在自己场上盖放。那张卡在下次的自己回合的结束阶段除外。
-- ③：这张卡不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
function c45803070.initial_effect(c)
	-- 效果原文：③：这张卡不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c45803070.efilter)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡召唤成功时，以自己墓地1只「虫惑魔」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45803070,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c45803070.sptg)
	e2:SetOperation(c45803070.spop)
	c:RegisterEffect(e2)
	-- 效果原文：②：这张卡特殊召唤成功时，以自己墓地1张「洞」通常陷阱卡或者「落穴」通常陷阱卡为对象才能发动。那张卡在自己场上盖放。那张卡在下次的自己回合的结束阶段除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45803070,1))  --"盖放"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_SSET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,45803070)
	e3:SetTarget(c45803070.settg)
	e3:SetOperation(c45803070.setop)
	c:RegisterEffect(e3)
end
-- 规则层面：使该卡免疫类型为陷阱且种族为「洞」或「落穴」的卡的效果
function c45803070.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 规则层面：过滤满足「虫惑魔」种族且能被守备表示特殊召唤的墓地怪兽
function c45803070.filter(c,e,tp)
	return c:IsSetCard(0x108a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 规则层面：设置①效果的发动条件，判断场上是否有满足条件的墓地怪兽
function c45803070.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45803070.filter(chkc,e,tp) end
	-- 规则层面：判断目标怪兽是否能特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：判断是否满足特殊召唤的条件
		and Duel.IsExistingTarget(c45803070.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择满足条件的墓地怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c45803070.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面：设置效果处理信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面：执行特殊召唤操作
function c45803070.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面：将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 规则层面：过滤满足「洞」或「落穴」种族且能盖放的陷阱卡
function c45803070.setfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89) and c:IsSSetable()
end
-- 规则层面：设置②效果的发动条件，判断场上是否有满足条件的墓地陷阱卡
function c45803070.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c45803070.setfilter(chkc) end
	-- 规则层面：判断目标陷阱卡是否能盖放
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 规则层面：判断是否满足盖放的条件
		and Duel.IsExistingTarget(c45803070.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面：提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 规则层面：选择满足条件的墓地陷阱卡作为盖放对象
	local g=Duel.SelectTarget(tp,c45803070.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 规则层面：设置效果处理信息，确定盖放的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 规则层面：执行盖放操作并设置后续除外效果
function c45803070.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 规则层面：判断目标陷阱卡是否能盖放
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		local fid=e:GetHandler():GetFieldID()
		-- 效果原文：②：这张卡特殊召唤成功时，以自己墓地1张「洞」通常陷阱卡或者「落穴」通常陷阱卡为对象才能发动。那张卡在自己场上盖放。那张卡在下次的自己回合的结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 规则层面：判断是否为当前玩家的回合
		if Duel.GetTurnPlayer()==tp then
			-- 规则层面：记录当前回合数用于后续判断
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetLabel(0)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		end
		e1:SetLabelObject(tc)
		e1:SetValue(fid)
		e1:SetCondition(c45803070.rmcon)
		e1:SetOperation(c45803070.rmop)
		-- 规则层面：注册一个回合结束时触发的效果
		Duel.RegisterEffect(e1,tp)
		tc:RegisterFlagEffect(45803070,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	end
end
-- 规则层面：判断是否为下次自己的回合结束阶段
function c45803070.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断是否为下次自己的回合结束阶段
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==tp
end
-- 规则层面：执行除外操作
function c45803070.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(45803070)==e:GetValue() then
		-- 规则层面：将目标陷阱卡以表侧表示从场上除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
