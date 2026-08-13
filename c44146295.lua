--氷剣竜ミラジェイド
-- 效果：
-- 「阿不思的落胤」＋融合·同调·超量·连接怪兽
-- ①：「冰剑龙 幻冰龙」在自己场上只能有1张表侧表示存在。
-- ②：自己·对方回合1次，把以「阿不思的落胤」为融合素材的1只融合怪兽从额外卡组送去墓地才能发动。场上1只怪兽除外。下个回合，这张卡不能使用这个效果。
-- ③：融合召唤的这张卡因对方从场上离开的场合才能发动。这个回合的结束阶段，对方场上的怪兽全部破坏。
function c44146295.initial_effect(c)
	c:SetUniqueOnField(1,0,44146295)
	c:EnableReviveLimit()
	-- 为冰剑龙添加融合召唤手续：需要1只「阿不思的落胤」（卡号68468459）和1只融合/同调/超量/连接怪兽作为素材，且允许使用融合替代素材。
	aux.AddFusionProcCodeFun(c,68468459,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK),1,true,true)
	-- 对应效果原文：“②：自己·对方回合1次，把以「阿不思的落胤」为融合素材的1只融合怪兽从额外卡组送去墓地才能发动。场上1只怪兽除外。下个回合，这张卡不能使用这个效果。” 该段注册效果②并实现其发动条件、代价、目标与处理。
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
	-- 对应效果原文：“③：融合召唤的这张卡因对方从场上离开的场合才能发动。这个回合的结束阶段，对方场上的怪兽全部破坏。” 该段注册效果③并实现离场诱发与结束阶段破坏。
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
-- 定义融合素材过滤函数：一张素材可以是「阿不思的落胤」，也可以是能够作为融合素材替代品的怪兽。
function c44146295.sfcfilter(c,fc)
	return c:IsFusionCode(68468459) or c:CheckFusionSubstitute(fc)
end
-- 定义同调融合检索用的素材组合检查：一组素材为阿不思或其替代素材，另一组为同调怪兽。
function c44146295.synchro_fusion_check(tp,sg,fc)
	-- 检查素材组sg是否由阿不思（或替代素材）和同调怪兽组成，用于「阿不思＋同调怪兽」的融合召唤判定。
	return aux.gffcheck(sg,c44146295.sfcfilter,fc,Card.IsFusionType,TYPE_SYNCHRO)
end
-- 定义烙印融合等效果适用的素材组合检查：一组素材必须是「阿不思的落胤」，另一组必须是融合/同调/超量/连接怪兽。
function c44146295.branded_fusion_check(tp,sg,fc)
	-- 检查素材组sg是否满足「阿不思的落胤」＋融合/同调/超量/连接怪兽的固定融合素材组合。
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,Card.IsFusionType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 效果②的发动条件：读取冰剑龙身上的标记，若标记值不等于“当前回合数-1”则可发动；标记值为上一回合时本回合不能发动。
function c44146295.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 通过标记值判断是否处于“下个回合不能使用”的限制中：标记值等于当前回合数-1时禁止发动。
	return e:GetHandler():GetFlagEffectLabel(44146295)~=Duel.GetTurnCount()-1
end
-- 效果②的代价筛选：从额外卡组选择1只融合怪兽，且该怪兽的融合素材包含「阿不思的落胤」，并且可以作为代价送去墓地。
function c44146295.costfilter(c)
	-- 过滤条件具体为：是融合怪兽、其素材表包含阿不思、可以送去墓地作为代价。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsAbleToGraveAsCost()
end
-- 效果②的代价处理：在发动时确认存在符合条件的融合怪兽，并提示玩家选择1张从额外卡组送去墓地作为cost。
function c44146295.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查cost是否可行：额外卡组存在至少1张符合条件的融合怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c44146295.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 显示“请选择要送去墓地的卡”的卡片选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从额外卡组选择1张符合条件的融合怪兽。
	local g=Duel.SelectMatchingCard(tp,c44146295.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的融合怪兽作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的目标选择与处理信息登记：选择场上1只可以除外的怪兽，并设置除外1只场上怪兽的效果信息。
function c44146295.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标合法性检查：场上存在至少1只可以被除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置操作信息：本次处理将除外1只场上怪兽（由于不取对象，targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_MZONE)
end
-- 效果②的发动处理：从所有可除外的场上怪兽中选择1只表侧表示除外；若冰剑龙仍与效果关联，则注册标记记录当前回合数，用于限制下个回合再次使用。
function c44146295.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方怪兽区所有可以被除外的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 显示“请选择要除外的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 手动为选中的目标怪兽显示被选中动画，并记录该卡成为效果处理对象。
		Duel.HintSelection(sg)
		-- 将选中的怪兽表侧表示除外。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 给冰剑龙注册标记44146295，值为当前回合数，持续到结束阶段，用于实现“下个回合不能使用这个效果”。
		c:RegisterFlagEffect(44146295,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2,Duel.GetTurnCount())
	end
end
-- 效果③的发动条件：冰剑龙是融合召唤出场、从怪兽区因对方玩家原因离场，且离场前控制者是发动玩家。
function c44146295.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 效果③的发动处理：在结束阶段注册一个延迟效果，等到该回合结束阶段时破坏对方场上全部怪兽。
function c44146295.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 对应效果原文：“这个回合的结束阶段，对方场上的怪兽全部破坏。” 该段创建并注册结束阶段的延迟效果，并在其处理时执行破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c44146295.desop2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段触发的延迟效果e1注册到当前决斗，所属玩家为tp，使其在该回合结束阶段生效。
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段实际处理：展示冰剑龙的效果动画，获取对方场上全部怪兽并全部破坏。
function c44146295.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 播放冰剑龙的效果发动动画，提示双方这是冰剑龙发动效果。
	Duel.Hint(HINT_CARD,0,44146295)
	-- 获取对方场上所有怪兽（无条件筛选出所有怪兽）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将对方场上所有怪兽全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
