--トックス・ボックス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，以自己或对方的墓地1张卡为对象才能发动。那张卡除外。
-- ②：这张卡被除外的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化卡片的同调召唤手续与①②两个诱发效果：添加同调素材条件并设置苏生限制，然后注册除外效果和无效效果。
function s.initial_effect(c)
	-- 添加同调召唤手续：以任意调整为调整，调整以外怪兽1只以上作为素材的同调召唤素材条件。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，以自己或对方的墓地1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：这张卡是用同调召唤方式特殊召唤成功的场合才能发动。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果的发动与选择目标：从自己或对方墓地选择1张可以除外的卡作为对象，并设置除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 检查自己或对方墓地是否存在至少1张可以除外的卡，用于判断效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 显示选择提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己或对方墓地选择1张可以除外的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 将本次连锁的操作信息设置为除外1张卡，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果处理：取得对象卡，确认其仍与连锁相关且不受王家长眠之谷影响后，将其除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与当前连锁相关，且不受王家长眠之谷等效果影响，满足条件才执行除外。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象卡以表侧表示除外，除外原因为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动与选择目标：选择对方场上1张表侧表示且能被无效的卡作为对象，并设置无效操作信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 对象合法性验证：对象必须是对方场上表侧表示的卡，并且可以被无效化效果选中。
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 检查对方场上是否存在至少1张表侧表示且可被无效的卡，用于判断效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家从对方场上选择1张表侧表示且可被无效的卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 将本次连锁的操作信息设置为无效1张卡，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ②效果处理：若对象仍表侧且在场上且能被此效果无效，则无效其相关连锁，并赋予其无效化效果（无效怪兽效果与持续效果，陷阱怪兽场合额外无效陷阱怪兽化），持续到回合结束。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这个效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与对象卡相关的连锁无效化，并在对象变成里侧表示时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
