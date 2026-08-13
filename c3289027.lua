--暗黒界の隠者 パアル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被效果从手卡丢弃去墓地的场合，以「暗黑界的隐者 珀尔」以外的自己墓地1只「暗黑界」怪兽为对象才能发动。那只怪兽在自己或者对方场上特殊召唤。被对方的效果丢弃的场合，可以再从自己的手卡·墓地的怪兽以及除外的自己怪兽之中选1只恶魔族怪兽在自己或者对方场上特殊召唤。
local s,id,o=GetID()
-- 创建并注册这张卡的①效果：对应“这个卡名的效果1回合只能使用1次”，将效果设为诱发选发效果，送去墓地时触发，带延迟与取对象标志，并绑定条件、目标与处理函数。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡被效果从手卡丢弃去墓地的场合，以「暗黑界的隐者 珀尔」以外的自己墓地1只「暗黑界」怪兽为对象才能发动。那只怪兽在自己或者对方场上特殊召唤。被对方的效果丢弃的场合，可以再从自己的手卡·墓地的怪兽以及除外的自己怪兽之中选1只恶魔族怪兽在自己或者对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 发动条件判断：将丢弃前这张卡的控制者存入e的标记，要求此卡在被从手卡丢弃后送去墓地，且丢弃原因满足0x4040（丢弃+代价/效果丢弃原因）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 选择对象用过滤：对象必须不是本卡，而是自己墓地的「暗黑界」怪兽，且该怪兽可以被特殊召唤到自己或对方场上。
function s.spfilter(c,e,tp)
	return not c:IsCode(id)
		and c:IsSetCard(0x6) and c:IsType(TYPE_MONSTER)
		-- 判断自己主要怪兽区有空位，且目标怪兽可以满足通常特殊召唤要求地特殊召唤到自己场上。
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		-- 判断对方主要怪兽区有空位，且目标怪兽可以表侧表示特殊召唤到对方场上。
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
-- 发动时的目标选择处理：先校验连锁对象是否合法；无对象时检查墓地存在可特殊召唤的暗黑界怪兽；随后选择1只墓地暗黑界怪兽为对象，设置基本特殊召唤操作信息；若被对方效果丢弃，则额外登记可能追加特殊召唤恶魔族的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动时可发检查：自己墓地存在至少1只符合 spfilter 的暗黑界怪兽作为可特殊召唤的对象。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示语，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合 spfilter 的怪兽作为对象，并自动与当前连锁建立对象联系。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次特殊召唤的操作信息登记为：对象卡确定为g，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	if rp==1-tp and tp==e:GetLabel() then
		-- 额外登记操作信息：若因对方效果丢弃，后续可能从手牌·墓地·除外区特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 追加特殊召唤的搜索/选择过滤：目标必须是恶魔族怪兽，且为手牌或墓地的怪兽，或是除外的表侧怪兽，并能够特殊召唤到自己或对方场上。
function s.spfilter2(c,e,tp)
	return c:IsRace(RACE_FIEND)
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND+LOCATION_GRAVE))
		-- 判断自己主要怪兽区有空位，且该恶魔族怪兽可特殊召唤到自己场上。
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		-- 判断对方主要怪兽区有空位，且该恶魔族怪兽可以表侧表示特殊召唤到对方场上。
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
-- 效果处理：特殊召唤对象怪兽到自己或对方场上；若特召成功且满足被对方效果丢弃的条件，则询问并追加从手牌·墓地·除外区选择1只恶魔族怪兽特殊召唤到自己或对方场上，追加处理前用BreakEffect切分时点。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的墓地暗黑界怪兽作为本次处理的对象。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 判断该对象能否特殊召唤到自己场上（自己主要怪兽区有空位且满足特召条件）。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 判断该对象能否以表侧表示特殊召唤到对方场上（对方主要怪兽区有空位且满足特召条件）。
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	local res=0
	local op=0
	if b1 and b2 then
		-- 两个场地均可时，弹出选择菜单，让玩家选择在自己场上还是对方场上特殊召唤。
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"在自己场上特殊召唤/在对方场上特殊召唤"
	elseif b1 then
		-- 只能在自己场上特殊召唤时，选择对应选项，op保持0。
		op=Duel.SelectOption(tp,aux.Stringid(id,2))  --"在自己场上特殊召唤"
	elseif b2 then
		-- 只能在对方场上特殊召唤时，因单一选项返回0，加1后op为1代表对方场地。
		op=Duel.SelectOption(tp,aux.Stringid(id,3))+1  --"在对方场上特殊召唤"
	else
		return
	end
	if op==0 then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 将对象怪兽以表侧表示特殊召唤到对方场上。
		res=Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
	end
	if res~=0 and rp==1-tp and tp==e:GetLabel()
		-- 检查手牌·墓地·除外区中是否存在至少1只符合追加过滤条件的恶魔族怪兽（并过滤王家长眠之谷的影响）。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		-- 向玩家确认是否再选择1只怪兽进行追加特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否再选1只怪兽特殊召唤？"
		-- 中断当前效果处理，使追加特殊召唤具有独立的处理时点。
		Duel.BreakEffect()
		-- 显示追加选择提示，让玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌·墓地·除外区中不取对象地选择1只符合条件的恶魔族怪兽（受王家长眠之谷过滤）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		local tc1=g:GetFirst()
		if tc1 then
			-- 判断追加选择的怪兽能否特殊召唤到自己场上。
			local b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc1:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断追加选择的怪兽能否以表侧表示特殊召唤到对方场上。
			local b4=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc1:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
			local sop=0
			if b3 and b4 then
				-- 两个场地均可时，弹出菜单选择追加怪兽特殊召唤到谁的场上。
				sop=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"在自己场上特殊召唤/在对方场上特殊召唤"
			elseif b3 then
				-- 只能在自己场上特召追加怪兽时，选择自己场上的选项。
				sop=Duel.SelectOption(tp,aux.Stringid(id,2))  --"在自己场上特殊召唤"
			elseif b4 then
				-- 只能在对方场上特召追加怪兽时，因为单选返回0，加1使sop为1。
				sop=Duel.SelectOption(tp,aux.Stringid(id,3))+1  --"在对方场上特殊召唤"
			else return end
			if sop==0 then
				-- 将追加选择的怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP)
			else
				-- 将追加选择的怪兽以表侧表示特殊召唤到对方场上。
				Duel.SpecialSummon(tc1,0,tp,1-tp,false,false,POS_FACEUP)
			end
		end
	end
end
