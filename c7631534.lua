--双天脚 鎧吽
-- 效果：
-- 「双天」怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的「双天」融合怪兽被效果破坏的场合，可以作为代替把自己场上1只「双天」怪兽破坏。
-- ②：效果怪兽为素材作融合召唤的「双天」融合怪兽在自己场上存在的场合，自己·对方的主要阶段，以从额外卡组特殊召唤的1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
function c7631534.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为2只「双天」怪兽
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x14f),2,true)
	-- 效果怪兽为素材作融合召唤的「双天」融合怪兽
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c7631534.matcheck)
	c:RegisterEffect(e0)
	-- ①：自己场上的「双天」融合怪兽被效果破坏的场合，可以作为代替把自己场上1只「双天」怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c7631534.reptg)
	e1:SetValue(c7631534.repval)
	e1:SetOperation(c7631534.repop)
	c:RegisterEffect(e1)
	-- ②：效果怪兽为素材作融合召唤的「双天」融合怪兽在自己场上存在的场合，自己·对方的主要阶段，以从额外卡组特殊召唤的1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7631534,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,7631534)
	e2:SetCondition(c7631534.discon)
	e2:SetTarget(c7631534.distg)
	e2:SetOperation(c7631534.disop)
	c:RegisterEffect(e2)
end
-- 检查融合素材中是否存在效果怪兽，若存在则给自身注册标记
function c7631534.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_EFFECT) then
		c:RegisterFlagEffect(85360035,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
end
-- 过滤自己场上因效果被破坏的表侧表示「双天」融合怪兽
function c7631534.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x14f) and c:IsType(TYPE_FUSION) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 过滤自己场上可以作为代替破坏的「双天」怪兽
function c7631534.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x14f)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的靶向/条件判定，检查是否有符合条件的被破坏卡和代替破坏卡
function c7631534.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c7631534.repfilter,1,nil,tp)
		-- 检查自己场上是否存在至少1只可以代替破坏的「双天」怪兽
		and Duel.IsExistingMatchingCard(c7631534.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 设置选择代替破坏卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 玩家选择1只自己场上的「双天」怪兽作为代替破坏的对象
		local g=Duel.SelectMatchingCard(tp,c7631534.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
-- 确定代替破坏效果的适用对象过滤函数
function c7631534.repval(e,c)
	return c7631534.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏的处理，将选中的代替卡破坏
function c7631534.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上展示此卡，提示发动不入连锁的代替破坏效果
	Duel.Hint(HINT_CARD,0,7631534)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 破坏作为代替的怪兽
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
-- 过滤自己场上以效果怪兽为素材融合召唤的表侧表示「双天」融合怪兽
function c7631534.fmfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x14f) and c:IsFaceup() and c:GetFlagEffect(85360035)~=0
end
-- 效果无效发动的条件判定，必须在自己或对方的主要阶段，且场上有符合条件的「双天」融合怪兽
function c7631534.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1或主要阶段2
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		-- 检查自己场上是否存在以效果怪兽为素材融合召唤的「双天」融合怪兽
		and Duel.IsExistingMatchingCard(c7631534.fmfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤未被无效的、从额外卡组特殊召唤的表侧表示怪兽
function c7631534.disfilter(c)
	-- 检查怪兽是否为表侧表示、未被无效的效果怪兽，且是从额外卡组特殊召唤
	return aux.NegateMonsterFilter(c) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果无效发动的目标选择与判定
function c7631534.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c7631534.disfilter(chkc) end
	-- 检查场上是否存在可以作为无效对象的从额外卡组特殊召唤的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c7631534.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置选择无效化卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择1只从额外卡组特殊召唤的表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c7631534.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理的操作信息，表示该效果会使1张卡的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果无效的实际处理逻辑
function c7631534.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与目标怪兽相关的连锁都无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
