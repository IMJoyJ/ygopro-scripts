--機雷化するクリボー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，场上有「栗子球」怪兽卡存在的场合才能发动。这张卡特殊召唤。
-- ②：对方把场上的怪兽的效果发动时才能发动。自己场上的这张卡当作持有以下效果的装备魔法卡使用给那只对方怪兽装备。
-- ●装备怪兽的效果无效化。
local s,id,o=GetID()
-- 为这张卡注册两个效果：①在手牌作为起动效果特殊召唤自身；②在场上作为诱发即时效果，当对方发动场上怪兽效果时，将自身作为装备卡装备给那只怪兽并使其效果无效化。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在，场上有「栗子球」怪兽卡存在的场合才能发动。这张卡特殊召唤。
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
-- 过滤函数：判断卡片是否为表侧表示，且持有「栗子球」字段，并且原本种类为怪兽卡。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa4) and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
-- ①效果的发动条件：自己或对方场上存在至少1只满足s.cfilter条件的「栗子球」怪兽卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索场上是否存在满足条件的「栗子球」怪兽卡（表侧表示且为「栗子球」字段的怪兽）。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- ①效果发动时的目标检查：自己主要怪兽区有空位，且这张卡能够被特殊召唤；满足条件后设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示接下来会将这张卡特殊召唤，用于连锁处理和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果保有联系，则将自身特殊召唤上场。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动条件：对方发动了场上怪兽的效果，即效果控制者为对方、效果类型为怪兽效果、且发动区域为怪兽区。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- ②效果发动时检查：自己魔陷区有空位，且对方那只发动效果的怪兽表侧表示存在于怪兽区；通过后建立关联并设置装备操作信息。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local c=e:GetHandler()
	-- 检查自己魔陷区是否有空位，且对象怪兽是否表侧表示并位于怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and rc:IsFaceup() and rc:IsLocation(LOCATION_MZONE) end
	rc:CreateEffectRelation(e)
	-- 设置装备操作信息，表示将这张卡作为装备卡处理。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
-- ②效果处理：若自身仍与效果关联且控制权未转移，则尝试装备给对方怪兽；装备成功后添加装备对象限制和无效化效果；若无法装备则自身送去墓地。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	-- 判断是否仍满足装备条件：自己魔陷区有空位、对象怪兽仍表侧表示且仍与效果关联。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or rc:IsFacedown() or not rc:IsRelateToEffect(e) then
		-- 装备条件不满足时，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
	-- 尝试将这张卡作为装备魔法卡装备给那只对方怪兽。
	elseif Duel.Equip(tp,c,rc) then
		-- 自己场上的这张卡当作持有以下效果的装备魔法卡使用给那只对方怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetLabelObject(rc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- ●装备怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备对象限制函数：这张卡只能装备给记录在LabelObject中的那只对方怪兽。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
