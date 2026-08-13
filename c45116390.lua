--重装騎士バベルデッカー
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从手卡把1只机械族·地属性怪兽特殊召唤。
-- ③：对方把卡的效果发动的回合的自己主要阶段才能发动。把1只机械族·地属性·10阶的超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：e1为①无解放召唤的召唤规则效果；e2/e3对应②召唤·特殊召唤成功时从手卡特召机械族·地属性怪兽的诱发效果（e2为召唤成功，e3为特殊召唤成功）；e4对应③在对方发动过效果的回合自己主要阶段从额外卡组超量召唤机械族·地属性·10阶超量怪兽的起动效果；同时注册活动计数器用于检测对方是否发动过效果。
function s.initial_effect(c)
	-- ①：这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从手卡把1只机械族·地属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：对方把卡的效果发动的回合的自己主要阶段才能发动。把1只机械族·地属性·10阶的超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"超量召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
	-- 注册自定义活动计数器，每当有玩家发动效果时计数+1，供③通过查询对方计数来判断对方本回合是否发动过效果。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 计数器过滤函数恒返回false，表示任意玩家发动的效果都会被计入计数器。
function s.chainfilter(re,tp,cid)
	return false
end
-- ②的特召筛选：选择手卡中机械族、地属性且能被该效果特殊召唤的怪兽。
function s.spfilter1(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动条件：自己场上有主要怪兽区空位，且手卡存在上述符合条件的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在满足spfilter1条件（机械族·地属性且可特召）的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示本卡发动了②的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，声明本次效果将进行从手卡特殊召唤1只怪兽的处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②的效果处理：从手卡选择1只符合条件的怪兽，以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查主要怪兽区是否有空位，若无则中断处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足spfilter1条件的机械族·地属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③的发动条件：对方（1-tp）在本回合发动过效果。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 通过自定义计数器检查对方发动效果的次数是否大于0。
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
-- ③的筛选：额外卡组中机械族、地属性、10阶超量怪兽，能以这张卡为超量素材且能通过超量召唤方式特召。
function s.spfilter2(c,e,tp,mc)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsRank(10)
		and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 确认该超量怪兽能进行超量召唤，且额外卡组特召有可用区域（考虑素材离场后腾出区域）。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ③的发动条件：本卡可作为超量素材，且额外卡组存在满足条件的超量怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查这张卡是否具备作为超量素材的资格（不受“必须作为超量素材”等限制）。
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在满足spfilter2条件的超量怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 向对方玩家提示本卡发动了③的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，声明本次效果将进行从额外卡组特殊召唤1只怪兽的处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③的效果处理：从额外卡组选择1只符合条件的超量怪兽，将这张卡及其全部叠放卡作为超量素材叠放，然后以超量召唤方式特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次检查这张卡可否作为超量素材，若受限则效果不适用。
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsRelateToChain() and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要超量召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足spfilter2的超量怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将这张卡原有的超量素材转移给新召唤的超量怪兽。
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将这张卡本身作为超量素材叠放到新超量怪兽下方。
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将选中的超量怪兽以超量召唤方式表侧表示特殊召唤。
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
