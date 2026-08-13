--RUM－レヴォリューション・フォース
-- 效果：
-- ①：可以把发动回合的以下效果发动。
-- ●自己回合：以自己场上1只「急袭猛禽」超量怪兽为对象才能发动。阶级高1阶的1只「急袭猛禽」怪兽在作为对象的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ●对方回合：以对方场上1只没有超量素材的超量怪兽为对象才能发动。得到那只超量怪兽的控制权。那之后，阶级高1阶的1只「急袭猛禽」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c43476205.initial_effect(c)
	-- 对应效果原文『①：可以把发动回合的以下效果发动。』；此处注册魔法卡发动效果，后续target/activate函数分别实现●自己回合与●对方回合的两种处理。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c43476205.target)
	e1:SetOperation(c43476205.activate)
	c:RegisterEffect(e1)
end
-- 定义自己回合可选对象的过滤条件：对象需为自己场上表侧表示、阶级大于0、字段为「急袭猛禽」的超量怪兽，且额外卡组存在可叠放的高1阶「急袭猛禽」怪兽，并且该对象满足作为超量素材的条件。
function c43476205.filter1(c,e,tp)
	local rk=c:GetRank()
	return rk>0 and c:IsFaceup() and c:IsSetCard(0xba)
		-- 确认额外卡组中存在满足filter3条件的「急袭猛禽」怪兽：其阶级为对象阶级+1，能以对象为超量素材进行特殊召唤，且额外怪兽区域有空位。
		and Duel.IsExistingMatchingCard(c43476205.filter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
		-- 检查对象是否不受“必须作为超量素材”效果的限制（若受该效果影响则不能用来超量召唤）。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 定义对方回合可选对象的过滤条件：对象需为对方场上表侧表示、阶级大于0、没有超量素材、控制权可以变更、满足作为超量素材条件，且额外卡组存在可叠放的高1阶「急袭猛禽」怪兽。
function c43476205.filter2(c,e,tp)
	local rk=c:GetRank()
	-- 过滤条件：对方场上表侧表示、阶级大于0、没有超量素材、控制权可以变更，且该对象不受“必须作为超量素材”效果影响。
	return rk>0 and c:IsFaceup() and c:GetOverlayCount()==0 and c:IsControlerCanBeChanged() and aux.MustMaterialCheck(c,1-tp,EFFECT_MUST_BE_XMATERIAL)
		-- 确认额外卡组中存在满足filter3条件的「急袭猛禽」怪兽：阶级为对象阶级+1，能以对象为素材特殊召唤。
		and Duel.IsExistingMatchingCard(c43476205.filter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
end
-- 定义额外卡组选择要特殊召唤的怪兽的过滤条件：必须是字段「急袭猛禽」且阶级等于对象阶级+1的超量怪兽，对象能成为其超量素材，该怪兽可以超量召唤且额外怪兽区域有空位。
function c43476205.filter3(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0xba) and mc:IsCanBeXyzMaterial(c)
		-- 追加检查：额外卡组的该怪兽能否以超量召唤方式被自己特殊召唤，以及对象离场后是否仍有额外怪兽区域空格供其出场。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的选对象处理：若当前是发动者回合，则选择自己场上1只符合条件的「急袭猛禽」超量怪兽；若是对方回合，则选择对方场上1只没有超量素材的超量怪兽，并设置对应分类（特殊召唤/控制权变更）的操作信息。
function c43476205.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断当前回合玩家是否为效果发动者tp；若是则进入自己回合分支。
	if Duel.GetTurnPlayer()==tp then
		if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c43476205.filter1(chkc,e,tp) end
		-- 自己回合的发动合法性检查：确认自己场上存在至少1只满足filter1条件的怪兽可选为对象。
		if chk==0 then return Duel.IsExistingTarget(c43476205.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 向发动者发送选择对象的提示消息（提示文本为“请选择效果的对象”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 自己回合：从自己场上选择1只满足filter1条件的「急袭猛禽」超量怪兽作为对象，并自动与当前效果建立对象联系。
		Duel.SelectTarget(tp,c43476205.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	else
		if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c43476205.filter2(chkc,e,tp) end
		-- 对方回合的发动合法性检查：确认对方场上存在至少1只满足filter2条件的没有超量素材的超量怪兽可选为对象。
		if chk==0 then return Duel.IsExistingTarget(c43476205.filter2,tp,0,LOCATION_MZONE,1,nil,e,tp) end
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL)
		-- 向发动者发送选择对象的提示消息（对方回合分支，提示文本为“请选择效果的对象”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 对方回合：从对方场上选择1只满足filter2条件的没有超量素材的超量怪兽作为对象，并自动注册为效果对象。
		local g=Duel.SelectTarget(tp,c43476205.filter2,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
		-- 设置操作信息：本次连锁包含改变控制权效果，对象为已选择的g中的卡，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	end
	-- 设置操作信息：本次连锁包含特殊召唤效果，将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：先取得对象；若当前为对方回合，则先获得对象控制权，再选择额外卡组的「急袭猛禽」怪兽叠放在对象上进行超量召唤；若为自己回合则直接选择叠放特殊召唤。
function c43476205.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理阶段要处理的对象（即发动时选择的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断当前是否为对方回合（当前回合玩家不是tp），若是则进入对方回合的处理分支。
	if Duel.GetTurnPlayer()~=tp then
		if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
		-- 尝试获得对方那只超量怪兽的控制权；若获得失败则整个效果处理中止。
		if Duel.GetControl(tc,tp)==0 then return end
		-- 中断当前效果链，使控制权变更与之后的特殊召唤处理视为不同时处理，避免错误时点。
		Duel.BreakEffect()
	end
	-- 再次确认对象可作为超量素材；若不能则终止特殊召唤处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示发动者选择要特殊召唤的卡（提示文本为“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足filter3条件（阶级为对象+1的「急袭猛禽」超量怪兽）的卡用于特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c43476205.filter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象原本叠放着的超量素材全部转移到要特殊召唤的怪兽下面。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽自身也叠放到要特殊召唤的怪兽下面，作为其超量素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选择的「急袭猛禽」怪兽以超量召唤方式表侧表示特殊召唤到发动者场上，完成超量召唤。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
