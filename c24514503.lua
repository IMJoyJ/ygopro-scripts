--心を凍らせるスノークリスタル
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上的怪兽数量比对方场上的怪兽少2只以上的场合才能发动。这张卡特殊召唤。
-- ②：场上的这张卡不会被效果破坏。
-- ③：以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效。
local s,id,o=GetID()
-- 初始化卡片效果：①我方怪兽比对方少2只以上时从手牌特殊召唤；②在场上不会被效果破坏；③取对方场上1只效果怪兽为对象无效其效果。
function s.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：这张卡在手卡存在，自己场上的怪兽数量比对方场上的怪兽少2只以上的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判断：对方场上怪兽数量减去我方场上怪兽数量大于等于2（即我方怪兽比对方少2只以上）时满足条件。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 统计对方怪兽数与己方怪兽数，判断差值是否≥2。
	return Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=2
end
-- ①效果发动时的合法性检查：chk==0时，判断自己场上是否有可用怪兽区且这张卡是否可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，若无空闲区域则不能发动特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本效果将特殊召唤这张卡（CATEGORY_SPECIAL_SUMMON），数量1，供后续时点和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：如果这张卡仍与当前效果关联，则将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到其持有者（tp）的怪兽区域，不改变控制权。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的目标选择流程：在指定对象时校验对象合法性；在发动前确认存在合法对象；给出选择提示并让玩家选择对象，然后设置无效效果的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 若当前连锁指定了对象（chkc），则校验该对象必须满足：对方场上、怪兽区域、表侧效果怪兽，否则不能作为本效果对象。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 发动时检查对方场上是否存在至少1只表侧效果怪兽可作为对象；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动玩家显示选择提示：‘请选择要无效的卡’（HINTMSG_DISABLE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让发动玩家从对方场上选择1只表侧效果怪兽作为效果对象，并记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本效果将使对象怪兽的效果无效（CATEGORY_DISABLE），对象为已选择的g，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ③效果处理：若对象仍与效果关联且表侧表示存在，则为对象怪兽附加效果无效和效果无效化状态，使其效果被无效，并在标准重置事件发生时解除。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的第一个对象卡片（即③效果选择的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsCanBeDisabledByEffect(e) then
		-- 那只怪兽的效果无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果无效。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
