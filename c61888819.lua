--インヴェルズ・オリジン
--not fully implemented
-- 效果：
-- 「入魔」怪兽2只
-- ①：只要这张卡在额外怪兽区域存在，双方要从额外卡组往主要怪兽区域把怪兽特殊召唤的场合，不在这张卡所连接区不能出现。
-- ②：只要这张卡所连接区有怪兽存在，这张卡不会成为效果的对象，不会被战斗·效果破坏。
-- ③：1回合1次，场上的怪兽被战斗·效果破坏时才能发动。把最多有那些破坏的怪兽数量的4星以下的「入魔」怪兽从卡组守备表示特殊召唤。
function c61888819.initial_effect(c)
	-- 设置连接召唤手续，需要2只「入魔」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xa),2,2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在额外怪兽区域存在，双方要从额外卡组往主要怪兽区域把怪兽特殊召唤的场合，不在这张卡所连接区不能出现。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_EXTRA,LOCATION_EXTRA)
	e1:SetCondition(c61888819.frccon)
	e1:SetValue(c61888819.frcval)
	c:RegisterEffect(e1)
	-- ②：只要这张卡所连接区有怪兽存在，这张卡不会成为效果的对象，不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c61888819.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
	-- ③：1回合1次，场上的怪兽被战斗·效果破坏时才能发动。把最多有那些破坏的怪兽数量的4星以下的「入魔」怪兽从卡组守备表示特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(61888819,0))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e6:SetCountLimit(1)
	e6:SetCondition(c61888819.spcon)
	e6:SetTarget(c61888819.sptg)
	e6:SetOperation(c61888819.spop)
	c:RegisterEffect(e6)
end
-- 判断这张卡是否在额外怪兽区域（格子编号大于4）
function c61888819.frccon(e)
	return e:GetHandler():GetSequence()>4
end
-- 返回允许特殊召唤的区域，即这张卡所连接的区域以及额外怪兽区域本身
function c61888819.frcval(e,c,fp,rp,r)
	return e:GetHandler():GetLinkedZone() | 0x600060
end
-- 判断这张卡所连接区是否有怪兽存在
function c61888819.indcon(e)
	return e:GetHandler():GetLinkedGroupCount()>0
end
-- 过滤在怪兽区域被战斗或效果破坏的卡片
function c61888819.cfilter(c)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 判断是否有场上的怪兽被战斗或效果破坏
function c61888819.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c61888819.cfilter,1,nil)
end
-- 过滤卡组中可以守备表示特殊召唤的4星以下的「入魔」怪兽
function c61888819.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xa) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的发动准备与合法性检测
function c61888819.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己场上是否有可用的主要怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动效果时，检查卡组中是否存在至少1只满足条件的「入魔」怪兽
		and Duel.IsExistingMatchingCard(c61888819.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	local ct=eg:FilterCount(c61888819.cfilter,nil)
	e:SetLabel(ct)
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的实际处理逻辑
function c61888819.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的主要怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	ft=math.min(ft,e:GetLabel())
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择最多等同于破坏数量且不超过可用格子数的满足条件的「入魔」怪兽
	local g=Duel.SelectMatchingCard(tp,c61888819.spfilter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
