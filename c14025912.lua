--斬機方程式
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「斩机」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力直到回合结束时上升1000。
function c14025912.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只「斩机」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,14025912+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c14025912.target)
	e1:SetOperation(c14025912.activate)
	c:RegisterEffect(e1)
end
-- 判断一张卡是否为「斩机」怪兽，并且当前效果能否将其特殊召唤（进行常规特殊召唤判定，检查召唤条件与苏生限制）。
function c14025912.filter(c,e,tp)
	return c:IsSetCard(0x132) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标对象的合法性判断：当存在已选对象时，检查该对象是否为自己墓地的「斩机」怪兽且可被特殊召唤；当进行发动条件判定时，检查自己怪兽区是否有空位且墓地存在至少1只可特殊召唤的「斩机」怪兽。
function c14025912.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14025912.filter(chkc,e,tp) end
	-- 发动条件判定：自己主要怪兽区存在可用空格，用于后续特殊召唤对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件判定：自己墓地存在至少1只可作为对象且满足特殊召唤条件的「斩机」怪兽。
		and Duel.IsExistingTarget(c14025912.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示，供选择卡片时参考。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「斩机」怪兽，并将其设为这张卡的发动对象。
	local g=Duel.SelectTarget(tp,c14025912.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：本次效果将进行1只怪兽的特殊召唤，供其他卡片/效果进行连锁判定时使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将对象怪兽以表侧表示特殊召唤，若特殊召唤成功，则使其攻击力直到回合结束时上升1000，最后完成特殊召唤处理。
function c14025912.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，并尝试将其以表侧表示特殊召唤（使用连续特殊召唤步骤，以便在召唤成功后处理攻击力上升）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理，触发特殊召唤成功时的各种时点。
	Duel.SpecialSummonComplete()
end
