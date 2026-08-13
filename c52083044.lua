--クロノダイバー・テンプホエーラー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放，以对方场上1只怪兽为对象才能发动。那只怪兽直到结束阶段除外。
-- ②：这张卡在墓地存在的场合，以「时间潜行者摆轮救生艇」以外的自己场上1只「时间潜行者」怪兽为对象才能发动。那只怪兽回到持有者手卡，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c52083044.initial_effect(c)
	-- ①：把这张卡解放，以对方场上1只怪兽为对象才能发动。那只怪兽直到结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52083044,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,52083044)
	e1:SetCost(c52083044.rmcost)
	e1:SetTarget(c52083044.rmtg)
	e1:SetOperation(c52083044.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以「时间潜行者摆轮救生艇」以外的自己场上1只「时间潜行者」怪兽为对象才能发动。那只怪兽回到持有者手卡，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52083044,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,52083045)
	e2:SetTarget(c52083044.sptg)
	e2:SetOperation(c52083044.spop)
	c:RegisterEffect(e2)
end
-- ①效果的代价函数：检查这张卡是否可解放，若可以则将自身解放作为发动代价。
function c52083044.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放这张卡作为发动代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ①效果的取对象目标选择：检查对方场上是否存在可除外的怪兽，提示玩家选择1只，并登记除外操作信息。
function c52083044.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 发动条件判定：对方场上存在至少1只可以除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要除外的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只可除外的怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：本次效果将除外1张卡，对象为g。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果处理：取得对象怪兽，若仍与效果关联则将其暂时除外，并设置结束阶段返回的标记与返回效果。
function c52083044.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联，然后将其以暂时除外的方式除外；成功才继续。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(52083044,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- ①：把这张卡解放，以对方场上1只怪兽为对象才能发动。那只怪兽直到结束阶段除外。②：这张卡在墓地存在的场合，以「时间潜行者摆轮救生艇」以外的自己场上1只「时间潜行者」怪兽为对象才能发动。那只怪兽回到持有者手卡，这张卡特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c52083044.retcon)
		e1:SetOperation(c52083044.retop)
		-- 注册一个在结束阶段将暂时除外的对象怪兽返回场上的效果给当前玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段返回效果的触发条件：被除外的对象怪兽仍带有本次除外对应的标记。
function c52083044.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(52083044)~=0
end
-- 结束阶段处理：将暂时除外的对象怪兽返回场上。
function c52083044.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的对象怪兽返回场上。
	Duel.ReturnToField(e:GetLabelObject())
end
-- ②效果选择对象的过滤条件：表侧表示的「时间潜行者」怪兽，不能是这张卡自身，可以加入手牌，且返回手牌后自己场上仍有可用怪兽区用于特殊召唤这张卡。
function c52083044.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x126) and not c:IsCode(52083044)
		-- 追加条件：该怪兽可以被加入手牌，且将该怪兽返回手牌后自己场上仍有空格可供这张卡特殊召唤。
		and c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的发动条件与取对象：确认墓地的这张卡可以特殊召唤，且自己场上有满足条件的「时间潜行者」怪兽可作为对象；若为对象判定则验证该卡是否满足条件。
function c52083044.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52083044.cfilter(chkc,tp) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认自己场上存在至少1只满足条件的「时间潜行者」怪兽可以作为对象。
		and Duel.IsExistingTarget(c52083044.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 显示“请选择要返回手牌的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只满足条件的「时间潜行者」怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c52083044.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 登记操作信息：本次效果将把1张卡返回手牌，对象为g。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 登记操作信息：本次效果将特殊召唤墓地的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：先将对象怪兽返回持有者手牌，若成功且这张卡仍与效果关联，则特殊召唤这张卡；随后给这张卡附加“从场上离开时除外”的永续效果。
function c52083044.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，将其返回持有者手牌，并确认确实回到手牌。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND)
		-- 确认这张卡仍与效果关联后，将其特殊召唤，若特召成功则继续附加离场除外效果。
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
