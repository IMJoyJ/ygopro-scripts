--トランシケーダ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。在自己场上把1只「蝉蜕衍生物」（昆虫族·地·3星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物在怪兽区域存在，自己不是昆虫族怪兽不能从额外卡组特殊召唤。
function c1799464.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡特殊召唤成功的场合才能发动。在自己场上把1只「蝉蜕衍生物」（昆虫族·地·3星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物在怪兽区域存在，自己不是昆虫族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1799464,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,1799464)
	e1:SetTarget(c1799464.sptg)
	e1:SetOperation(c1799464.spop)
	c:RegisterEffect(e1)
end
-- 该效果发动时的合法性判定：检查自己主要怪兽区是否有空位，且自己能否特殊召唤“蝉蜕衍生物”，满足条件才允许发动。
function c1799464.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用空格，作为效果能否发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否允许自己特殊召唤“蝉蜕衍生物”（昆虫族·地·3星·攻/守0的衍生物），作为效果能否发动的条件之一。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,1799465,0,TYPES_TOKEN_MONSTER,0,0,3,RACE_INSECT,ATTRIBUTE_EARTH) end
	-- 设置本次连锁的操作信息：包含衍生物分类（CATEGORY_TOKEN），预期处理1只衍生物；不取对象，用于供其他卡片的发动条件检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本次连锁的操作信息：包含特殊召唤分类（CATEGORY_SPECIAL_SUMMON），预期处理1只怪兽；不取对象，用于供其他卡片的发动条件检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理实现：若主要怪兽区仍有空位且允许特殊召唤衍生物，则创建并特殊召唤1只“蝉蜕衍生物”，并给该衍生物赋予“存在期间自己不能从额外卡组特殊召唤非昆虫族怪兽”的永续效果，最后完成特殊召唤。
function c1799464.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区是否存在可用空格，以保证特殊召唤能够进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 处理时再次确认是否允许特殊召唤“蝉蜕衍生物”，以保证特殊召唤能够进行。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,1799465,0,TYPES_TOKEN_MONSTER,0,0,3,RACE_INSECT,ATTRIBUTE_EARTH) then
		-- 在自己场上生成1只卡号为1799465的“蝉蜕衍生物”token。
		local token=Duel.CreateToken(tp,1799465)
		-- 将生成的衍生物以表侧表示特殊召唤到自己场上（作为特殊召唤过程的一步）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的衍生物在怪兽区域存在，自己不是昆虫族怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c1799464.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成整个特殊召唤过程，正式结算所有已执行的特殊召唤步骤。
		Duel.SpecialSummonComplete()
	end
end
-- 定义限制效果的条件：目标怪兽在额外卡组且种族不是昆虫时，不能进行特殊召唤。
function c1799464.splimit(e,c)
	return not c:IsRace(RACE_INSECT) and c:IsLocation(LOCATION_EXTRA)
end
