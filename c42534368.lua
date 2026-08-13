--黙する死者
-- 效果：
-- ①：以自己墓地1只通常怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能攻击。
function c42534368.initial_effect(c)
	-- ①：以自己墓地1只通常怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42534368.target)
	e1:SetOperation(c42534368.activate)
	c:RegisterEffect(e1)
end
-- 定义可选择为对象的怪兽条件：必须是通常怪兽，且可以被表侧守备表示特殊召唤。
function c42534368.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的合法性检查与对象选择：指定对象时必须是己方墓地且满足条件的通常怪兽；发动条件要求主要怪兽区有空位且墓地有符合条件的通常怪兽。
function c42534368.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42534368.filter(chkc,e,tp) end
	-- 在发动条件检查阶段，要求自己主要怪兽区域存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地存在至少1只满足过滤条件的通常怪兽可以作为对象。
		and Duel.IsExistingTarget(c42534368.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的通常怪兽作为效果对象，并将其登记为连锁对象。
	local g=Duel.SelectTarget(tp,c42534368.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本连锁将进行1只怪兽的特殊召唤，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若自己主要怪兽区仍空位，则取得选择的对象；若对象仍与效果关联且成功以表侧守备表示特殊召唤，则为其附加不能攻击的效果。
function c42534368.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区域有空位，若没有则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联（未离场等）并将其以表侧守备表示特殊召唤；若特殊召唤成功则继续附加不能攻击的永续效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的怪兽不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
