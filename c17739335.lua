--呪眼の王 ザラキエル
-- 效果：
-- 「咒眼」怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：攻击力2600以上的怪兽为素材作连接召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡有「太阴之咒眼」装备的场合，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果在对方回合也能发动。
-- ③：这张卡的②的效果发动的场合，下次的准备阶段发动。选这张卡所连接区1只效果怪兽，那个效果无效。
function c17739335.initial_effect(c)
	-- 为这张卡添加连接召唤手续，要求使用2只以上「咒眼」连接怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x129),2)
	c:EnableReviveLimit()
	-- “①：攻击力2600以上的怪兽为素材作连接召唤的这张卡在同1次的战斗阶段中可以作2次攻击。”中的“攻击力2600以上的怪兽为素材作连接召唤的这张卡”的判定记录部分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c17739335.regcon)
	e1:SetOperation(c17739335.regop)
	c:RegisterEffect(e1)
	-- “①：攻击力2600以上的怪兽为素材作连接召唤的这张卡在同1次的战斗阶段中可以作2次攻击。”中的素材条件检查部分，即是否存在攻击力2600以上的素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c17739335.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- “①：攻击力2600以上的怪兽为素材作连接召唤的这张卡在同1次的战斗阶段中可以作2次攻击。”中的“在同1次的战斗阶段中可以作2次攻击”。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	e3:SetCondition(c17739335.macon)
	c:RegisterEffect(e3)
	-- “②：这张卡有「太阴之咒眼」装备的场合，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果在对方回合也能发动。”
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(17739335,0))  --"卡片破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,17739335)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(c17739335.descon)
	e4:SetTarget(c17739335.destg)
	e4:SetOperation(c17739335.desop)
	c:RegisterEffect(e4)
	-- “③：这张卡的②的效果发动的场合，下次的准备阶段发动。选这张卡所连接区1只效果怪兽，那个效果无效。”
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(17739335,1))  --"效果无效"
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c17739335.discon)
	e5:SetTarget(c17739335.distg)
	e5:SetOperation(c17739335.disop)
	c:RegisterEffect(e5)
end
-- 判断该效果是否可执行：只有这张卡为连接召唤成功，且内部标记e1的Label为1（素材包含攻击力2600以上的怪兽）时才返回真。
function c17739335.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 给这张卡注册一个标记（17739336），表示其以攻击力2600以上的怪兽为素材连接召唤，并附加客户端提示文案；该标记随离场等标准情况重置。
function c17739335.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(17739336,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(17739335,2))  --"攻击力2600以上的怪兽作为连接素材"
end
-- 判定这张卡是否带有标记17739336（即以攻击力2600以上的怪兽为素材连接召唤过），作为获得额外攻击次数的条件。
function c17739335.macon(e)
	return e:GetHandler():GetFlagEffect(17739336)>0
end
-- 在连接召唤素材确定时检查实际素材：若素材中存在攻击力2600以上的怪兽，则将e1的Label设为1，否则设为0，供特殊召唤成功时决定是否登记额外攻击标记。
function c17739335.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttackAbove,1,nil,2600) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ②效果的发动条件：这张卡当前装备有「太阴之咒眼」（编号44133040）。
function c17739335.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsCode,1,nil,44133040)
end
-- ②效果的发动处理：选择对方场上1张卡为对象，设置破坏操作信息；同时根据发动时是否处于准备阶段，注册用于③效果判定“下次准备阶段”的特殊标记。
function c17739335.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动合法性检查：确认对方场上有至少1张卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家弹出选择提示“请选择要破坏的卡”，并准备后续的选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张卡作为对象，并将该卡登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 向系统登记当前连锁将进行破坏操作，对象为已选择的卡，数量为1，供相关效果/时点判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 判断当前是否为准备阶段，这用于决定②效果发动标记的储存方式，以便③效果在正确的“下次准备阶段”触发。
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 在准备阶段发动②效果时，给这张卡注册一个特殊标记（持续到下次准备阶段），并将当前回合数作为标签保存；③效果通过比对标签与当前回合数来推迟到下次准备阶段触发。
		e:GetHandler():RegisterFlagEffect(17739335,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(17739335,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,1,0)
	end
end
-- ②效果处理：取得选择的对象，若该对象仍与效果关联，则将其破坏。
function c17739335.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ③效果的触发条件：存在②效果发动的标记，并且当前回合数已不是标记记录的回合数，即已进入下一个准备阶段。
function c17739335.discon(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(17739335)
	-- 返回真条件：标记存在且标记中的回合数与当前回合数不同，从而避免在当前准备阶段立即触发。
	return tid and tid~=Duel.GetTurnCount()
end
-- ③效果选择无效对象的过滤函数：对象必须是表侧表示的效果怪兽、未处于无效状态，且位于这张卡的连接区。
function c17739335.disfilter(c,g)
	-- 过滤条件的具体实现：目标怪兽可通过aux.NegateEffectMonsterFilter检测（表侧、效果怪兽、未被无效），且属于这张卡的连接区集合g。
	return aux.NegateEffectMonsterFilter(c) and g:IsContains(c)
end
-- ③效果发动时（必发）的取整处理：取得这张卡连接区中所有可无效的效果怪兽，并设置无效操作信息；具体选怪在处理时进行。
function c17739335.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local cg=e:GetHandler():GetLinkedGroup()
	-- 从双方场上取得所有满足过滤条件的怪兽（即这张卡连接区中的可无效效果怪兽）作为候选集合。
	local g=Duel.GetMatchingGroup(c17739335.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
	-- 向系统登记当前连锁将进行无效操作，候选集合为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ③效果处理：从连接区候选怪兽中选择1只，对其应用无效化处理（包括使卡片效果无效和相关连锁无效）。
function c17739335.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetLinkedGroup()
	-- 实际处理时重新获取这张卡连接区中可无效的效果怪兽候选组。
	local g=Duel.GetMatchingGroup(c17739335.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
	if g:GetCount()>0 then
		-- 向玩家弹出选择提示“请选择要无效的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽显示为对象选择动画，并记录该卡被选择。
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		-- 使与所选怪兽相关的连锁效果无效化，并在回合结束时重置该无效关联。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- “③：这张卡的②的效果发动的场合，下次的准备阶段发动。选这张卡所连接区1只效果怪兽，那个效果无效。”中的“那个效果无效”之文本无效处理。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- “③：这张卡的②的效果发动的场合，下次的准备阶段发动。选这张卡所连接区1只效果怪兽，那个效果无效。”中的“那个效果无效”之效果无效处理。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
