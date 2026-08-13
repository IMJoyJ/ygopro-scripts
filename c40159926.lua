--ミラー・リゾネーター
-- 效果：
-- 「镜子共鸣者」的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，从额外卡组特殊召唤的怪兽只有对方场上才存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。这张卡在这个回合作为同调素材的场合，当作和作为对象的怪兽的原本等级相同等级使用。
function c40159926.initial_effect(c)
	-- 「镜子共鸣者」的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，从额外卡组特殊召唤的怪兽只有对方场上才存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40159926,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,40159926)
	e1:SetCondition(c40159926.condition)
	e1:SetTarget(c40159926.target)
	e1:SetOperation(c40159926.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。这张卡在这个回合作为同调素材的场合，当作和作为对象的怪兽的原本等级相同等级使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40159926,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c40159926.lvtg)
	e2:SetOperation(c40159926.lvop)
	c:RegisterEffect(e2)
end
-- 定义过滤器：判断怪兽是否为从额外卡组特殊召唤的怪兽（即“从额外卡组特殊召唤的怪兽”的判定条件）。
function c40159926.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果①的发动条件判定：对方场上有从额外卡组特殊召唤的怪兽，且自己场上没有从额外卡组特殊召唤的怪兽，满足“从额外卡组特殊召唤的怪兽只有对方场上才存在”。
function c40159926.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认对方场上至少存在1只从额外卡组特殊召唤的怪兽。
	return Duel.IsExistingMatchingCard(c40159926.cfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 同时确认自己场上不存在从额外卡组特殊召唤的怪兽。
		and not Duel.IsExistingMatchingCard(c40159926.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①发动时的合法性检查：自己场上有可用的主要怪兽区空格，且这张卡自身满足特殊召唤条件，可以被特殊召唤。
function c40159926.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格（用于特殊召唤这张卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息：声明本效果将进行特殊召唤，处理对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理：先确认这张卡仍与发动时的效果关联；若已不关联则处理不适用。随后将这张卡以表侧表示特殊召唤到自己场上；若特殊召唤成功，则给它附加‘从场上离开的场合除外’的离场效果（将离场去向改为除外区）。
function c40159926.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到自己场上；若特殊召唤成功（返回值>0），则继续附加离场除外效果。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
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
-- 定义②效果对象的过滤器：对方场上的表侧表示怪兽，且原本等级大于0（拥有可供参照的原本等级）。
function c40159926.lvfilter(c)
	return c:IsFaceup() and c:GetOriginalLevel()>0
end
-- ②效果发动时的取对象处理：先检查对方场上是否存在符合条件的表侧表示怪兽；若存在，则提示玩家选择其中1只，并将其登记为效果对象。
function c40159926.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c40159926.lvfilter(chkc) end
	-- ②效果发动合法性检测：对方场上是否存在至少1只符合条件的可选取对象怪兽（表侧表示且原本等级>0）。
	if chk==0 then return Duel.IsExistingTarget(c40159926.lvfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发出‘请选择表侧表示的卡’的UI选择提示，用于后续选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只符合条件的表侧表示怪兽，并将所选卡登记为②效果的对象（取对象）。
	Duel.SelectTarget(tp,c40159926.lvfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理：若这张卡仍表侧表示且与效果关联、对象怪兽仍合法且表侧，则为这张卡附加‘作为同调素材时等级视为对象怪兽原本等级’的效果，持续到回合结束；同时设置等级提示数字。
function c40159926.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果发动时选择的对象怪兽（因为只取1张对象，直接用Duel.GetFirstTarget获取）。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这张卡在这个回合作为同调素材的场合，当作和作为对象的怪兽的原本等级相同等级使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_LEVEL)
		e1:SetValue(tc:GetOriginalLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		c:SetHint(CHINT_NUMBER,tc:GetOriginalLevel())
	end
end
