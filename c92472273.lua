--終刻竜機ⅩⅡ－ドラスティア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张「终刻」卡为对象才能发动。那张卡破坏，这张卡从手卡特殊召唤。那之后，可以从卡组把1张装备魔法卡给这张卡装备。
-- ②：自己·对方回合，这张卡有装备卡装备的场合才能发动。把持有和这张卡的等级相同数值的阶级的1只机械族·风属性超量怪兽当作超量召唤从额外卡组特殊召唤，把这张卡以及这张卡的装备卡全部作为那超量素材。
local s,id,o=GetID()
-- 注册该卡的效果：①手卡发动破坏场上「终刻」卡并特召自身，之后可从卡组装备装备魔法；②场上有装备卡时，在自己·对方回合将额外卡组与自身等级相同阶级的机械族·风属性超量怪兽当作超量召唤特召，并将自身及装备卡作为超量素材。
function s.initial_effect(c)
	-- ①：以自己场上1张「终刻」卡为对象才能发动。那张卡破坏，这张卡从手卡特殊召唤。那之后，可以从卡组把1张装备魔法卡给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，这张卡有装备卡装备的场合才能发动。把持有和这张卡的等级相同数值的阶级的1只机械族·风属性超量怪兽当作超量召唤从额外卡组特殊召唤，把这张卡以及这张卡的装备卡全部作为那超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.xyzcon)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数：筛选自己场上表侧表示的「终刻」卡，且该卡破坏后能腾出怪兽区域。
function s.desfilter(c,tp)
	-- 过滤条件：表侧表示、属于「终刻」系列，且该卡离场后自己场上有可用于特殊召唤的怪兽区域。
	return c:IsFaceup() and c:IsSetCard(0x1d2) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义效果①的发动准备与合法性检测函数：检测自身是否能特殊召唤，以及场上是否存在可作为对象的「终刻」卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.desfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在至少1张满足过滤条件的「终刻」卡作为对象。
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 给玩家发送选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1张满足过滤条件的「终刻」卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置效果处理信息：破坏选中的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：特殊召唤手牌中的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义过滤函数：筛选卡组中可装备给该卡的装备魔法卡。
function s.eqfilter(c,ec,tp)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
-- 定义效果①的效果处理函数：破坏对象卡，特殊召唤自身，并可选择从卡组给自身装备1张装备魔法卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍存在于场上，则将其因效果破坏。
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 若自身卡片仍存在于手牌，则将其表侧表示特殊召唤。
		if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
			-- 检查卡组中是否存在可装备给这张卡的装备魔法卡。
			and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
			-- 检查魔法与陷阱区域是否有空位，并询问玩家是否选择装备。
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否装备装备卡？"
			-- 中断当前效果处理，使后续的装备处理与特殊召唤不视为同时进行（造成错时点）。
			Duel.BreakEffect()
			-- 给玩家发送选择提示：请选择要装备的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 从卡组中选择1张满足条件的装备魔法卡。
			local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,c,tp)
			local ec=g:GetFirst()
			-- 若成功选出装备魔法卡，则将其作为装备卡装备给这张卡。
			if ec then Duel.Equip(tp,ec,c) end
		end
	end
end
-- 定义效果②的发动条件函数：自身有装备卡装备，且自身及所有装备卡均可作为超量素材。
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	-- 检查装备卡数量大于0，且所有装备卡都满足可以作为超量素材叠放的条件。
	return g:GetCount()>0 and not g:IsExists(aux.NOT(Card.IsCanOverlay),1,nil)
end
-- 定义过滤函数：筛选额外卡组中满足条件的机械族·风属性超量怪兽，其阶级须与这张卡的等级相同。
function s.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRank(lv) and c:IsAllTypes(TYPE_XYZ+TYPE_MONSTER)
		-- 检查该超量怪兽是否能以超量召唤的方式特殊召唤，且额外怪兽区域或有指向的怪兽区域有空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 定义效果②的发动准备与合法性检测函数：自身可作为超量素材，满足必须成为素材的限制，且额外卡组存在可特殊召唤的怪兽。
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanOverlay()
		-- 检查是否存在必须作为超量素材的卡片限制。
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组中是否存在阶级与这张卡等级相同的机械族·风属性超量怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel()) end
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 向对方玩家提示当前发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 定义效果②的效果处理函数：从额外卡组将满足条件的超量怪兽当作超量召唤特殊召唤，并将自身及所有装备卡重叠作为其超量素材。
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or c:IsFacedown() then return end
	-- 再次检查必须作为超量素材的卡片限制，若不满足则不处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 给玩家发送选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的机械族·风属性超量怪兽。
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c:GetLevel())
	local sc=sg:GetFirst()
	-- 若成功选出，则将其当作超量召唤表侧表示特殊召唤。
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		sc:CompleteProcedure()
		local g=c:GetEquipGroup()
		g:AddCard(c)
		-- 将这张卡以及这张卡的装备卡全部重叠作为该超量怪兽的超量素材。
		Duel.Overlay(sc,g)
	end
end
