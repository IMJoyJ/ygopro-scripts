--終刻竜機Ⅶ－エララ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合或者被效果破坏的场合才能发动。从卡组把1张「终刻」魔法·陷阱卡在自己场上盖放。
-- ②：自己·对方回合，这张卡有装备卡装备的场合才能发动。把持有和这张卡的等级相同数值的阶级的1只机械族·风属性超量怪兽当作超量召唤从额外卡组特殊召唤，把这张卡以及这张卡的装备卡全部作为那超量素材。
local s,id,o=GetID()
-- 注册卡片效果，包括召唤·特殊召唤·被效果破坏时从卡组盖放「终刻」魔陷的效果，以及在双方回合将自身及装备卡作为素材超量召唤额外卡组怪兽的效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合或者被效果破坏的场合才能发动。从卡组把1张「终刻」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.setcon)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合，这张卡有装备卡装备的场合才能发动。把持有和这张卡的等级相同数值的阶级的1只机械族·风属性超量怪兽当作超量召唤从额外卡组特殊召唤，把这张卡以及这张卡的装备卡全部作为那超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"超量召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.xyzcon)
	e4:SetTarget(s.xyztg)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
end
-- 判断这张卡是否因效果而被破坏
function s.setcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤卡组中属于「终刻」系列且可以盖放在场上的魔法·陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1d2) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 盖放效果的发动准备，检查卡组中是否存在可盖放的「终刻」魔法·陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「终刻」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放效果的效果处理，从卡组选择1张「终刻」魔法·陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张满足条件的「终刻」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡片在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- 超量召唤效果的发动条件，检查这张卡是否有装备卡装备，且这些装备卡都可以作为超量素材
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	-- 检查装备卡数量大于0，且所有装备卡都满足可以作为超量素材（叠放）的条件
	return g:GetCount()>0 and not g:IsExists(aux.NOT(Card.IsCanOverlay),1,nil)
end
-- 过滤额外卡组中满足条件的怪兽：机械族、风属性、阶级等于指定等级、是超量怪兽、可以被特殊召唤，且额外怪兽区域有空位
function s.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRank(lv) and c:IsAllTypes(TYPE_XYZ+TYPE_MONSTER)
		-- 检查该怪兽是否能以超量召唤的形式特殊召唤，且额外卡组特召的可用格子数大于0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 超量召唤效果的发动准备，检查自身是否能作为超量素材、是否存在必须作为超量素材的限制，以及额外卡组是否存在满足条件的超量怪兽
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanOverlay()
		-- 检查是否存在必须作为超量素材的卡片限制
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在1只阶级与这张卡等级相同的机械族·风属性超量怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel()) end
	-- 设置当前连锁的操作信息，表明此效果包含从额外卡组特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 向对方玩家提示已选择发动该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 超量召唤效果的效果处理，将额外卡组满足条件的超量怪兽当作超量召唤特殊召唤，并将这张卡及装备卡全部作为其超量素材
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or c:IsFacedown() then return end
	-- 效果处理时，再次检查是否存在必须作为超量素材的卡片限制，若不满足则不处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只阶级与这张卡等级相同的机械族·风属性超量怪兽
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c:GetLevel())
	local sc=sg:GetFirst()
	-- 将选择的超量怪兽当作超量召唤特殊召唤，并检查是否特殊召唤成功
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		sc:CompleteProcedure()
		local g=c:GetEquipGroup()
		g:AddCard(c)
		-- 将这张卡以及这张卡的所有装备卡全部重叠作为该超量怪兽的超量素材
		Duel.Overlay(sc,g)
	end
end
