--シャルルの叙事詩
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1张「圣剑」装备魔法卡给对方观看，从手卡·卡组把1只「焰圣骑士」怪兽特殊召唤。那之后，给人观看的卡给那只怪兽装备或送去墓地。
-- ②：把墓地的这张卡除外，以自己场上1只「焰圣骑士帝-查理」为对象才能发动。从手卡·卡组选1只「圣骑士」怪兽当作攻击力上升500的装备魔法卡使用给作为对象的怪兽装备。
local s,id,o=GetID()
-- 注册这张卡的①②效果：①为魔法卡发动效果，②为墓地中除外自身发动的取对象装备效果；同时登记其记述的卡名「焰圣骑士帝-查理」。
function s.initial_effect(c)
	-- 将「焰圣骑士帝-查理」（77656797）登记为这张卡记述的卡名，用于相关效果的联动判定。
	aux.AddCodeList(c,77656797)
	-- ①：把手卡1张「圣剑」装备魔法卡给对方观看，从手卡·卡组把1只「焰圣骑士」怪兽特殊召唤。那之后，给人观看的卡给那只怪兽装备或送去墓地。（这个卡名的①的效果1回合只能使用1次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「焰圣骑士帝-查理」为对象才能发动。从手卡·卡组选1只「圣骑士」怪兽当作攻击力上升500的装备魔法卡使用给作为对象的怪兽装备。（这个卡名的②的效果1回合只能使用1次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 设置②效果的发动cost：除外墓地中的这张卡。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中非公开状态的「圣剑」装备魔法卡（满足字段0x207a且类型为魔法+装备）。
function s.cfilter0(c)
	return c:IsSetCard(0x207a) and c:GetType()&(TYPE_SPELL+TYPE_EQUIP)==TYPE_SPELL+TYPE_EQUIP and not c:IsPublic()
end
-- ①发动时的双重过滤：选择的展示卡必须是「圣剑」装备魔法卡，且手卡·卡组中存在可特殊召唤的「焰圣骑士」怪兽。
function s.cfilter(c,e,tp,ft)
	-- 判断是否存在展示用「圣剑」卡，并且存在可特殊召唤的「焰圣骑士」怪兽。
	return s.cfilter0(c) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,c,ft)
end
-- 特殊召唤候选过滤：候选怪兽必须是「焰圣骑士」且满足特殊召唤条件；若展示的圣剑不能送墓，则还需满足该圣剑能装备给候选怪兽、魔陷区有空位且不违反装备限制。
function s.spfilter(c,e,tp,ec,ft)
	if not c:IsSetCard(0x507a) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if ec:IsAbleToGrave() then
		return true
	else
		return ft>0 and ec:CheckEquipTarget(c) and ec:CheckUniqueOnField(tp) and not ec:IsForbidden()
	end
