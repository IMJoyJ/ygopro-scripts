--RUM－ヌメロン・フォース
-- 效果：
-- ①：以自己场上1只超量怪兽为对象才能发动。和那只自己怪兽相同种族而阶级高1阶的1只「混沌No.」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。那之后，这个效果特殊召唤的怪兽以外的场上的全部表侧表示的卡的效果无效化。
function c48333324.initial_effect(c)
	-- ①：以自己场上1只超量怪兽为对象才能发动。和那只自己怪兽相同种族而阶级高1阶的1只「混沌No.」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。那之后，这个效果特殊召唤的怪兽以外的场上的全部表侧表示的卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c48333324.target)
	e1:SetOperation(c48333324.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断c能否作为效果对象，必须是表侧表示的超量怪兽，且额外卡组存在符合条件（同种族、阶级+1、混沌No.）可特殊召唤的怪兽，且c未被‘必须作为超量素材’效果限制。
function c48333324.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查额外卡组是否存在至少1只满足filter2条件的「混沌No.」怪兽（与对象怪兽同种族、阶级高1阶、可作为超量素材、可特殊召唤且有额外区空格）。
		and Duel.IsExistingMatchingCard(c48333324.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1,c:GetRace(),c:GetCode())
		-- 确认对象怪兽c没有受到‘必须作为超量素材’的限制，即c可以正常作为超量素材被使用。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤函数：判断额外卡组候选怪兽是否符合升阶条件：必须是阶级为对象阶级+1、种族与对象相同、属于「混沌No.」字段（0x1048），并且能够叠放在对象怪兽上进行超量召唤；同时有特殊限制：若候选卡是特定卡且对象不是指定卡则不可选择。
function c48333324.filter2(c,e,tp,mc,rk,rc,code)
	if c:GetOriginalCode()==6165656 and code~=48995978 then return false end
	return c:IsRank(rk) and c:IsRace(rc) and c:IsSetCard(0x1048) and mc:IsCanBeXyzMaterial(c)
		-- 检查候选怪兽能够以超量召唤形式被当前效果特殊召唤，并且从额外卡组特殊召唤到场上有足够空格（考虑对象怪兽离开后空出的位置）。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- target函数：效果发动时的对象选择和合法性判定。若为连锁处理校验目标（chkc），则校验目标是否为自己场上合法超量怪兽；若为发动合法性检查（chk==0），则检查自己场上是否存在合法目标；然后提示玩家选择对象，并将所选目标设为连锁对象，同时设置操作信息为从额外卡组特殊召唤。
function c48333324.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c48333324.filter1(chkc,e,tp) end
	-- 发动合法性检查：确认自己场上存在至少1只满足filter1条件的表侧表示超量怪兽，才可以发动此卡。
	if chk==0 then return Duel.IsExistingTarget(c48333324.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送选择对象的提示缓存，提示内容为‘请选择效果的对象’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从我方怪兽区选择1只满足filter1条件的超量怪兽作为效果对象，并自动登记为当前连锁的对象。
	Duel.SelectTarget(tp,c48333324.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置本次效果的操作信息：效果处理时会从额外卡组特殊召唤1只怪兽（具体卡在处理时确定，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- activate函数：效果处理时，先确认对象仍合法；接着从额外卡组选择符合条件的「混沌No.」怪兽，将对象原有的素材和对象本身叠放为素材，以超量召唤形式特殊召唤该怪兽并完成超量召唤手续；然后将场上（除该怪兽外）所有表侧表示的效果怪兽、魔法陷阱卡的效果无效化。
function c48333324.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽tc。
	local tc=Duel.GetFirstTarget()
	-- 效果处理时再次确认对象tc可以作为超量素材（未被‘必须作为超量素材’之类的效果限制），否则效果不处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 向玩家发送选择要特殊召唤的卡片的提示缓存，提示内容为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足filter2条件的「混沌No.」怪兽（以对象怪兽的阶级+1、种族、卡号作为筛选条件）。
	local g=Duel.SelectMatchingCard(tp,c48333324.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,tc:GetRace(),tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原有的超量素材mg全部叠放到新选择的混沌No.怪兽sc下方，作为sc的超量素材。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽tc自身也叠放到sc下方，完成升阶动作（在作为对象的怪兽上面重叠）。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将sc以超量召唤形式表侧表示特殊召唤到tp场上（视为一次正式的超量召唤）。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		-- 取得场上除刚特殊召唤的sc以外的所有表侧表示卡片（含双方怪兽区和魔法陷阱区）。
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,sc)
		if c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			g1:RemoveCard(c)
		end
		if g1:GetCount()>0 then
			-- 中断当前效果处理，使之后的无效化效果处理视为新的效果处理时段，避免与特殊召唤同时处理（产生正确时点）。
			Duel.BreakEffect()
		end
		-- 从这些表侧卡片中筛选出所有可以被无效化效果影响的卡（效果怪兽、表侧魔法陷阱卡、陷阱怪兽）。
		local ng=g1:Filter(aux.NegateAnyFilter,nil)
		local nc=ng:GetFirst()
		while nc do
			-- 那之后，这个效果特殊召唤的怪兽以外的场上的全部表侧表示的卡的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			nc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			nc:RegisterEffect(e2)
			if nc:IsType(TYPE_TRAPMONSTER) then
				local e3=e1:Clone()
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				nc:RegisterEffect(e3)
			end
			nc=ng:GetNext()
		end
	end
end
