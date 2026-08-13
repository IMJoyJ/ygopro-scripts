--シューティング・スター・ドラゴン
-- 效果：
-- 同调怪兽调整＋「星尘龙」
-- ①：1回合1次，可以发动。从自己卡组上面翻开5张并回到卡组。这个回合这张卡可以作出最多有所翻开之中的调整数量的攻击。
-- ②：1回合1次，要让场上的卡破坏的效果的发动时才能发动。那个效果无效并破坏。
-- ③：1回合1次，对方的攻击宣言时以攻击怪兽为对象才能发动。场上的这张卡除外，那次攻击无效。
-- ④：这个③的效果除外的回合的结束阶段发动。这张卡特殊召唤。
function c24696097.initial_effect(c)
	-- 为流星龙声明其素材卡名列表中包含「星尘龙」（卡号44508094），用于辅助同调召唤条件的判定。
	aux.AddMaterialCodeList(c,44508094)
	-- 为流星龙添加同调召唤手续：素材为1只同调怪兽调整＋1只「星尘龙」，合计2只。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.FilterBoolFunction(Card.IsCode,44508094),1,1)
	c:EnableReviveLimit()
	-- ①：1回合1次，可以发动。从自己卡组上面翻开5张并回到卡组。这个回合这张卡可以作出最多有所翻开之中的调整数量的攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24696097,0))  --"多重攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c24696097.mtcon)
	e1:SetOperation(c24696097.mtop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，要让场上的卡破坏的效果的发动时才能发动。那个效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24696097,1))  --"把卡破坏的效果无效并破坏"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c24696097.discon)
	e2:SetTarget(c24696097.distg)
	e2:SetOperation(c24696097.disop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方的攻击宣言时以攻击怪兽为对象才能发动。场上的这张卡除外，那次攻击无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24696097,2))  --"无效攻击"
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c24696097.dacon)
	e3:SetTarget(c24696097.datg)
	e3:SetOperation(c24696097.daop)
	c:RegisterEffect(e3)
	-- ④：这个③的效果除外的回合的结束阶段发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24696097,3))  --"特殊召唤"
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCountLimit(1)
	e4:SetCondition(c24696097.sumcon)
	e4:SetTarget(c24696097.sumtg)
	e4:SetOperation(c24696097.sumop)
	c:RegisterEffect(e4)
end
c24696097.material_type=TYPE_SYNCHRO
-- ①效果的发动条件判定：当前可进入战斗阶段，且自己卡组上方至少有5张卡。
function c24696097.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家可以进入战斗阶段且卡组上方剩余卡数不少于5张，作为①效果的发动条件。
	return Duel.IsAbleToEnterBP() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5
end
-- ①效果的处理：翻开卡组上方5张卡确认，统计其中调整数量后洗回卡组；若调整数量大于1，则本回合这张卡获得额外攻击次数（调整数-1）；若调整为0，则这张卡本回合不能攻击。
function c24696097.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让当前玩家确认自己卡组最上方的5张卡。
	Duel.ConfirmDecktop(tp,5)
	-- 取得卡组最上方的5张卡作为一组对象，用于统计调整数量。
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:FilterCount(Card.IsType,nil,TYPE_TUNER)
	-- 将刚才翻开的5张卡洗回卡组。
	Duel.ShuffleDeck(tp)
	if ct>1 then
		-- 这个回合这张卡可以作出最多有所翻开之中的调整数量的攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct-1)
		c:RegisterEffect(e1)
	elseif ct==0 then
		-- 这个回合这张卡可以作出最多有所翻开之中的调整数量的攻击。（翻开的调整数量为0时，即不能攻击）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- ②效果的发动条件判定：若此卡已被战斗破坏或目标连锁不能被无效则不满足；若目标效果本身带有“无效”分类且是魔法·陷阱卡的发动，则也不能发动。
function c24696097.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 若此卡已被战斗破坏，或该连锁效果不能被无效，则不满足②效果发动条件。
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 若该连锁效果带有“无效”分类且是魔法·陷阱卡的发动，则②效果不能发动，以避免互相无效。
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取该连锁效果中关于“破坏”的操作信息，判断其是否包含破坏场上卡的效果。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- ②效果的发动目标：无额外条件；处理时设置将无效该连锁效果，若其发动卡可破坏且仍与效果关联，则一并设置破坏该卡。
function c24696097.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次操作包含“无效效果”分类，对象为当前连锁的卡组eg，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置本次操作包含“破坏”分类，对象为当前连锁的卡组eg，数量1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果的处理：先无效该连锁效果，若其发动卡仍与效果关联，则将其破坏。
function c24696097.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效该连锁效果，且该效果的发动卡仍与效果关联，则继续执行破坏处理。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方连锁涉及的卡组eg以效果破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ③效果的发动条件判定：当前攻击怪兽的控制者不是自己，即对方怪兽进行攻击宣言。
function c24696097.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽的控制者不是自己（即对方攻击时），满足③效果发动条件。
	return Duel.GetAttacker():GetControler()~=tp
end
-- ③效果的发动目标：将攻击怪兽选为对象，并检查此卡可被除外且不在连锁处理中；发动时设置除外此卡。
function c24696097.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 若在选择对象阶段校验对象，则对象必须是当前攻击怪兽。
	if chkc then return chkc==Duel.GetAttacker() end
	-- 发动时检查此卡可以被除外，且攻击怪兽能成为效果对象，并且此卡不在连锁处理中。
	if chk==0 then return e:GetHandler():IsAbleToRemove() and Duel.GetAttacker():IsCanBeEffectTarget(e)
		and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 将当前攻击怪兽设置为③效果的对象。
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 设置本次操作包含“除外”分类，将要把此卡除外，数量1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- ③效果的处理：若此卡仍与效果关联且成功除外，则无效攻击，并给此卡设置标记，用于④效果在结束阶段特殊召唤。
function c24696097.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果关联，并且将其表侧表示除外成功，则继续执行无效攻击和标记处理。
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 无效当前攻击。
		Duel.NegateAttack()
		c:RegisterFlagEffect(24696097,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end
-- ④效果的发动条件判定：此卡带有③效果设置的标记，即本回合因③效果被除外过。
function c24696097.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(24696097)>0
end
-- ④效果发动时：无额外条件，设置将特殊召唤此卡。
function c24696097.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次操作包含“特殊召唤”分类，将要把此卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ④效果的处理：若此卡仍在除外状态且与效果关联，则将其特殊召唤。
function c24696097.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到其持有者场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