end
-- ①效果的发动条件：自己场上有主要怪兽区空格，手卡有可展示的「圣剑」装备魔法卡，且手卡·卡组有可特殊召唤的「焰圣骑士」怪兽；满足后设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取自己魔陷区的可用空格数，用于判断展示的圣剑能否装备给将要特殊召唤的怪兽。
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsLocation(LOCATION_SZONE) then
			ft=ft-1
		end
		-- 必须有可用的主要怪兽区空格才能特殊召唤，否则不能发动①效果。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 同时需要存在符合条件的「圣剑」展示卡以及对应的可特殊召唤「焰圣骑士」怪兽（通过s.cfilter综合判定）。
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp,ft)
	end
	-- 设置本效果处理时包含特殊召唤的操作信息：从手卡·卡组特殊召唤1只怪兽（由于送墓是处理时选择，故不在此处设置送墓分类）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果处理：让玩家选择手卡1张「圣剑」展示给对方确认，然后从手卡·卡组选择1只「焰圣骑士」怪兽特殊召唤；特殊召唤成功后，让玩家选择将展示的圣剑装备给那只怪兽或送去墓地（若无法装备则只能送墓）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前魔陷区可用空格数，在特召前后用于判断装备可行性。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 弹出“请选择给对方确认的卡”的提示，要求选择要展示的手卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中1张符合条件的「圣剑」装备魔法卡作为展示卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ft)
	if #g>0 then
		local tc=g:GetFirst()
		-- 将选择的「圣剑」卡给对手确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示后洗切自己的手卡。
		Duel.ShuffleHand(tp)
		-- 若此时主要怪兽区没有空格，则无法特殊召唤，效果处理中止。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 弹出“请选择要特殊召唤的卡”的提示，要求选择要特召的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组选择1只满足条件的「焰圣骑士」怪兽。
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,tc,ft)
		-- 将选择的怪兽表侧攻击表示特殊召唤，并判断是否特殊召唤成功。
		if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 特殊召唤后重新计算魔陷区可用空格，用于之后装备选择的合法判断。
			ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
			local sc=sg:GetFirst()
			local b1=sc:IsFaceup() and sc:IsLocation(LOCATION_MZONE) and ft>0
				and tc:CheckEquipTarget(sc) and tc:CheckUniqueOnField(tp) and not tc:IsForbidden()
			local b2=tc:IsAbleToGrave()
			local off=1
			local ops={}
			local opval={}
			if b1 then
				ops[off]=aux.Stringid(id,2)  --"给那只怪兽装备"
				opval[off]=0
				off=off+1
			end
			if b2 then
				ops[off]=aux.Stringid(id,3)  --"送去墓地"
				opval[off]=1
				off=off+1
			end
			-- 根据条件生成“给那只怪兽装备”和“送去墓地”两个选项，并让玩家从中选择。
			local op=Duel.SelectOption(tp,table.unpack(ops))+1
			local sel=opval[op]
			if sel==0 then
				-- 中断当前效果处理，使后续的装备处理被视为单独时点，避免错过时点。
				Duel.BreakEffect()
				-- 将展示的「圣剑」装备魔法卡装备给特殊召唤的那只怪兽。
				Duel.Equip(tp,tc,sc)
			elseif sel==1 then
				-- 中断当前效果处理，使后续的送墓处理被视为单独时点，避免错过时点。
				Duel.BreakEffect()
				-- 将展示的「圣剑」装备魔法卡送去墓地。
				Duel.SendtoGrave(tc,REASON_EFFECT)
			end
		end
	else
		-- 若未按完整条件选出展示卡，则退化为仍选择1张「圣剑」给对方确认后结束处理（防御性分支）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 选择手卡中1张「圣剑」装备魔法卡（仅判断卡本身条件）。
		g=Duel.SelectMatchingCard(tp,s.cfilter0,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			-- 将选择的「圣剑」卡给对方确认。
			Duel.ConfirmCards(1-tp,g)
			-- 展示后洗切自己的手卡。
			Duel.ShuffleHand(tp)
		end
	end
end
-- ②的取对象过滤：表侧表示且卡名是「焰圣骑士帝-查理」（77656797）。
function s.charlesfilter(c)
	return c:IsFaceup() and c:IsCode(77656797)
end
-- 装备候选过滤：手卡·卡组中的「圣骑士」怪兽，可作为装备卡使用（满足字段0x107a、是怪兽、场上无同名且不被禁止装备）。
function s.eqfilter(c,tp)
	return c:IsSetCard(0x107a) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- ②效果的发动条件：自己魔陷区有空位，自己场上有表侧表示「焰圣骑士帝-查理」可对象，且手卡·卡组存在可作为装备的「圣骑士」怪兽；满足后选择对象。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.charlesfilter(chkc) end
	-- 必须存在可用的魔陷区空格，才能放置装备魔法卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 自己场上必须存在可成为对象的表侧表示「焰圣骑士帝-查理」。
		and Duel.IsExistingTarget(s.charlesfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 手卡·卡组必须存在可作为装备卡的「圣骑士」怪兽。
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 弹出“请选择表侧表示的卡”的提示，要求选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「焰圣骑士帝-查理」作为效果对象。
	Duel.SelectTarget(tp,s.charlesfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：从手卡·卡组选择1只「圣骑士」怪兽作为装备魔法卡，装备给对象「焰圣骑士帝-查理」，并使其攻击力上升500。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若魔陷区没有空格，则无法装备，效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 取出作为对象的「焰圣骑士帝-查理」。
	local tc1=Duel.GetFirstTarget()
	if not tc1:IsRelateToEffect(e) or tc1:IsFacedown() then return end
	-- 弹出“请选择要装备的卡”的提示，要求选择要装备的「圣骑士」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从手卡·卡组选择1只符合条件的「圣骑士」怪兽作为装备卡。
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		local tc2=g:GetFirst()
		-- 将选择的「圣骑士」怪兽作为装备卡装备给对象，若装备成功则继续附加以下效果。
		if Duel.Equip(tp,tc2,tc1,true) then
			local c=e:GetHandler()
			-- 给作为对象的怪兽装备（限制该装备卡只能装备给被选中的对象怪兽）。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			e1:SetLabelObject(tc1)
			tc2:RegisterEffect(e1)
			-- 当作攻击力上升500的装备魔法卡使用（赋予装备怪兽攻击力上升500）。
			local e2=Effect.CreateEffect(tc2)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(500)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e2)
		end
	end
end
-- 装备限制判定：只有当初作为对象的「焰圣骑士帝-查理」才能装备这张「圣骑士」卡。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
