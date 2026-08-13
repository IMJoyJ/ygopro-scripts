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
	-- 「电子鱼人-博士」的②的效果1回合只能使用1次。②：这张卡在墓地存在，自己场上的怪兽只有「电子鱼人」怪兽的场合，自己主要阶段才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- 过滤函数：返回true表示该怪兽是里侧表示或不属于「电子鱼人」系列，即视为“不是表侧表示的「电子鱼人」怪兽”。
function c10560119.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x96)
end
-- ①效果的发动条件：自己场上有满足cfilter的怪兽（即存在「电子鱼人」以外的怪兽或里侧表示怪兽）时，这张卡自我破坏。
function c10560119.sdcon(e)
	-- 检查自己怪兽区是否存在至少1只满足cfilter的怪兽。
	return Duel.IsExistingMatchingCard(c10560119.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动条件：自己场上有怪兽，且场上怪兽全部都是表侧表示的「电子鱼人」怪兽（不存在里侧或非电子鱼人怪兽）。
function c10560119.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上主要怪兽区的全部怪兽。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return g:GetCount()>0 and not g:IsExists(c10560119.cfilter,1,nil)
end
-- ②效果的发动目标判定：检查自己主要怪兽区是否有空位，且墓地的这张卡是否可以被特殊召唤。
function c10560119.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）的检查：确认自己主要怪兽区有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁的操作信息设为特殊召唤，处理对象为这张卡自身，数量为1，供其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联且特殊召唤成功，则给它附加“从场上离开的场合除外”的永续效果；若不成功则不处理。
function c10560119.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果有关联，且成功特殊召唤到场上。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
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
