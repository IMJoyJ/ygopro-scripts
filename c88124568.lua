--SPYRAL－ダブルフェイク
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己的场上或墓地有「秘旋谍」卡存在的场合才能发动。这张卡从手卡往对方场上守备表示特殊召唤。那之后，双方卡组最上面的卡给双方确认。这个效果特殊召唤的这张卡不能解放，也不能作为融合·同调·超量·连接召唤的素材。
-- ②：场上的「秘旋谍」怪兽的攻击力上升500，「秘旋谍-花公子」可以直接攻击。
local s,id,o=GetID()
-- 注册卡片效果：①效果（手卡特召+确认卡组顶+限制素材），②效果（攻击力上升与直接攻击）
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己的场上或墓地有「秘旋谍」卡存在的场合才能发动。这张卡从手卡往对方场上守备表示特殊召唤。那之后，双方卡组最上面的卡给双方确认。这个效果特殊召唤的这张卡不能解放，也不能作为融合·同调·超量·连接召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 「秘旋谍-花公子」可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 过滤直接攻击效果的适用对象为卡名是「秘旋谍-花公子」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,41091257))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	-- 过滤攻击力上升效果的适用对象为「秘旋谍」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xee))
	e3:SetValue(500)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示或墓地存在的「秘旋谍」卡
function s.filter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xee)
end
-- ①效果的发动条件：自己的场上或墓地有「秘旋谍」卡存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的场上（表侧表示）或墓地是否存在至少1张「秘旋谍」卡
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil)
end
-- ①效果的发动准备（检查对方场上是否有空位、自身能否特召、双方卡组是否有卡，并设置特殊召唤的操作信息）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查对方场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
		-- 检查双方卡组是否都至少存在1张卡
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	-- 设置特殊召唤的操作信息（特殊召唤1张自身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：将自身往对方场上守备表示特殊召唤，并赋予不能解放、不能作为融合/同调/超量/连接召唤素材的永续效果，之后双方确认卡组最上方的卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡以守备表示特殊召唤到对方场上
	local chk=Duel.SpecialSummonStep(c,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	if chk then
		-- 不能解放
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetRange(LOCATION_MZONE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e3:SetValue(s.lim)
		c:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		c:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		c:RegisterEffect(e5)
		local e6=e1:Clone()
		e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		c:RegisterEffect(e6)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
	if chk then
		-- 中断当前效果处理，用于连接“那之后”的后续处理
		Duel.BreakEffect()
		-- 确认自己卡组最上面的1张卡
		Duel.ConfirmDecktop(tp,1)
		-- 确认对方卡组最上面的1张卡
		Duel.ConfirmDecktop(1-tp,1)
	end
end
-- 限制融合素材的辅助函数，仅在进行融合召唤时限制其不能作为素材
function s.lim(e,c,st)
	return st==SUMMON_TYPE_FUSION
end
