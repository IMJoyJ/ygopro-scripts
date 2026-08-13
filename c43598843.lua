--ギミック・パペット－テラー・ベビー
-- 效果：
-- ①：这张卡召唤成功时，以「机关傀儡-恐怖婴儿」以外的自己墓地1只「机关傀儡」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：把墓地的这张卡除外才能发动。这个回合，对方不能对应自己的「机关傀儡」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
function c43598843.initial_effect(c)
	-- ①：这张卡召唤成功时，以「机关傀儡-恐怖婴儿」以外的自己墓地1只「机关傀儡」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43598843,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c43598843.sptg)
	e1:SetOperation(c43598843.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合，对方不能对应自己的「机关傀儡」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43598843,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置发动②效果所需的代价：将墓地中的这张卡除外（aux.bfgcost实现除外自身作为cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c43598843.target)
	e2:SetOperation(c43598843.operation)
	c:RegisterEffect(e2)
end
-- 过滤符合条件的墓地「机关傀儡」怪兽：属于「机关傀儡」系列、不是这张卡自身、并且能够以表侧守备表示特殊召唤。
function c43598843.spfilter(c,e,tp)
	return c:IsSetCard(0x1083) and not c:IsCode(43598843) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动条件与取对象判断：若指定了对象则验证对象位于自己墓地且满足特殊召唤条件；若进行发动判定则还需确认场上主要怪兽区有空位且墓地存在满足条件的对象。
function c43598843.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43598843.spfilter(chkc,e,tp) end
	-- 发动条件判定：确认自己场上主要怪兽区存在至少1个可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件判定：确认自己墓地存在至少1只满足spfilter条件的「机关傀儡」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c43598843.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示，用于后续对象选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足spfilter条件的「机关傀儡」怪兽，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c43598843.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：本效果包含特殊召唤，目标为已选择的怪兽，数量为1，供其他卡片/时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①处理：取得对象卡，若其仍与本效果关联，则将其以表侧守备表示特殊召唤到自己的主要怪兽区。
function c43598843.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个（也是唯一一个）效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动条件判断函数：用于确认本回合尚未使用过②效果（以玩家flag为标记）。
function c43598843.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：若当前是check阶段，则返回玩家是否还没有本回合②效果的flag标记（0表示未使用，允许发动）。
	if chk==0 then return Duel.GetFlagEffect(tp,43598843)==0 end
end
-- 效果②处理：注册一个本回合结束阶段重置的持续效果，用于监听后续「机关傀儡」怪兽效果发动，并给玩家登记本回合已使用②效果的flag。
function c43598843.operation(e,tp,eg,ep,ev,re,r,rp)
	-- ②：把墓地的这张卡除外才能发动。这个回合，对方不能对应自己的「机关傀儡」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(c43598843.actop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的持续监视效果注册给玩家tp，效果持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	-- 为玩家tp登记一个本回合已使用过②效果的标志，结束阶段重置，用于防止同一回合重复发动。
	Duel.RegisterFlagEffect(tp,43598843,RESET_PHASE+PHASE_END,0,1)
end
-- actop回调：当自己发动「机关傀儡」怪兽的效果时，设置本次连锁的连锁限制。
function c43598843.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(0x1083) and ep==tp then
		-- 设置连锁限制函数，使对方不能连锁自己「机关傀儡」怪兽效果的发动来发动魔法·陷阱·怪兽效果。
		Duel.SetChainLimit(c43598843.chainlm)
	end
end
-- chainlm限制函数：仅允许效果发动者tp自身进行连锁，对方（rp）不能连锁，从而实现“对方不能对应发动”的效果。
function c43598843.chainlm(e,rp,tp)
	return tp==rp
end
