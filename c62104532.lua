--RUM－幻影騎士団レクイエム
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的墓地·除外状态的1只「幻影骑士团」怪兽或「超量龙」怪兽为对象才能发动。那只怪兽效果无效特殊召唤。那之后，以下效果适用。
-- ●选自己场上1只暗属性超量怪兽，比那只怪兽阶级高1阶的1只「幻影骑士团」超量怪兽或「超量龙」超量怪兽在选的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 在卡片的效果初始化函数中，注册该卡的发动效果，设定其效果分类为特殊召唤、取对象、同名卡每回合限发动一次等属性。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己的墓地·除外状态的1只「幻影骑士团」怪兽或「超量龙」怪兽为对象才能发动。那只怪兽效果无效特殊召唤。那之后，以下效果适用。●选自己场上1只暗属性超量怪兽，比那只怪兽阶级高1阶的1只「幻影骑士团」超量怪兽或「超量龙」超量怪兽在选的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己场上表侧表示的暗属性超量怪兽，且其必须满足作为超量素材的限制。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
		-- 检查怪兽是否满足必须作为超量素材的规则限制。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤函数：用于筛选墓地或除外状态，满足特殊召唤条件的「幻影骑士团」或「超量龙」怪兽，且特召后场上存在能作为超量素材进行升阶超量召唤的暗属性超量怪兽。
function s.spfilter(c,e,tp,g)
	local sg=g:Clone()
	sg:AddCard(c)
	return c:IsFaceupEx() and c:IsSetCard(0x10db,0x2073)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and sg:IsExists(s.stfilter,1,nil,e,tp)
end
-- 过滤函数：用于筛选自己场上满足超量素材限制的暗属性超量怪兽，且额外卡组存在比其高1阶的「幻影骑士团」或「超量龙」超量怪兽可以用于重叠召唤。
function s.stfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
		-- 检查该怪兽是否满足必须作为超量素材的限制。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在高1阶、可用于叠放超量召唤的合法超量怪兽。
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank())
end
-- 过滤函数：筛选额外卡组中比素材怪兽阶级高1阶的「幻影骑士团」或「超量龙」超量怪兽，且该怪兽可进行超量召唤并有可用的额外怪兽区域。
function s.xyzfilter(c,e,tp,mc,rk)
	if c:GetOriginalCode()==6165656 and not mc:IsCode(48995978) then return false end
	return c:IsRank(rk+1) and c:IsSetCard(0x10db,0x2073) and mc:IsCanBeXyzMaterial(c)
		-- 检查该额外怪兽是否能作为超量召唤特殊召唤，以及进行升阶时额外怪兽区域是否有空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的效果目标处理函数，负责校验发动条件（包括特召两次、格子数量、超量素材限制等）并选择合法的对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上所有可作为超量素材的暗属性超量怪兽的卡片组。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,tp)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.spfilter(chkc,e,tp,g) end
	-- 检查玩家本回合是否被允许特殊召唤至少2次。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己场上是否有空余的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家自身是否受到必须使用特定超量素材的规则限制。
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查墓地或除外状态中是否存在能被特殊召唤且能满足后续超量召唤条件的卡片。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,g) end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家在墓地或除外怪兽中选择1只符合条件的卡片作为效果处理对象。
	local sg=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,g)
	-- 设置连锁处理的操作信息，声明本次效果最多会从墓地/除外和额外卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,2,tp,LOCATION_EXTRA)
end
-- 卡片效果处理函数，负责将选定对象特殊召唤并无效其效果，随后让玩家选择场上1只暗属性超量怪兽进行重叠超量召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若怪兽区域没有空位则无法进行特殊召唤，效果处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动的连锁中被选作特殊召唤对象的那张卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与该连锁相关、是否免疫该效果，以及是否受到王家长眠之谷的妨碍。
	if not tc:IsRelateToChain() or tc:IsImmuneToEffect(e) or not aux.NecroValleyFilter()(tc) then return end
	-- 尝试以表侧表示特殊召唤该对象怪兽（特召的第一步处理）。
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	else
		return
	end
	-- 完成特殊召唤的处理（执行实际的登场时点刷新）。
	Duel.SpecialSummonComplete()
	-- 检查当前特殊召唤的怪兽是否满足超量素材的限制，以决定后续处理能否继续。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 刷新场上怪兽和怪兽区域的状态，确保后续素材检测准确。
	Duel.AdjustAll()
	-- 向玩家发送提示，指示选择用于重叠超量召唤的素材怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家从场上选择1只满足升阶条件的暗属性超量怪兽作为超量素材。
	local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local xc=g:GetFirst()
	if xc then
		-- 打断当前效果的处理连接，使“特殊召唤”与后续“升阶超量召唤”不视为同时进行。
		Duel.BreakEffect()
		-- 向玩家发送提示，指示在额外卡组中选择要特殊召唤的超量怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家在额外卡组选择1只高1阶且符合条件的「幻影骑士团」或「超量龙」超量怪兽。
		local sg=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,xc,xc:GetRank())
		local sc=sg:GetFirst()
		if sc then
			-- 打断当前效果的处理连接，使后续的叠放召唤处理不与前述步骤同时进行。
			Duel.BreakEffect()
			local mg=xc:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将被重叠怪兽原本拥有的所有超量素材转移给新登场的超量怪兽。
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(xc))
			-- 将选中的超量怪兽自身作为素材重叠在要特殊召唤的超量怪兽下方。
			Duel.Overlay(sc,Group.FromCards(xc))
			-- 将选定的超量怪兽以表侧表示当作超量召唤从额外卡组特殊召唤。
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
