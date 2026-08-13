--占い魔女 スィーちゃん
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡的特殊召唤成功的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽直到下次的自己回合的准备阶段除外。
function c5298175.initial_effect(c)
	-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5298175,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1,5298175)
	e1:SetCost(c5298175.spcost)
	e1:SetTarget(c5298175.sptg)
	e1:SetOperation(c5298175.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡的特殊召唤成功的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽直到下次的自己回合的准备阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5298175,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,5298176)
	e2:SetCondition(c5298175.rmcon)
	e2:SetTarget(c5298175.rmtg)
	e2:SetOperation(c5298175.rmop)
	c:RegisterEffect(e2)
end
-- 发动代价判定：这张卡必须处于非公开状态（即尚未对外公开，才能通过向对方展示作为代价来发动）。
function c5298175.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 效果发动时的合法条件判定：确认此卡可以特殊召唤且我方主要怪兽区有空位。
function c5298175.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查我方主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：告知系统此次效果将特殊召唤这张卡，用于连锁判定和后续处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：若此卡仍与效果关联，则将其从手牌特殊召唤到场上。
function c5298175.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到其控制者场上，并正常检查召唤条件与苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动条件：这张卡是从手牌特殊召唤成功（即特殊召唤之前位于手牌）。
function c5298175.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 选择对象时的过滤条件：场上表侧表示怪兽且可以被除外。
function c5298175.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果发动时的目标选择处理：从场上双方怪兽区域选择1只除自身以外的表侧表示怪兽作为对象，并设置除外操作信息。
function c5298175.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c5298175.rmfilter(chkc) and chkc~=c end
	-- 确认场上是否存在至少1只除自身以外、满足条件且能成为此效果对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c5298175.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 弹出选择提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1只满足条件的怪兽作为效果对象，并将选中的卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c5298175.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置操作信息：确定此次效果将除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：将对象怪兽暂时除外，然后根据当前回合情况注册一个在下一次自己的准备阶段将那只怪兽返回场上的延迟效果，并建立效果关联。
function c5298175.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第1张效果对象卡（即被选择要除外的怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与效果关联，则将其以效果原因暂时除外；只有除外成功且对象在除外区时才继续后续的返回处理。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0
		and tc:IsLocation(LOCATION_REMOVED) then
		-- 那只怪兽直到下次的自己回合的准备阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(5298175,2))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c5298175.retcon)
		e1:SetOperation(c5298175.retop)
		-- 判断当前回合玩家是否为自己，用于决定返回效果是在下一个自己准备阶段触发，还是需要跨过一个对方回合后的自己准备阶段触发。
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			-- 记录发动效果时的回合数，防止在发动时的同一个准备阶段立即触发回归效果。
			e1:SetValue(Duel.GetTurnCount())
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e1:SetValue(0)
		end
		-- 将该回归效果注册到场上的效果管理器中，由tp玩家控制，并在满足条件时自动执行。
		Duel.RegisterEffect(e1,tp)
		tc:CreateEffectRelation(e1)
	end
end
-- 回归效果的触发条件：必须是自己的准备阶段，且处于下一次准备阶段而非记录中的那次，同时被除外的怪兽仍与该效果保持关联。
function c5298175.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前不是自己的回合，或者仍然停留在记录回合数的那个准备阶段，则不触发回归效果。
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
	return e:GetLabelObject():IsRelateToEffect(e)
end
-- 回归效果的处理：取出被暂时除外的怪兽并将其返回场上。
function c5298175.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将被暂时除外的怪兽按其离场前的表示形式返回场上。
	Duel.ReturnToField(tc)
end
