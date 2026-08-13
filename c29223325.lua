--アーティファクト・ムーブメント
-- 效果：
-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，从卡组选1只「古遗物」怪兽当作魔法卡使用在自己的魔法与陷阱区域盖放。
-- ②：这张卡被对方破坏的场合发动。下次的对方战斗阶段跳过。
function c29223325.initial_effect(c)
	-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，从卡组选1只「古遗物」怪兽当作魔法卡使用在自己的魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29223325,0))  --"跳过战斗阶段"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetTarget(c29223325.target)
	e1:SetOperation(c29223325.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏的场合发动。下次的对方战斗阶段跳过。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29223325,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c29223325.descon)
	e2:SetOperation(c29223325.desop)
	c:RegisterEffect(e2)
end
-- 定义检索卡组用「古遗物」怪兽的过滤器：必须是「古遗物」字段的怪兽，并且能够作为魔法卡盖放到魔陷区（满足SSet条件）。
function c29223325.filter(c)
	return c:IsSetCard(0x97) and c:IsType(TYPE_MONSTER) and c:IsSSetable(true)
end
-- 定义可成为破坏对象的过滤器：该卡是魔法·陷阱卡，并且把该卡考虑在内后己方魔陷区剩余空格数大于追加占位数ft，确保破坏后仍有空间盖放「古遗物」怪兽。
function c29223325.desfilter(c,tp,ft)
	-- 判断该卡为魔法·陷阱卡，且考虑该卡占位后魔陷区空格数大于ft（即破坏后仍有足够空位盖放检索的怪兽）。
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetSZoneCount(tp,c)>ft
end
-- 效果①的发动条件检查与对象选择：首先确认卡组存在可盖放的「古遗物」怪兽，再选择场上1张魔法·陷阱卡作为破坏对象；若从手牌发动则额外预留1个魔陷区空格，设置破坏操作信息。
function c29223325.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c29223325.desfilter(chkc,tp,0) and chkc~=e:GetHandler() end
	if chk==0 then
		-- 检查卡组是否存在至少1只满足filter的「古遗物」怪兽，若不存在则效果无法发动。
		if not Duel.IsExistingMatchingCard(c29223325.filter,tp,LOCATION_DECK,0,1,nil) then return false end
		local ft=0
		if e:GetHandler():IsLocation(LOCATION_HAND) then ft=1 end
		-- 检查双方场上是否存在至少1张满足desfilter的魔法·陷阱卡可成为对象，且考虑手牌发动时的魔陷区占用后仍能完成后续盖放。
		return Duel.IsExistingTarget(c29223325.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),tp,ft)
	end
	-- 向玩家显示“请选择要破坏的卡”的选择提示，并写入待选卡片类型信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张满足desfilter的魔法·陷阱卡（不能选自身效果发动卡），并作为本连锁的对象登记。
	local g=Duel.SelectTarget(tp,c29223325.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler(),tp,0)
	-- 设置操作信息：本次连锁将破坏所选择的1张卡（分类为CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的处理：取对象卡，若对象仍与效果关联则将其破坏；破坏成功后若己方魔陷区有空位，从卡组选择1只「古遗物」怪兽当作魔法卡盖放到己方魔陷区。
function c29223325.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍然与效果有关联（未被移离/失效），然后以效果原因将其破坏；若破坏成功再继续处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 盖放前检查己方魔陷区是否存在空格，若没有空格则无法盖放，直接结束处理。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 向玩家显示“请选择要盖放的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从己方卡组选择1只满足filter条件的「古遗物」怪兽（不取对象，效果处理时选择）。
		local g=Duel.SelectMatchingCard(tp,c29223325.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的「古遗物」怪兽当作魔法卡以表侧表示盖放到己方魔陷区。
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 效果②的发动条件：这张卡是对方的效果（rp==1-tp）破坏，且破坏前这张卡的控制者为发动效果时的自己。
function c29223325.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 效果②的处理：生成一个跳过战斗阶段的场地效果，只影响对方玩家；若当前正处于对方战斗阶段内，则记录回合数并延迟到下一个对方回合跳过，否则在下次对方战斗阶段生效。
function c29223325.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断处理时是否已经进入了战斗阶段。
	local ph=Duel.GetCurrentPhase()
	-- ②：下次的对方战斗阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	-- 如果当前是对方回合并且已经过了主要阶段1但还未到主要阶段2（即正处于战斗阶段），说明跳过战斗阶段的效果无法在本回合战斗阶段生效，需要延迟到下一个对方回合。
	if Duel.GetTurnPlayer()~=tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
		-- 将当前回合数记录在效果标签中，用于后续判断是否已经进入下一个回合，从而实现“下次战斗阶段”的延迟。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c29223325.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,1)
	end
	-- 将跳过战斗阶段的效果注册到场上，使其持续影响对方玩家。
	Duel.RegisterEffect(e1,tp)
end
-- skipcon是延迟生效的条件：只有当前回合数与记录标签不同（即已经进入下一个回合）时，跳过战斗阶段的效果才会生效。
function c29223325.skipcon(e)
	-- 判断当前回合数不等于标签中记录的回合数，确保跳过的是发动后的下一次对方战斗阶段，而不是发动回合的战斗阶段。
	return Duel.GetTurnCount()~=e:GetLabel()
end
