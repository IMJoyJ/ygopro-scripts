--フィッシュボーグ－ドクター
-- 效果：
-- 「电子鱼人-博士」的②的效果1回合只能使用1次。
-- ①：自己场上有「电子鱼人」怪兽以外的怪兽存在的场合这张卡破坏。
-- ②：这张卡在墓地存在，自己场上的怪兽只有「电子鱼人」怪兽的场合，自己主要阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c10560119.initial_effect(c)
	-- ①：自己场上有「电子鱼人」怪兽以外的怪兽存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c10560119.sdcon)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上的怪兽只有「电子鱼人」怪兽的场合，自己主要阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10560119,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,10560119)
	e2:SetCondition(c10560119.spcon)
	e2:SetTarget(c10560119.sptg)
	e2:SetOperation(c10560119.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在非电子鱼人怪兽
function c10560119.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x96)
end
-- 效果①的发动条件函数，判断是否满足破坏条件
function c10560119.sdcon(e)
	-- 检查以玩家来看的自己的场上是否存在非电子鱼人怪兽
	return Duel.IsExistingMatchingCard(c10560119.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动条件函数，判断是否满足特殊召唤条件
function c10560119.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取以玩家来看的自己的场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return g:GetCount()>0 and not g:IsExists(c10560119.cfilter,1,nil)
end
-- 效果②的发动时的处理函数，用于设置特殊召唤的目标和数量
function c10560119.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件，包括场上是否有空位和卡片是否可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前处理的连锁的操作信息，确定要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的发动时的处理函数，用于执行特殊召唤操作
function c10560119.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否与当前效果相关并且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 特殊召唤后，设置该卡离开场上时被除外的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
