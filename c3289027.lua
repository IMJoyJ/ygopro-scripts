--暗黒界の隠者 パアル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被效果从手卡丢弃去墓地的场合，以「暗黑界的隐者 珀尔」以外的自己墓地1只「暗黑界」怪兽为对象才能发动。那只怪兽在自己或者对方场上特殊召唤。被对方的效果丢弃的场合，可以再从自己的手卡·墓地的怪兽以及除外的自己怪兽之中选1只恶魔族怪兽在自己或者对方场上特殊召唤。
local s,id,o=GetID()
-- 创建一个诱发效果，当此卡被送去墓地时发动，效果类型为单体诱发效果，具有延迟和取对象属性，限制每回合只能发动一次
function s.initial_effect(c)
	-- ①：这张卡被效果从手卡丢弃去墓地的场合，以「暗黑界的隐者 珀尔」以外的自己墓地1只「暗黑界」怪兽为对象才能发动。
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
-- 判断此卡是否从手卡被送去墓地，并且是被对方的效果丢弃
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 过滤满足条件的墓地怪兽：不是同名卡、属于暗黑界、是怪兽卡、并且有在自己或对方场上特殊召唤的条件
function s.spfilter(c,e,tp)
	return not c:IsCode(id)
		and c:IsSetCard(0x6) and c:IsType(TYPE_MONSTER)
		-- 判断自己场上是否有空位且该怪兽可以特殊召唤
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		-- 判断对方场上是否有空位且该怪兽可以特殊召唤
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
-- 设置效果目标，选择墓地中的1只符合条件的怪兽作为对象，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查是否有满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的1只符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	if rp==1-tp and tp==e:GetLabel() then
		-- 设置操作信息，表示可能再特殊召唤1只恶魔族怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
-- 过滤满足条件的恶魔族怪兽：是恶魔族、正面表示或在手牌/墓地、并且有在自己或对方场上特殊召唤的条件
function s.spfilter2(c,e,tp)
	return c:IsRace(RACE_FIEND)
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND+LOCATION_GRAVE))
		-- 判断自己场上是否有空位且该怪兽可以特殊召唤
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		-- 判断对方场上是否有空位且该怪兽可以特殊召唤
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
-- 处理效果的发动，先特殊召唤目标怪兽，再判断是否满足再特殊召唤条件并执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 判断自己场上是否有空位且目标怪兽可以特殊召唤
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 判断对方场上是否有空位且目标怪兽可以特殊召唤
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	local res=0
	local op=0
	if b1 and b2 then
		-- 提示玩家选择在自己场上或对方场上特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"在自己场上特殊召唤/在对方场上特殊召唤"
	elseif b1 then
		-- 提示玩家选择在自己场上特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(id,2))  --"在自己场上特殊召唤"
	elseif b2 then
		-- 提示玩家选择在对方场上特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(id,3))+1  --"在对方场上特殊召唤"
	else
		return
	end
	if op==0 then
		-- 将目标怪兽特殊召唤到自己场上
		res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 将目标怪兽特殊召唤到对方场上
		res=Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
	end
	if res~=0 and rp==1-tp and tp==e:GetLabel()
		-- 检查自己手牌/墓地/除外区是否有恶魔族怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		-- 询问玩家是否再特殊召唤1只恶魔族怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否再选1只怪兽特殊召唤？"
		-- 中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择手牌/墓地/除外区中的1只恶魔族怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		local tc1=g:GetFirst()
		if tc1 then
			-- 判断自己场上是否有空位且该怪兽可以特殊召唤
			local b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc1:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断对方场上是否有空位且该怪兽可以特殊召唤
			local b4=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc1:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
			local sop=0
			if b3 and b4 then
				-- 提示玩家选择在自己场上或对方场上特殊召唤
				sop=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"在自己场上特殊召唤/在对方场上特殊召唤"
			elseif b3 then
				-- 提示玩家选择在自己场上特殊召唤
				sop=Duel.SelectOption(tp,aux.Stringid(id,2))  --"在自己场上特殊召唤"
			elseif b4 then
				-- 提示玩家选择在对方场上特殊召唤
				sop=Duel.SelectOption(tp,aux.Stringid(id,3))+1  --"在对方场上特殊召唤"
			else return end
			if sop==0 then
				-- 将该怪兽特殊召唤到自己场上
				Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP)
			else
				-- 将该怪兽特殊召唤到对方场上
				Duel.SpecialSummon(tc1,0,tp,1-tp,false,false,POS_FACEUP)
			end
		end
	end
end
