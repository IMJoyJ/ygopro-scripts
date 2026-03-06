--邪神官チラム・サバク
-- 效果：
-- 「邪神官 契伦·沙巴」的②的效果1回合只能使用1次。
-- ①：自己手卡是5张以上的场合，这张卡可以不用解放作召唤。
-- ②：这张卡被战斗破坏送去墓地时才能发动。这张卡从墓地守备表示特殊召唤。这个效果特殊召唤的这张卡当作调整使用。
function c27103517.initial_effect(c)
	-- 效果原文：①：自己手卡是5张以上的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27103517,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c27103517.sumcon)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡被战斗破坏送去墓地时才能发动。这张卡从墓地守备表示特殊召唤。这个效果特殊召唤的这张卡当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCountLimit(1,27103517)
	e2:SetCondition(c27103517.spcon)
	e2:SetTarget(c27103517.sptg)
	e2:SetOperation(c27103517.spop)
	c:RegisterEffect(e2)
end
c27103517.treat_itself_tuner=true
-- 满足条件时可以不用解放作召唤，条件为：手卡数量不少于5张且场上怪兽区有空位且等级不低于5。
function c27103517.sumcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断召唤时是否满足不需解放的条件，即等级不低于5且场上怪兽区有空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡数量是否不少于5张。
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=5
end
-- 判断该卡是否在墓地，即被战斗破坏送去墓地后才能发动此效果。
function c27103517.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 判断是否可以将该卡特殊召唤，条件为场上怪兽区有空位且该卡可以被特殊召唤。
function c27103517.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位可以进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息，表示将要特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，并在成功后为该卡添加调整属性。
function c27103517.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否能参与特殊召唤，且特殊召唤成功。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 效果原文：这个效果特殊召唤的这张卡当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
