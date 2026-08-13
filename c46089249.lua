--コアキリング
-- 效果：
-- 把手卡1张「核成兽的钢核」给对方观看发动。把场上表侧表示存在的1只怪兽破坏，双方受到1000分伤害。
function c46089249.initial_effect(c)
	-- 将本卡效果中提到「核成兽的钢核」的卡号36623431登记到这张卡的关联卡号列表中，用于处理与该卡相关的文本及检索识别。
	aux.AddCodeList(c,36623431)
	-- 把手卡1张「核成兽的钢核」给对方观看发动。把场上表侧表示存在的1只怪兽破坏，双方受到1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c46089249.cost)
	e1:SetTarget(c46089249.target)
	e1:SetOperation(c46089249.activate)
	c:RegisterEffect(e1)
end
-- 手牌过滤条件：该卡必须是「核成兽的钢核」（卡号36623431），且当前未处于公开状态，才能作为展示给对方的发动代价。
function c46089249.cfilter(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- 发动代价：先确认手牌中存在符合条件的「核成兽的钢核」，然后从中选择1张给对方确认，最后洗切手牌。
function c46089249.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 仅在代价检查阶段（chk==0）判定：自己手牌是否存在至少1张符合cfilter条件的「核成兽的钢核」，没有则不能发动效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c46089249.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向操作玩家tp发出“请选择给对方确认的卡”的选择提示，使随后弹出的选择框显示该提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家tp从自己的手牌中选出1张满足cfilter条件的「核成兽的钢核」，作为发动本卡要展示的代价。
	local g=Duel.SelectMatchingCard(tp,c46089249.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选出的「核成兽的钢核」展示给对方玩家（1-tp）确认，完成“给对方观看”这一代价。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切玩家tp的手牌，使展示过的那张卡在手牌中的位置不再被对方锁定或知晓。
	Duel.ShuffleHand(tp)
end
-- 对象过滤条件：选择场上表侧表示存在的怪兽作为破坏对象（c:IsFaceup()保证表侧表示）。
function c46089249.filter(c)
	return c:IsFaceup()
end
-- 目标选择阶段：确认场上存在可选的表侧怪兽后，从双方怪兽区选择1只作为对象，并设置破坏1只、双方各受1000伤害的操作信息。
function c46089249.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c46089249.filter(chkc) end
	-- chk==0时判断：双方场上是否存在至少1只表侧表示怪兽能够成为这个效果的取对象目标；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c46089249.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发出“请选择要破坏的卡”的提示，用于选择即将被破坏的对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方怪兽区选择1只表侧表示怪兽作为本卡的对象；该选择会同时把目标登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c46089249.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记连锁的破坏操作信息：本次效果将破坏所选对象，数量为1；供星尘龙等检测破坏效果的卡片或效果使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记连锁的伤害操作信息：本次效果将给予双方玩家各1000点伤害（伤害对象不是卡，所以targets为nil，target_player为PLAYER_ALL）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- 效果处理：取回发动时的对象怪兽，确认它仍表侧且与发动效果关联后将其破坏；破坏成功则依次给双方各1000伤害并完成时点处理。
function c46089249.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那1只对象怪兽（当前连锁的第一个目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 用效果原因破坏对象怪兽，返回值是实际被破坏的数量；只有破坏成功（>0）才继续执行双方伤害。
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			-- 给与对方玩家（1-tp）1000点效果伤害；is_step=true表示作为分段伤害过程的一部分，暂不立即触发时点。
			Duel.Damage(1-tp,1000,REASON_EFFECT,true)
			-- 给与自己玩家（tp）1000点效果伤害，同样以分段方式处理。
			Duel.Damage(tp,1000,REASON_EFFECT,true)
			-- 调用Duel.RDComplete()完成分段伤害/回复的时点处理，触发因受到伤害而产生的诱发效果或时点。
			Duel.RDComplete()
		end
	end
end
