--ヴァレット・ローダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只龙族·暗属性·7星怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的属性直到回合结束时变成暗属性。
local s,id,o=GetID()
-- 为怪兽注册全部效果：①召唤/特殊召唤成功时检索卡组中龙族·暗属性·7星怪兽加入手卡，并附加发动后不能从额外卡组特殊召唤非暗属性怪兽的自肃；②墓地起动效果，除外自身，以场上表侧表示怪兽为对象将其属性变成暗属性。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只龙族·暗属性·7星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的属性直到回合结束时变成暗属性。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"改变属性"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价为把墓地的这张卡除外（作为发动COST）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.atttg)
	e3:SetOperation(s.attop)
	c:RegisterEffect(e3)
end
-- 检索效果的过滤条件：卡组中1只等级7、龙族、暗属性且可以加入手卡的怪兽。
function s.thfilter(c)
	return c:IsLevel(7) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 检索效果的发动条件与处理信息登记：满足条件时确认卡组存在符合条件的怪兽，并登记将1张卡加入手卡的操作信息（用于连锁检测）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认卡组中存在至少1只符合条件的龙族·暗属性·7星怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次处理将把卡组中1只怪兽加入手卡的操作信息（不取对象，数量1，位置为卡组），供相关卡进行效果发动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组挑选1只符合条件的怪兽加入手卡，并向对方确认；然后给自己附加“直到回合结束时不能从额外卡组特殊召唤非暗属性怪兽”的自肃效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示当前玩家选择要加入手卡的卡片（弹出选择提示文字）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从卡组的符合条件的怪兽中选择1张加入手卡（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将所选怪兽送去（加入）持有者的手卡，并记为效果处理导致。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示己方检索加入手卡的那张怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
	-- ①的后续自肃：‘这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。’②：‘把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的属性直到回合结束时变成暗属性。’
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述自肃效果以玩家tp为对象注册到场上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的判定条件：不能特殊召唤的怪兽是位于额外卡组且属性不是暗属性的怪兽。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果可选择对象的过滤条件：场上表侧表示且属性不是暗属性的怪兽（因为若已是暗属性则改变属性无意义）。
function s.attfilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_DARK)
end
-- ②效果的发动条件与取对象处理：检查场上存在符合条件的表侧表示怪兽；存在则让玩家选择1只作为对象，并登记取对象信息。
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.attfilter(chkc) end
	-- 效果发动合法性检查时，确认场上存在至少1只表侧表示且非暗属性的怪兽可以作为对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示当前玩家选择效果对象（显示“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让当前玩家从双方场上选择1只表侧表示且非暗属性的怪兽作为效果对象，并自动将其与当前连锁建立联系。
	Duel.SelectTarget(tp,s.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理：取得对象怪兽，若其仍与效果有关联且表侧表示、为怪兽且不是暗属性，则给它赋予“属性变为暗属性”的永续效果直到回合结束。
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and not tc:IsAttribute(ATTRIBUTE_DARK) then
		-- 那只怪兽的属性直到回合结束时变成暗属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ATTRIBUTE_DARK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
