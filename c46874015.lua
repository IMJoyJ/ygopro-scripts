--六武衆推参！
-- 效果：
-- 选择自己墓地1只名字带有「六武众」的怪兽才能发动。选择的怪兽从墓地特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段时破坏。
function c46874015.initial_effect(c)
	-- 选择自己墓地1只名字带有「六武众」的怪兽才能发动。选择的怪兽从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c46874015.target)
	e1:SetOperation(c46874015.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：墓地中卡名带有「六武众」且能够被当前效果特殊召唤的怪兽。
function c46874015.filter(c,e,tp)
	return c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标判定：该效果为取对象效果，需要选择自己墓地1只满足条件的「六武众」怪兽，同时还要确认自己场上主要怪兽区有可用空格。
function c46874015.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46874015.filter(chkc,e,tp) end
	-- 检查自己场上是否拥有可用的主要怪兽区空格，若没有则无法发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的「六武众」怪兽可作为效果对象。
		and Duel.IsExistingTarget(c46874015.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家弹出选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「六武众」怪兽作为这个效果的对象。
	local g=Duel.SelectTarget(tp,c46874015.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁要进行的特殊召唤操作信息登记为特殊召唤1只对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤对象怪兽，并为其设置结束阶段破坏的延迟效果；若特殊召唤不成功或格子不足则中断。
function c46874015.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上还有可用的主要怪兽区空格，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取出发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与本效果关联，且以表侧表示特殊召唤成功；成功后进入结束阶段破坏的后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(46874015,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个效果特殊召唤的怪兽在这个回合的结束阶段时破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c46874015.descon)
		e1:SetOperation(c46874015.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 将结束阶段破坏的诱发效果注册到场上，由发动者控制。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 破坏效果的条件：确认要破坏的怪兽正是本回合由这个效果特殊召唤的怪兽（通过记录字段ID和Flag防止误判）。
function c46874015.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(46874015)==e:GetLabel()
end
-- 结束阶段破坏效果的处理：对效果特殊召唤的怪兽执行破坏。
function c46874015.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将对象怪兽破坏。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
