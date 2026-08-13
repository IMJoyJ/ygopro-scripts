--死者への供物
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽破坏。下次的自己抽卡阶段跳过。
function c19230407.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽破坏。下次的自己抽卡阶段跳过。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c19230407.target)
	e1:SetOperation(c19230407.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，筛选出场上表侧表示的怪兽，用于作为效果对象的选择条件。
function c19230407.filter(c)
	return c:IsFaceup()
end
-- 效果发动时的目标处理：确认存在可选的表侧表示怪兽，提示玩家选择1只，并记录为对象及设置破坏的操作信息。
function c19230407.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c19230407.filter(chkc) end
	-- 发动合法性检查：若场上不存在满足条件的表侧表示怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c19230407.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从双方主要怪兽区选择1只表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c19230407.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将所选择对象的信息登记到连锁，声明本效果将破坏这1只怪兽，供后续处理及连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象怪兽，若其仍表侧表示且与该效果关联，则将其破坏；随后为发动玩家附加下一次抽卡阶段跳过的效果。
function c19230407.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽（第一张目标卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因将所选对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
	-- 下次的自己抽卡阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetTargetRange(1,0)
	-- 判断当前是否正好处于发动玩家自己的抽卡阶段；若是，则需要让跳过效果持续到下一次自己的抽卡阶段后，因此重置计数为2。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW then
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
	end
	-- 将“跳过自己的抽卡阶段”的效果注册给发动玩家，使其在下次抽卡阶段不能抽卡。
	Duel.RegisterEffect(e1,tp)
end
