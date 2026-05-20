--異次元ポスト
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的怪兽的攻击力上升自己的除外状态的卡种类（怪兽·魔法·陷阱）×300。
-- ②：1回合1次，自己·对方的主要阶段才能发动。从自己的手卡·墓地把1张卡除外。那之后，可以让自己的除外状态的1张卡回到卡组。
-- ③：这张卡被除外的场合才能发动。这张卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、攻击力上升的永续效果、主要阶段除外并回卡组的即时诱发效果，以及被除外时在场上放置的诱发效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的怪兽的攻击力上升自己的除外状态的卡种类（怪兽·魔法·陷阱）×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己·对方的主要阶段才能发动。从自己的手卡·墓地把1张卡除外。那之后，可以让自己的除外状态的1张卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	-- ③：这张卡被除外的场合才能发动。这张卡在自己场上表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 获取卡片的类型（怪兽、魔法或陷阱），用于后续计算除外状态的卡种类。
function s.GetIntType(c)
	if c:IsType(TYPE_MONSTER) then
		return TYPE_MONSTER
	elseif c:IsType(TYPE_SPELL) then
		return TYPE_SPELL
	elseif c:IsType(TYPE_TRAP) then
		return TYPE_TRAP
	end
end
-- 计算攻击力上升值的辅助函数，获取自己除外状态的卡，并根据卡片种类数量乘以300。
function s.atkval(e,c)
	-- 获取自己除外状态的所有表侧表示的卡。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)
	return g:GetClassCount(s.GetIntType)*300
end
-- 效果②的发动条件函数，限制在双方的主要阶段才能发动。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 效果②的发动准备（Target）函数，检查手卡或墓地是否有可除外的卡，并设置除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或墓地是否存在至少1张可以除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息，表示此效果包含从手卡或墓地除外1张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的效果处理（Operation）函数，执行除外手卡/墓地的卡，并可选地将除外状态的卡送回卡组。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家发送选择要除外的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡或墓地选择1张可以除外的卡（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 如果成功选择并除外了该卡。
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0
		-- 检查自己的除外状态是否存在可以回到卡组的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,nil)
		-- 询问玩家是否选择发动“让自己的除外状态的1张卡回到卡组”的效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否让卡回到卡组？"
		-- 给玩家发送选择要返回卡组的卡的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从除外状态选择1张（除这张卡以外的）可以回到卡组的卡。
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,1,c)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续的回到卡组处理不与除外处理同时进行（造成错时点）。
			Duel.BreakEffect()
			-- 选中所选的卡片并向双方玩家展示。
			Duel.HintSelection(sg)
			-- 将选中的卡送回持有者卡组并洗牌。
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 效果③的发动准备（Target）函数，检查魔法与陷阱区域是否有空位，以及该卡是否可以放置在场上。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 检查自己的魔法与陷阱区域是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and not c:IsForbidden() and c:CheckUniqueOnField(tp) end
end
-- 效果③的效果处理（Operation）函数，将这张卡在自己的魔法与陷阱区域表侧表示放置。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡仍与效果相关联，则将其移动到自己的魔法与陷阱区域表侧表示放置。
	if c:IsRelateToEffect(e) then Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
