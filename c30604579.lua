--極神皇トール
-- 效果：
-- 「极星兽」调整＋调整以外的怪兽2只以上
-- ①：1回合1次，自己主要阶段才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
-- ②：场上的表侧表示的这张卡被对方破坏送去墓地的回合的结束阶段，从自己墓地把1只「极星兽」调整除外才能发动。这张卡从墓地特殊召唤。
-- ③：这张卡的②的效果特殊召唤成功时才能发动。给与对方800伤害。
function c30604579.initial_effect(c)
	-- 为这张卡添加同调召唤手续：以1只「极星兽」调整为调整素材，调整以外的怪兽2只以上为其他素材，进行同调召唤。
	aux.AddSynchroProcedure(c,c30604579.tfilter,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30604579,0))  --"怪兽效果无效化"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c30604579.distg)
	e1:SetOperation(c30604579.disop)
	c:RegisterEffect(e1)
	-- 场上的表侧表示的这张卡被对方破坏送去墓地的回合的结束阶段
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c30604579.regop)
	c:RegisterEffect(e2)
	-- 从自己墓地把1只「极星兽」调整除外才能发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30604579,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(c30604579.spcon)
	e3:SetCost(c30604579.spcost)
	e3:SetTarget(c30604579.sptg)
	e3:SetOperation(c30604579.spop)
	c:RegisterEffect(e3)
	-- ③：这张卡的②的效果特殊召唤成功时才能发动。给与对方800伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30604579,2))  --"给与对方800伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c30604579.damcon)
	e4:SetTarget(c30604579.damtg)
	e4:SetOperation(c30604579.damop)
	c:RegisterEffect(e4)
end
-- 定义同调调整素材的过滤条件：必须是「极星兽」系列怪兽，或者拥有指定效果的怪兽（可作为「极星兽」调整使用）。
function c30604579.tfilter(c)
	return c:IsSetCard(0x6042) or c:IsHasEffect(61777313)
end
-- ①效果的发动条件判定：检查对方场上是否存在至少1只表侧表示怪兽。
function c30604579.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧表示怪兽（若存在则可发动）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- ①效果处理：获取对方场上全部表侧表示怪兽，并分别使其怪兽效果无效化和效果发动无效化，持续到回合结束时。
function c30604579.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的全部表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- ②的触发条件登记：当这张卡以表侧表示存在场上时被对方破坏并送去墓地，则给这张卡设置标记，记录满足②特殊召唤的发动条件。
function c30604579.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pos=c:GetPreviousPosition()
	if c:IsReason(REASON_BATTLE) then pos=c:GetBattlePosition() end
	if rp==1-tp and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and bit.band(pos,POS_FACEUP)~=0 then
		c:RegisterFlagEffect(30604579,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- spcon：②效果发动条件检查，确认这张卡已满足“被对方破坏送去墓地”的标记，即处于可发动②的回合。
function c30604579.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(30604579)~=0
end
-- 定义②的cost过滤条件：从自己墓地选择1只「极星兽」调整且可以作为cost除外。
function c30604579.cfilter(c)
	return c:IsSetCard(0x6042) and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- ②的cost处理：从自己墓地将1只「极星兽」调整除外作为发动代价。
function c30604579.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只符合条件的「极星兽」调整，以确定cost是否可支付。
	if chk==0 then return Duel.IsExistingMatchingCard(c30604579.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只符合条件的「极星兽」调整作为除外对象。
	local g=Duel.SelectMatchingCard(tp,c30604579.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的「极星兽」调整除外，作为发动②效果的cost。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标判定：确认自己主要怪兽区有空位，并且这张卡可以被特殊召唤。
function c30604579.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己的主要怪兽区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明后续会将这张卡从墓地特殊召唤，供连锁检测和卡牌互动使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍在墓地且与效果关联，则将其从墓地特殊召唤到自己场上。
function c30604579.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示形式特殊召唤到自己场上，并指定召唤类型标记为自身效果特殊召唤。
		Duel.SpecialSummon(e:GetHandler(),SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- damcon：③效果发动条件检查，确认这张卡是通过②的效果成功特殊召唤的。
function c30604579.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- ③效果发动时的目标设定：以对方玩家为对象，设置伤害参数为800，并登记伤害操作信息。
function c30604579.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对方玩家设置为伤害对象。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的伤害数值参数设置为800。
	Duel.SetTargetParam(800)
	-- 设置操作信息：后续将对对方造成800点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- ③效果处理：从连锁信息中取得目标玩家和伤害值，并造成对应效果伤害。
function c30604579.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出伤害对象玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给对方造成800点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
