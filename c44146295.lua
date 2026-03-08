--氷剣竜ミラジェイド
-- 效果：
-- 「阿不思的落胤」＋融合·同调·超量·连接怪兽
-- ①：「冰剑龙 幻冰龙」在自己场上只能有1张表侧表示存在。
-- ②：自己·对方回合1次，把以「阿不思的落胤」为融合素材的1只融合怪兽从额外卡组送去墓地才能发动。场上1只怪兽除外。下个回合，这张卡不能使用这个效果。
-- ③：融合召唤的这张卡因对方从场上离开的场合才能发动。这个回合的结束阶段，对方场上的怪兽全部破坏。
function c44146295.initial_effect(c)
	c:SetUniqueOnField(1,0,44146295)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用卡号68468459的怪兽和满足条件的1只融合·同调·超量·连接怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,68468459,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK),1,true,true)
	-- ②：自己·对方回合1次，把以「阿不思的落胤」为融合素材的1只融合怪兽从额外卡组送去墓地才能发动。场上1只怪兽除外。下个回合，这张卡不能使用这个效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44146295,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c44146295.rmcon)
	e1:SetCost(c44146295.rmcost)
	e1:SetTarget(c44146295.rmtg)
	e1:SetOperation(c44146295.rmop)
	c:RegisterEffect(e1)
	-- ③：融合召唤的这张卡因对方从场上离开的场合才能发动。这个回合的结束阶段，对方场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44146295,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c44146295.descon)
	e2:SetOperation(c44146295.desop)
	c:RegisterEffect(e2)
end
c44146295.material_type=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK
-- 用于判断融合素材是否满足条件，是否为卡号68468459或可替代的融合素材
function c44146295.sfcfilter(c,fc)
	return c:IsFusionCode(68468459) or c:CheckFusionSubstitute(fc)
end
-- 检查融合素材组是否包含一张满足sfcfilter条件的卡和一张同调怪兽
function c44146295.synchro_fusion_check(tp,sg,fc)
	-- 检查融合素材组是否恰好包含两张卡，且一张满足sfcfilter条件，另一张为同调怪兽
	return aux.gffcheck(sg,c44146295.sfcfilter,fc,Card.IsFusionType,TYPE_SYNCHRO)
end
-- 检查融合素材组是否包含一张卡号为68468459的融合怪兽和一张融合·同调·超量·连接怪兽
function c44146295.branded_fusion_check(tp,sg,fc)
	-- 检查融合素材组是否恰好包含两张卡，且一张为卡号68468459的融合怪兽，另一张为融合·同调·超量·连接怪兽
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,Card.IsFusionType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 判断该效果是否在当前回合已使用过，若未使用则可发动
function c44146295.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该效果是否在当前回合已使用过，若未使用则可发动
	return e:GetHandler():GetFlagEffectLabel(44146295)~=Duel.GetTurnCount()-1
end
-- 用于筛选满足条件的融合怪兽作为发动效果的代价
function c44146295.costfilter(c)
	-- 筛选类型为融合且以68468459为素材并能送入墓地的怪兽
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsAbleToGraveAsCost()
end
-- 发动效果时选择一张满足条件的融合怪兽送入墓地作为代价
function c44146295.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否存在满足条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44146295.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要送入墓地的融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c44146295.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的融合怪兽送入墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果的目标，选择场上可除外的怪兽
function c44146295.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测场上是否存在可除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置效果操作信息，表示将要除外场上怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_MZONE)
end
-- 发动效果时选择场上怪兽除外，并记录该效果已使用
function c44146295.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可除外的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要除外的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显示选中的怪兽被除外的动画效果
		Duel.HintSelection(sg)
		-- 将选中的怪兽除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 记录该效果在当前回合已使用，下个回合不能再使用
		c:RegisterFlagEffect(44146295,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2,Duel.GetTurnCount())
	end
end
-- 判断该卡是否为融合召唤且因对方操作离开场上的条件
function c44146295.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 注册结束阶段触发的效果，用于在结束阶段破坏对方场上怪兽
function c44146295.desop(e,tp,eg,ep,ev,re,r,rp)
	-- ③：融合召唤的这张卡因对方从场上离开的场合才能发动。这个回合的结束阶段，对方场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c44146295.desop2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家的全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段时破坏对方场上所有怪兽
function c44146295.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示该卡发动的动画效果
	Duel.Hint(HINT_CARD,0,44146295)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 破坏对方场上所有怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
