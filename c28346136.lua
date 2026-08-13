--銀河眼の極光波竜
-- 效果：
-- 10星怪兽×2
-- 「银河眼极光波龙」1回合1次也能在自己场上的「光波龙」怪兽上面重叠来超量召唤。
-- ①：把这张卡2个超量素材取除才能发动。自己场上的光属性怪兽直到对方回合结束时不会成为对方的效果的对象。
-- ②：自己准备阶段才能发动。自己墓地1只9阶以下的龙族超量怪兽回到额外卡组。那之后，可以把那只怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
function c28346136.initial_effect(c)
	aux.AddXyzProcedure(c,nil,10,2,c28346136.ovfilter,aux.Stringid(28346136,0),2,c28346136.xyzop)  --"是否在「光波龙」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：把这张卡2个超量素材取除才能发动。自己场上的光属性怪兽直到对方回合结束时不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28346136,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c28346136.cost)
	e1:SetOperation(c28346136.operation)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段才能发动。自己墓地1只9阶以下的龙族超量怪兽回到额外卡组。那之后，可以把那只怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28346136,2))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c28346136.con)
	e2:SetTarget(c28346136.tg)
	e2:SetOperation(c28346136.op)
	c:RegisterEffect(e2)
end
-- 作为「光波龙」怪兽上重叠超量召唤的替代素材过滤：选择我方场上表侧表示的「光波龙」怪兽作为叠放对象。
function c28346136.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10e5)
end
-- 处理在「光波龙」怪兽上重叠的超量召唤方式的操作：检查并设置该召唤方式1回合1次的誓约标志。
function c28346136.xyzop(e,tp,chk)
	-- 发动条件检测：确认本回合玩家tp尚未使用过该「光波龙」重叠超量召唤方式，以符合1回合1次限制。
	if chk==0 then return Duel.GetFlagEffect(tp,28346136)==0 end
	-- 为玩家tp注册一个回合结束时重置的誓约标志，表示本回合已使用过该特殊召唤方式，防止重复使用。
	Duel.RegisterFlagEffect(tp,28346136,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 效果处理中筛选自己场上表侧表示的光属性怪兽的过滤器：表侧表示且属性为光。
function c28346136.filter1(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- ①效果的发动代价：检测能否从这张卡上取除2个超量素材，执行时实际取除2个超量素材作为代价（REASON_COST）。
function c28346136.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- ①效果的发动处理：给自己场上全部表侧表示的光属性怪兽赋予「不会成为对方的效果的对象」的持续效果（直到对方回合结束时）。
function c28346136.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得自己场上所有满足filter1条件（表侧表示光属性）的怪兽组成的组。
	local g=Duel.GetMatchingGroup(c28346136.filter1,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的光属性怪兽直到对方回合结束时不会成为对方的效果的对象。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		-- 设置效果的判定函数为aux.tgoval，使受保护怪兽不会成为对方玩家发动的效果的对象。
		e3:SetValue(aux.tgoval)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
end
-- ②效果的发动条件：当前回合玩家是这张卡的控制者tp，即自己准备阶段才能发动。
function c28346136.con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为tp玩家的准备阶段（回合玩家等于自己）。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果选择墓地龙族超量怪兽的过滤器：超量怪兽、阶级9以下、龙族、且可以返回额外卡组。
function c28346136.filter(c)
	return c:IsType(TYPE_XYZ) and c:IsRankBelow(9) and c:IsRace(RACE_DRAGON) and c:IsAbleToExtra()
end
-- ②效果发动时的目标检测与操作信息设置：检测墓地存在符合条件的龙族超量怪兽，并设置返回额外卡组的处理信息。
function c28346136.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检测：确认墓地存在至少1只满足filter条件的龙族超量怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28346136.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置当前连锁的操作信息，声明效果包含返回额外卡组分类，预计处理1张来自墓地的对象卡，供相关卡片联动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的实际处理：选择1只墓地符合条件的龙族超量怪兽返回额外卡组，之后由玩家选择是否将其叠放在这张卡上并当作超量召唤从额外卡组特殊召唤。
function c28346136.op(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作玩家显示选择提示，提示文字为「请选择要返回卡组的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1只满足filter条件的龙族超量怪兽作为返回额外卡组的对象。
	local g=Duel.SelectMatchingCard(tp,c28346136.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g==0 then return end
	-- 将选择的龙族超量怪兽以效果原因洗回持有者的额外卡组（返回卡组并洗牌）。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local c=e:GetHandler()
	local sc=g:GetFirst()
	if sc:IsLocation(LOCATION_EXTRA) and c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp)
		and c:IsCanBeXyzMaterial(sc) and sc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 追加确认：额外卡组有可用区域，这张卡可以作为那只怪兽的超量素材，且不因「必须作为超量素材」效果而受限。
		and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 询问玩家是否将返回额外卡组的那只怪兽在这张卡上重叠并当作超量召唤特殊召唤，选择「是」才继续处理。
		and Duel.SelectYesNo(tp,aux.Stringid(28346136,4)) then  --"是否把那只怪兽特殊召唤？"
		-- 中断当前效果处理，使之后的特殊召唤处理视为另开连锁，避免错过时点。
		Duel.BreakEffect()
		local mg=c:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 把这张卡原有的全部超量素材转移叠放到要特殊召唤的怪兽sc下面，保留原有素材。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(c))
		-- 把这张卡自身也作为超量素材叠放到sc下面，实现「在那只怪兽上面重叠」的超量召唤手续。
		Duel.Overlay(sc,Group.FromCards(c))
		-- 将sc以超量召唤的形式特殊召唤到tp场上（表侧攻击表示），并完成超量召唤手续。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
