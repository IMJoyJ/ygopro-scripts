--DDD赦俿王デス・マキナ
-- 效果：
-- ←10 【灵摆】 10→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有卡存在的场合，以自己的场上·墓地1只灵摆怪兽为对象才能发动。另一边的自己的灵摆区域的卡特殊召唤，作为对象的灵摆怪兽在自己的灵摆区域放置。
-- 【怪兽效果】
-- 恶魔族10星怪兽×2
-- 这张卡也能在自己场上的「DDD」怪兽上面重叠来超量召唤。
-- ①：「DDD 赦俿王 死亡机降神」在自己的怪兽区域只能有1只表侧表示存在。
-- ②：对方场上的怪兽卡的效果发动时才能发动（同一连锁上最多1次）。这张卡2个超量素材取除或自己场上1张「契约书」卡破坏，那张对方的卡作为这张卡的超量素材。
-- ③：自己准备阶段才能发动。这张卡在自己的灵摆区域放置。
function c46593546.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),10,2,c46593546.ovfilter,aux.Stringid(46593546,0))  --"是否在「DDD」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 为该卡赋予灵摆怪兽的基本属性（可进行灵摆召唤），但不注册灵摆区域作为魔法卡“卡的发动”的效果。
	aux.EnablePendulumAttribute(c,false)
	c:SetUniqueOnField(1,0,46593546,LOCATION_MZONE)
	-- 灵摆效果①：另一边的自己的灵摆区域有卡存在的场合，以自己的场上·墓地1只灵摆怪兽为对象才能发动。另一边的自己的灵摆区域的卡特殊召唤，作为对象的灵摆怪兽在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46593546,1))  --"特殊召唤灵摆区域的怪兽"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,46593546)
	e1:SetTarget(c46593546.sptg)
	e1:SetOperation(c46593546.spop)
	c:RegisterEffect(e1)
	-- 怪兽效果②：对方场上的怪兽卡的效果发动时才能发动（同一连锁上最多1次）。这张卡2个超量素材取除或自己场上1张「契约书」卡破坏，那张对方的卡作为这张卡的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46593546,2))  --"发动效果的怪兽作为超量素材"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c46593546.ovlcon)
	e2:SetTarget(c46593546.ovltg)
	e2:SetOperation(c46593546.ovlop)
	c:RegisterEffect(e2)
	-- 怪兽效果③：自己准备阶段才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46593546,3))  --"这张卡在自己的灵摆区域放置"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c46593546.pencon)
	e3:SetTarget(c46593546.pentg)
	e3:SetOperation(c46593546.penop)
	c:RegisterEffect(e3)
end
-- 超量召唤手续中判断能否将怪兽直接叠放在自己场上的「DDD」怪兽上：该怪兽需表侧表示且卡名含有0x10af（DDD）字段。
function c46593546.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10af)
end
-- 灵摆效果可选对象的过滤条件：对象需为自己场上表侧表示或墓地里的灵摆怪兽，且该卡没有被禁止使用。
function c46593546.sptgfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 灵摆效果的发动条件和对象选择：需要自己另一边的灵摆区域有卡、有足够怪兽区空格且该卡可以特殊召唤，同时从场上·墓地选择1只符合条件的灵摆怪兽作为对象。
function c46593546.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c46593546.sptgfilter(chkc) end
	local c=e:GetHandler()
	-- 取得自己灵摆区域中除了自身以外的另一张卡（“另一边的自己的灵摆区域的卡”）。
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	-- 检查发动条件：另一边灵摆区有卡存在、自己场上有可用的怪兽区空格、另一边的灵摆卡可以被特殊召唤。
	if chk==0 then return tc and Duel.GetMZoneCount(tp)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己的场上·墓地是否有至少1只满足条件的灵摆怪兽可以作为效果的对象。
		and Duel.IsExistingTarget(c46593546.sptgfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 向操作者显示选择提示，提示内容为“请选择要放置到灵摆区域的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(46593546,4))  --"请选择要放置到灵摆区域的卡"
	-- 从自己的场上·墓地选择1只符合条件的灵摆怪兽作为效果的对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c46593546.sptgfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：效果处理时会将另一边的灵摆区域的卡特殊召唤（记录特殊召唤分类）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 若选择的对象在墓地，则额外设置操作信息：效果处理时该卡会离开墓地（用于相关连锁检测）。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 灵摆效果处理：重新取得另一边的灵摆卡并确认其仍存在、场上有空位后将其特殊召唤；若特殊召唤成功且对象仍与效果关联，则将对象移动到自己的灵摆区域。
