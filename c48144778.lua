--インフェルニティ・コンジュラー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己手卡是0张，对方场上的怪兽的攻击力下降800。
-- ②：这张卡在墓地存在，自己手卡是0张的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c48144778.initial_effect(c)
	-- ①：只要自己手卡是0张，对方场上的怪兽的攻击力下降800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-800)
	e1:SetCondition(c48144778.atkcon)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己手卡是0张的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48144778,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,48144778)
	e2:SetCondition(c48144778.spcon)
	e2:SetTarget(c48144778.sptg)
	e2:SetOperation(c48144778.spop)
	c:RegisterEffect(e2)
end
-- 判断是否满足效果①的发动条件：自己手卡为0张
function c48144778.atkcon(e)
	-- 自己手卡数量为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
-- 判断是否满足效果②的发动条件：自己手卡为0张
function c48144778.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己手卡数量为0
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 设置效果②的发动目标：确认特殊召唤的条件是否满足
function c48144778.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域以及该卡能否被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果②的处理程序：将卡特殊召唤到场上并设置除外条件
function c48144778.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡能被正常特殊召唤且成功召唤后进行后续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置特殊召唤后离场时的去向为除外区
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
