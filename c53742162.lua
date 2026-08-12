--氷水浸蝕
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1张表侧表示的卡为对象才能发动。自己场上1只「冰水」怪兽破坏，作为对象的卡的效果直到回合结束时无效。
-- ②：自己场上的表侧表示的水属性怪兽以破坏以外的方法因对方从场上离开的场合才能发动。从卡组选1只「冰水」怪兽加入手卡或特殊召唤。
function c53742162.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以对方场上1张表侧表示的卡为对象才能发动。自己场上1只「冰水」怪兽破坏，作为对象的卡的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53742162,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,53742162)
	e2:SetTarget(c53742162.distg)
	e2:SetOperation(c53742162.disop)
	c:RegisterEffect(e2)
	-- ②：自己场上的表侧表示的水属性怪兽以破坏以外的方法因对方从场上离开的场合才能发动。从卡组选1只「冰水」怪兽加入手卡或特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53742162,1))  --"加入手卡或特殊召唤"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,53742163)
	e3:SetCondition(c53742162.thcon)
	e3:SetTarget(c53742162.thtg)
	e3:SetOperation(c53742162.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片是否为表侧表示的「冰水」卡（即可作为①效果破坏代价的自己场上怪兽）。
function c53742162.disfilter(c)
	return c:IsSetCard(0x16c) and c:IsFaceup()
end
-- ①效果的取对象目标函数：确认对象卡须为对方场上的表侧表示卡；发动条件检测时，要求对方场上存在1张可被无效的表侧表示卡，且自己怪兽区存在1只表侧表示的「冰水」怪兽。
function c53742162.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 发动条件检测：对方场上存在至少1张可以被无效的表侧表示卡作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 发动条件检测：自己怪兽区存在至少1只表侧表示的「冰水」怪兽可作为破坏代价。
		and Duel.IsExistingMatchingCard(c53742162.disfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送选择提示：请选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择对方场上1张可被无效的表侧表示卡，并将其设为本连锁的对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 取得自己怪兽区所有表侧表示的「冰水」怪兽组成的卡组。
	local dg=Duel.GetMatchingGroup(c53742162.disfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息：本连锁将破坏自己场上1只「冰水」怪兽（用于破坏分类的发动检测）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	-- 设置操作信息：本连锁将使作为对象的1张卡的效果无效（用于无效分类的发动检测）。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果的处理：让玩家选自己场上1只表侧表示的「冰水」怪兽破坏，破坏成功后，若对象卡仍表侧表示、与本效果关联且可被无效，则将与该卡有关的连锁无效，并赋予其直到回合结束时无效（含陷阱怪兽无效化）的效果。
function c53742162.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己怪兽区1只表侧表示的「冰水」怪兽。
	local g=Duel.SelectMatchingCard(tp,c53742162.disfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 若成功选出并以效果破坏了1只「冰水」怪兽，则继续执行后续的无效处理。
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 取得本连锁的对象卡（即要被无效的对方场上的卡）。
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
			-- 将与对象卡有关的连锁无效化（对象卡被里侧表示重置时解除）。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 作为对象的卡的效果直到回合结束时无效（赋予单体无效效果）。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 作为对象的卡的效果直到回合结束时无效（使其发动的效果无效化）。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 作为对象的卡的效果直到回合结束时无效（若对象卡为陷阱怪兽则同样无效）。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- 过滤函数：判断离场卡是否为自己场上以表侧表示存在于怪兽区、因对方原因以破坏以外的方法离开的水属性怪兽。
function c53742162.filter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and not c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp
end
-- ②效果的发动条件：本次离场的卡中存在至少1只满足条件的自己场上表侧表示的水属性怪兽（以破坏以外的方法因对方离开）。
function c53742162.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53742162.filter,1,nil,tp)
end
-- 过滤函数：判断卡片是否为卡组中可以加入手卡、或在有可用怪兽区空格时可以特殊召唤的「冰水」怪兽。
function c53742162.ffilter(c,e,tp,ft)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x16c) and (c:IsAbleToHand() or ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ②效果的目标函数：发动条件检测时，统计自己怪兽区可用空格数，并要求卡组中存在至少1只可加入手卡或可特殊召唤的「冰水」怪兽。
function c53742162.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得自己怪兽区当前可用的空格数。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 发动条件检测：卡组中存在至少1只满足条件的「冰水」怪兽。
		return Duel.IsExistingMatchingCard(c53742162.ffilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft)
	end
end
-- ②效果的处理：从卡组选1只满足条件的「冰水」怪兽，若其能加入手卡且（不能特殊召唤、没有可用空格或玩家选择加入手卡），则将其加入手卡并向对方展示；否则将其以表侧表示特殊召唤。
function c53742162.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得自己怪兽区当前可用的空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 向玩家发送选择提示：请选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组选择1只满足条件的「冰水」怪兽。
	local g=Duel.SelectMatchingCard(tp,c53742162.ffilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		-- 若选出的卡能加入手卡，且（该卡不能特殊召唤、怪兽区没有可用空格，或玩家选择了「加入手卡」选项），则执行加入手卡处理。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选出的卡以效果原因加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示（确认）加入手卡的那张卡。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选出的卡以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
