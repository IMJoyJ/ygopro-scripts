--玉砕指令
-- 效果：
-- 选择自己场上存在的1只2星以下的通常怪兽（衍生物除外）发动。发动之后，祭掉被选择的通常怪兽，破坏对方场上至多2张魔法·陷阱卡。
function c39019325.initial_effect(c)
	-- 效果定义：将此卡注册为发动时点为自由时点的魔法卡效果，具有取对象效果属性，发动时需要选择自己场上1只2星以下的通常怪兽作为对象，并在发动后破坏对方场上至多2张魔法·陷阱卡。
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
-- 过滤函数：判断一张卡是否为通常怪兽且不是衍生物，且处于表侧表示，等级不超过2，可以因效果被解放，且未被效果免疫。
function c39019325.rfilter(c,e)
	local tpe=c:GetType()
	return bit.band(tpe,TYPE_NORMAL)~=0 and bit.band(tpe,TYPE_TOKEN)==0
		and c:IsFaceup() and c:IsLevelBelow(2) and c:IsReleasableByEffect() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：判断一张卡是否为魔法卡或陷阱卡。
function c39019325.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果处理：判断是否满足发动条件，即自己场上存在满足条件的怪兽和对方场上存在魔法·陷阱卡。
function c39019325.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c39019325.rfilter(chkc,e) end
	-- 效果处理：检查自己场上是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c39019325.rfilter,tp,LOCATION_MZONE,0,1,nil,e)
		-- 效果处理：检查对方场上是否存在魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(c39019325.dfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示信息：向玩家提示选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择对象：选择自己场上满足条件的1只怪兽作为效果对象。
	local rg=Duel.SelectTarget(tp,c39019325.rfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	-- 获取目标：获取对方场上的所有魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c39019325.dfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：设置效果发动后要破坏对方场上魔法·陷阱卡的分类和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动：当满足条件时，解放选择的怪兽并破坏对方场上至多2张魔法·陷阱卡。
function c39019325.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对象：获取当前连锁中被选择的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 效果处理：判断被选择的怪兽是否表侧表示且与效果相关联，并成功解放该怪兽。
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)>0 then
		-- 提示信息：向玩家提示选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择目标：从对方场上选择1至2张魔法·陷阱卡作为破坏对象。
		local dg=Duel.SelectMatchingCard(tp,c39019325.dfilter,tp,0,LOCATION_ONFIELD,1,2,nil)
		if dg:GetCount()>0 then
			-- 效果处理：将选择的魔法·陷阱卡以效果原因破坏。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