function c46593546.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取回另一边的灵摆区域的卡（效果处理时重新确认其位置与状态）。
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	-- 取得发动灵摆效果时选择的对象（即要放置到灵摆区域的灵摆怪兽）。
	local fc=Duel.GetFirstTarget()
	-- 确认另一边的灵摆卡仍然存在且自己场上有可用怪兽区空格。
	if tc and Duel.GetMZoneCount(tp)>0
		-- 将另一边的灵摆卡以表侧表示特殊召唤，并确认特殊召唤成功（返回值大于0）后继续处理。
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and fc:IsRelateToEffect(e) then
		-- 把作为对象的灵摆怪兽移动到自己的灵摆区域（表侧表示放置，并立即适用其效果）。
		Duel.MoveToField(fc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- ②效果的发动条件：对方场上怪兽卡的效果发动，且该效果是在场上发动的（包括魔法陷阱卡发动时产生的效果），同时该发动卡的原类型为怪兽。
function c46593546.ovlcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsControler(1-tp) and rc:GetOriginalType()&TYPE_MONSTER~=0
		and (re:GetActivateLocation()&LOCATION_ONFIELD~=0 or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 用于选择自己场上表侧表示的卡名含有0xae「契约书」字段的卡。
function c46593546.ovltgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xae)
end
-- ②效果发动合法性检查：本卡是XYZ怪兽，满足至少一种代价（可去除2个超量素材或场上有契约书可破坏），且对方那只发动效果的怪兽仍与连锁相关并可以被叠放。
function c46593546.ovltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if chk==0 then return c:IsType(TYPE_XYZ)
		and (c:CheckRemoveOverlayCard(tp,2,REASON_EFFECT)
			-- 检查自己场上是否存在至少1张可破坏的「契约书」卡（作为代替去除素材的选项）。
			or Duel.IsExistingMatchingCard(c46593546.ovltgfilter,tp,LOCATION_ONFIELD,0,1,nil))
		and rc:IsRelateToEffect(re) and rc:IsCanOverlay() end
end
-- ②效果处理：根据选择执行代价——去除2个超量素材或破坏1张「契约书」卡；代价成功后，若对方那只怪兽仍关联、控制者为对方且不免疫此效果，则将其变为本卡的超量素材叠放。
function c46593546.ovlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local opt1=c:IsRelateToEffect(e) and c:CheckRemoveOverlayCard(tp,2,REASON_EFFECT)
	-- 判定自己场上是否存在至少1张可破坏的「契约书」卡，用于提供替代代价选项。
	local opt2=Duel.IsExistingMatchingCard(c46593546.ovltgfilter,tp,LOCATION_ONFIELD,0,1,nil)
	local result=0
	if not opt1 and not opt2 then return end
	if opt1 and not opt2 then result=0 end
	if opt2 and not opt1 then result=1 end
	-- 当两种代价都可行时，让玩家选择：去除2个超量素材（选项0）或破坏自己场上1张「契约书」卡（选项1）。
	if opt1 and opt2 then result=Duel.SelectOption(tp,aux.Stringid(46593546,5),aux.Stringid(46593546,6)) end  --"这张卡2个超量素材取除/自己场上1张「契约书」卡破坏"
	if result==0 then
		result=c:RemoveOverlayCard(tp,2,2,REASON_EFFECT)
	else
		-- 显示选择提示，提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从自己场上选择1张表侧表示的「契约书」卡作为破坏对象。
		local g=Duel.SelectMatchingCard(tp,c46593546.ovltgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 为选中的卡显示被选为对象的动画，并将其记录为对象。
		Duel.HintSelection(g)
		-- 破坏选择的「契约书」卡，并记录实际破坏数量用于后续判定。
		result=Duel.Destroy(g,REASON_EFFECT)
	end
	if result>0 and c:IsRelateToEffect(e)
		and rc:IsRelateToEffect(re) and rc:IsControler(1-tp) and not rc:IsImmuneToEffect(e) then
		local og=rc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 若对方怪兽原本附有超量素材，则将其所有超量素材按规则送去墓地，避免影响叠放。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将对方那只发动效果的怪兽作为超量素材叠放在这张卡下方。
		Duel.Overlay(c,rc)
	end
end
-- ③效果的发动条件：当前回合玩家是自己，即自己的准备阶段。
function c46593546.pencon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（自己的准备阶段时才能发动）。
	return Duel.GetTurnPlayer()==tp
end
-- ③效果的发动目标检查：确认自己的灵摆区域是否有空位可以放置这张卡。
function c46593546.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域的左或右任一格是否为空。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- ③效果处理：若这张卡仍与效果关联，则将其移动到自己的灵摆区域。
function c46593546.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡移动到自己的灵摆区域，以表侧表示放置并立即适用其效果。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
