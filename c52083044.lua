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
-- 支付效果代价：解放自身
function c52083044.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从游戏中除外作为效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 选择效果对象：对方场上的1只怪兽
function c52083044.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 确认是否存在符合条件的效果对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，将除外的卡加入连锁处理
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理效果：将目标怪兽除外并设置结束阶段返回场上的效果
function c52083044.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽是否仍然在场上且成功除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(52083044,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 注册一个持续到结束阶段的永续效果，用于在结束阶段将怪兽返回场上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c52083044.retcon)
		e1:SetOperation(c52083044.retop)
		-- 将该效果注册到游戏环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否已设置标记以触发返回场上的效果
function c52083044.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(52083044)~=0
end
-- 将目标怪兽返回场上
function c52083044.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽以原本表示形式返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
-- 筛选符合条件的「时间潜行者」怪兽作为效果对象
function c52083044.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x126) and not c:IsCode(52083044)
		-- 确认目标怪兽可以送入手牌且自己场上存在可用区域
		and c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>0
end
-- 设置效果对象：选择自己场上的「时间潜行者」怪兽
function c52083044.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52083044.cfilter(chkc,tp) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认是否存在符合条件的效果对象
		and Duel.IsExistingTarget(c52083044.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c52083044.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果处理信息，将送入手牌的卡加入连锁处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果处理信息，将特殊召唤的卡加入连锁处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果：将目标怪兽送回手牌并特殊召唤自身
function c52083044.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽是否仍然在场上且成功送入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND)
		-- 确认自身是否可以特殊召唤且成功特殊召唤
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置效果：当此卡从场上离开时将其除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
