--アメイズメント・プレシャスパーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己可以把1张「游乐设施」陷阱卡在盖放的回合的自己主要阶段发动。
-- ②：自己·对方的结束阶段，把给怪兽装备的自己场上1张「游乐设施」陷阱卡送去墓地，从自己墓地的卡以及除外的自己的卡之中以和送去墓地的卡卡名不同的1张「游乐设施」陷阱卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
function c33773528.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己可以把1张「游乐设施」陷阱卡在盖放的回合的自己主要阶段发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33773528,1))  --"适用「惊乐珍宝园」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetCountLimit(1,33773528)
	e1:SetCondition(c33773528.actcon)
	-- 将①效果的作用对象限定为「游乐设施」字段的卡，使只有「游乐设施」陷阱卡能获得在盖放回合的主要阶段发动的许可。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x15c))
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，把给怪兽装备的自己场上1张「游乐设施」陷阱卡送去墓地，从自己墓地的卡以及除外的自己的卡之中以和送去墓地的卡卡名不同的1张「游乐设施」陷阱卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33773528,0))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,33773529)
	e2:SetCost(c33773528.cost)
	e2:SetTarget(c33773528.target)
	e2:SetOperation(c33773528.activate)
	c:RegisterEffect(e2)
end
-- ①效果的适用条件：仅当当前回合玩家为此卡控制者且处于自己主要阶段1或主要阶段2时，才允许盖放的「游乐设施」陷阱卡发动。
function c33773528.actcon(e)
	-- 获取当前游戏阶段并保存到局部变量ph，用于判断是否为主要阶段。
	local ph=Duel.GetCurrentPhase()
	-- 返回真当且仅当当前回合玩家是效果控制者，且当前阶段是主要阶段1或主要阶段2，即只有自己回合的主要阶段才满足①效果的发动时机。
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 定义用于选择要作为代价送去墓地的装备中「游乐设施」陷阱卡的过滤函数，需满足表侧表示、字段、类型、有装备对象、可作为代价、魔陷区有空位且存在可盖放的另一张同名不同的「游乐设施」陷阱卡。
function c33773528.filter(c,tp)
	-- 过滤条件：该卡必须是表侧表示、属「游乐设施」且为陷阱卡、正装备在怪兽上、可以作代价送入墓地，且自己魔陷区有空位可用。
	return c:IsFaceup() and c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:GetEquipTarget() and c:IsAbleToGraveAsCost() and Duel.GetSZoneCount(tp,c)>0
		-- 同时要求自己墓地或除外区中存在至少1张与候选卡卡名不同的「游乐设施」陷阱卡，且该卡能成为本次效果的对象。
		and Duel.IsExistingTarget(c33773528.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c:GetCode())
end
-- 定义盖放对象的过滤函数：对象必须是「游乐设施」陷阱卡，与送去墓地的卡卡名不同，能够以里侧表示盖放到魔陷区；墓地中的卡或表侧除外的卡均可。
function c33773528.setfilter(c,code)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and not c:IsCode(code) and c:IsSSetable(true)
end
-- 代价函数：本效果的送墓代价与对象选择是捆绑处理的，这里仅通过代价检查并将效果标签设为100，作为已经进入发动选择流程的标记。
function c33773528.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- ②效果的发动选择处理：确认代价检查标记后，选择1张装备中的「游乐设施」陷阱卡送入墓地，再以墓地/除外区中与其卡名不同的1张「游乐设施」陷阱卡为对象；若对象在墓地则追加设置涉及墓地的操作信息。
function c33773528.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c33773528.setfilter(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查己方魔陷区是否存在至少1张满足filter的「游乐设施」陷阱卡可作为送墓代价，用以判断②效果能否发动。
		return Duel.IsExistingMatchingCard(c33773528.filter,tp,LOCATION_SZONE,0,1,nil,tp)
	end
	e:SetLabel(0)
	-- 显示选择提示“请选择要送去墓地的卡”，引导玩家选择要作为代价送入墓地的装备中的「游乐设施」陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 由己方玩家从自己魔陷区中选出1张满足filter的「游乐设施」陷阱卡，作为发动代价准备送入墓地，结果存入g。
	local g=Duel.SelectMatchingCard(tp,c33773528.filter,tp,LOCATION_SZONE,0,1,1,nil,tp)
	-- 将选中的那张「游乐设施」陷阱卡作为代价从魔陷区送入墓地，实际支付发动代价。
	Duel.SendtoGrave(g,REASON_COST)
	local code=g:GetFirst():GetCode()
	e:SetLabel(code)
	-- 显示选择提示“请选择要盖放的卡”，引导玩家选择要从墓地或除外区盖放到魔陷区的「游乐设施」陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 由己方玩家从自己墓地或除外区选择1张与已送墓卡卡名不同且满足setfilter的「游乐设施」陷阱卡作为效果对象，并自动登记为当前连锁的对象。
	local sg=Duel.SelectTarget(tp,c33773528.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,code)
	if sg:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 当选择的对象位于墓地时，设置操作信息为CATEGORY_LEAVE_GRAVE，以使涉及墓地移动的效果能被正确检测（如王家长眠之谷的干扰）。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
	end
end
-- ②效果处理函数：当对象卡仍与效果相关联时，将其以里侧表示盖放到己方魔法与陷阱区域。
function c33773528.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的对象卡（先前通过SelectTarget选择的那张「游乐设施」陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以里侧表示盖放到己方魔法与陷阱区域，完成②效果的最终处理。
		Duel.SSet(tp,tc)
	end
end
