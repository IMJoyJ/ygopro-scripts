--機雷化するクリボー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，场上有「栗子球」怪兽卡存在的场合才能发动。这张卡特殊召唤。
-- ②：对方把场上的怪兽的效果发动时才能发动。自己场上的这张卡当作持有以下效果的装备魔法卡使用给那只对方怪兽装备。
-- ●装备怪兽的效果无效化。
local s,id,o=GetID()
-- 创建两个效果，分别对应①特殊召唤和②装备效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，场上有「栗子球」怪兽卡存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方把场上的怪兽的效果发动时才能发动。自己场上的这张卡当作持有以下效果的装备魔法卡使用给那只对方怪兽装备。●装备怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于判断场上是否存在「栗子球」怪兽（正面表示且为怪兽类型）
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa4) and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
-- 判断手牌中的机雷化的栗子球是否可以发动特殊召唤效果（场上有栗子球怪兽）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1张「栗子球」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 设置特殊召唤的发动条件和目标，判断是否满足召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将此卡从手牌特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤动作，以正面表示形式召唤到玩家场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否满足装备效果发动条件（对方怪兽在场上发动效果）
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- 设置装备效果的发动目标和条件，判断是否可以装备
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local c=e:GetHandler()
	-- 检查玩家场上是否有足够的魔法陷阱区域，并确认目标怪兽正面表示且在场上
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and rc:IsFaceup() and rc:IsLocation(LOCATION_MZONE) end
	rc:CreateEffectRelation(e)
	-- 设置连锁操作信息，表示将要装备此卡到对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
-- 执行装备效果的操作，包括装备限制和效果无效化
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	-- 判断是否满足装备失败条件（无空位、目标怪兽背向或不在场）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or rc:IsFacedown() or not rc:IsRelateToEffect(e) then
		-- 若装备失败，则将此卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	-- 若装备成功，则设置装备限制和效果无效化效果
	elseif Duel.Equip(tp,c,rc) then
		-- 设置装备对象限制，确保只能装备给指定的怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetLabelObject(rc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置装备后使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 定义装备对象限制函数，确保只能装备给特定怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
