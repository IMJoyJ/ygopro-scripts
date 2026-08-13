--玉砕指令
-- 效果：
-- 选择自己场上存在的1只2星以下的通常怪兽（衍生物除外）发动。发动之后，祭掉被选择的通常怪兽，破坏对方场上至多2张魔法·陷阱卡。
function c39019325.initial_effect(c)
	-- 选择自己场上存在的1只2星以下的通常怪兽（衍生物除外）发动。发动之后，祭掉被选择的通常怪兽，破坏对方场上至多2张魔法·陷阱卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c39019325.target)
	e1:SetOperation(c39019325.activate)
	c:RegisterEffect(e1)
end
-- 该过滤函数用于筛选可作为发动对象的怪兽：必须是表侧表示、等级2以下的通常怪兽，且不是衍生物，并且可以被效果解放、不免疫此效果。
function c39019325.rfilter(c,e)
	local tpe=c:GetType()
	return bit.band(tpe,TYPE_NORMAL)~=0 and bit.band(tpe,TYPE_TOKEN)==0
		and c:IsFaceup() and c:IsLevelBelow(2) and c:IsReleasableByEffect() and not c:IsImmuneToEffect(e)
end
-- 该过滤函数用于筛选对方场上的魔法·陷阱卡，作为破坏候选卡。
function c39019325.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的目标处理：先检查自己场上是否存在满足条件的2星以下通常怪兽，以及对方场上是否存在可被破坏的魔法·陷阱卡；若满足，则选择1只解放对象怪兽，并获取对方场上所有魔法·陷阱卡作为破坏候选。
function c39019325.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c39019325.rfilter(chkc,e) end
	-- 在效果发动时（chk==0）检查自己场上是否存在1只满足rfilter条件且能成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c39019325.rfilter,tp,LOCATION_MZONE,0,1,nil,e)
		-- 同时检查对方场上是否至少存在1张魔法·陷阱卡可供破坏。
		and Duel.IsExistingMatchingCard(c39019325.dfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要解放的卡，显示“请选择要解放的卡”的消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择自己场上1只满足rfilter条件的2星以下通常怪兽作为效果对象（取对象），并建立对象与连锁的联系。
	local rg=Duel.SelectTarget(tp,c39019325.rfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	-- 获取对方场上所有魔法·陷阱卡组成集合，用于后续设置破坏操作信息。
	local g=Duel.GetMatchingGroup(c39019325.dfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本次连锁将破坏对方的魔法·陷阱卡，目标集合为g，预计破坏数量为1，供相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：若对象怪兽仍表侧表示且与效果关联，则将其解放；解放成功后，从对方场上选择1~2张魔法·陷阱卡破坏。
function c39019325.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的目标怪兽（即要解放的那只通常怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否表侧表示且与效果仍有关联，若是则将其解放（效果解放），解放成功后才继续后续破坏处理。
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)>0 then
		-- 提示玩家选择要破坏的卡，显示“请选择要破坏的卡”的消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1~2张魔法·陷阱卡作为破坏对象。
		local dg=Duel.SelectMatchingCard(tp,c39019325.dfilter,tp,0,LOCATION_ONFIELD,1,2,nil)
		if dg:GetCount()>0 then
			-- 将选中的魔法·陷阱卡以效果破坏并送去墓地。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
