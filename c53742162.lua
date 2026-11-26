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
	-- 这个卡名的①②的效果1回合各能使用1次。①：以对方场上1张表侧表示的卡为对象才能发动。自己场上1只「冰水」怪兽破坏，作为对象的卡的效果直到回合结束时无效。
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
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
-- 过滤函数：筛选场上表侧表示的「冰水」(0x16c)怪兽
function c53742162.disfilter(c)
	return c:IsSetCard(0x16c) and c:IsFaceup()
end
-- 效果①的Target函数：检测对方场上存在可无效的表侧卡且己方存在「冰水」怪兽，取对方1张卡为对象并设置破坏与无效操作信息
function c53742162.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 发动检测时确认对方场上存在至少1张可成为对象并被无效的表侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 且确认己方怪兽区存在至少1只表侧表示的「冰水」怪兽
		and Duel.IsExistingMatchingCard(c53742162.disfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向己方玩家发送选择要无效的对方表侧卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从对方场上选择1张可被无效的表侧卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 获取己方怪兽区所有表侧表示的「冰水」怪兽
	local dg=Duel.GetMatchingGroup(c53742162.disfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置将己方场上1只「冰水」怪兽破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	-- 设置使所选对方表侧卡效果无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果①的Operation函数：先选择己方场上1只「冰水」怪兽破坏，成功后再使对方对象卡的效果直到回合结束时无效
function c53742162.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向己方玩家发送选择要破坏的己方「冰水」怪兽提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从己方怪兽区选择1只表侧表示的「冰水」怪兽
	local g=Duel.SelectMatchingCard(tp,c53742162.disfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 检查选中的己方「冰水」怪兽并将其以效果破坏，确认成功破坏后执行后续处理
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 获取发动时指定为对象的对方表侧表示卡片
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
			-- 使与对象卡相关的当前连锁效果无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 直到回合结束时无效（怪兽效果本身）
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 直到回合结束时无效（卡片发动与适用中的效果）
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 直到回合结束时无效（若对象为陷阱怪兽，同步无效其陷阱怪兽状态）
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- 过滤函数：检查离场卡片是否原本为己方怪兽区表侧表示的水属性怪兽，且因对方操作以破坏以外的方法离开场上
function c53742162.filter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and not c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp
end
-- 效果②的Condition函数：检查本次离场事件eg中是否存在符合条件的己方水属性怪兽
function c53742162.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53742162.filter,1,nil,tp)
end
-- 过滤函数：筛选卡组中属于「冰水」(0x16c)字段的怪兽，要求可加入手卡或在有空位ft>0时可特殊召唤
function c53742162.ffilter(c,e,tp,ft)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x16c) and (c:IsAbleToHand() or ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果②的Target函数：获取己方怪兽区空位数并检测卡组中存在可检索或特召的「冰水」怪兽
function c53742162.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取己方主要怪兽区当前的可用空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 发动检测时确认己方卡组中存在至少1只满足加入手卡或特召条件的「冰水」怪兽
		return Duel.IsExistingMatchingCard(c53742162.ffilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft)
	end
end
-- 效果②的Operation函数：从己方卡组选择1只「冰水」怪兽，根据可操作性及玩家选择加入手卡或表侧特殊召唤
function c53742162.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取己方主要怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 向己方玩家发送选择要操作的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从己方卡组中选择1只符合条件的「冰水」怪兽
	local g=Duel.SelectMatchingCard(tp,c53742162.ffilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		-- 若该卡可加入手卡，且无法特召、没有空位或玩家在加入手卡(1190)与特召(1152)间选择了加入手卡，则执行回手分支
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 以效果将选中的「冰水」怪兽加入持有者（己方）手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家公开确认加入手卡的「冰水」怪兽
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的「冰水」怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
