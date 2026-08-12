--マドルチェ・エンジェリー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡解放才能发动。从卡组把1只「魔偶甜点」怪兽特殊召唤。这个效果特殊召唤的怪兽不会被战斗破坏，下次的自己回合的结束阶段回到卡组。
-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
function c34680482.initial_effect(c)
	-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34680482,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c34680482.retcon)
	e1:SetTarget(c34680482.rettg)
	e1:SetOperation(c34680482.retop)
	c:RegisterEffect(e1)
	-- ①：把这张卡解放才能发动。从卡组把1只「魔偶甜点」怪兽特殊召唤。这个效果特殊召唤的怪兽不会被战斗破坏，下次的自己回合的结束阶段回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34680482,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,34680482)
	e2:SetCost(c34680482.spcost)
	e2:SetTarget(c34680482.sptg)
	e2:SetOperation(c34680482.spop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否因对方破坏而送去墓地
function c34680482.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 设置效果处理时的OperationInfo信息，用于提示将此卡送回卡组
function c34680482.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将此卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 执行将此卡送回卡组的效果
function c34680482.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以洗牌方式送回卡组
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 支付特殊召唤的代价，解放此卡
function c34680482.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为特殊召唤的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选卡组中满足条件的「魔偶甜点」怪兽
function c34680482.filter(c,e,tp)
	return c:IsSetCard(0x71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的处理条件，检查是否有足够的召唤位置和满足条件的怪兽
function c34680482.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查召唤位置是否足够
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c34680482.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息，表示将从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤效果，选择并特殊召唤符合条件的怪兽
function c34680482.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c34680482.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 为特殊召唤的怪兽设置标记，用于记录其召唤回合
		tc:RegisterFlagEffect(34680482,RESET_EVENT+RESETS_STANDARD,0,1,Duel.GetTurnCount())
		-- 「魔偶甜点·果冻天使」效果适用中
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(34680482,2))  --"「魔偶甜点·果冻天使」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 设置一个持续到下次结束阶段的效果，用于在结束阶段将怪兽送回卡组
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		-- 记录当前回合数，用于后续判断
		e2:SetLabel(Duel.GetTurnCount())
		e2:SetLabelObject(tc)
		e2:SetCondition(c34680482.tdcon)
		e2:SetOperation(c34680482.tdop)
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		e2:SetCountLimit(1)
		-- 将效果注册到游戏环境
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断是否满足将怪兽送回卡组的条件
function c34680482.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断是否为不同回合、是否为当前玩家回合、以及怪兽是否仍处于标记状态
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==tp and tc:GetFlagEffectLabel(34680482)==e:GetLabel()
end
-- 执行将怪兽送回卡组的操作
function c34680482.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 显示提示动画，表示此卡发动了效果
	Duel.Hint(HINT_CARD,0,34680482)
	-- 将怪兽以洗牌方式送回卡组
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
