--TG ストライカー
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。从卡组把「科技属 突击兵」以外的1只「科技属」怪兽加入手卡。
function c1315120.initial_effect(c)
	-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1315120.spcon)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c1315120.regop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件判断：当该卡从手卡进行规则特殊召唤时，若满足自己场上无怪兽、对方场上有怪兽且自己主要怪兽区有空位，则允许特殊召唤。
function c1315120.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者自己场上主要怪兽区的怪兽数量是否为0（即自己场上没有怪兽）。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查这张卡的控制者对方场上主要怪兽区的怪兽数量是否大于0（即对方场上有怪兽）。
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查这张卡的控制者自己场上主要怪兽区是否存在可用的空格（用于特殊召唤）。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 当这张卡从场上被破坏送去墓地时，在结束阶段为这张卡注册一个诱发选发的检索效果。
function c1315120.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
		-- 从卡组把「科技属 突击兵」以外的1只「科技属」怪兽加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(1315120,0))  --"检索"
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c1315120.thtg)
		e1:SetOperation(c1315120.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 检索的过滤条件：卡是「科技属」怪兽、不是「科技属 突击兵」自身、是怪兽卡且可以加入手卡。
function c1315120.filter(c)
	return c:IsSetCard(0x27) and not c:IsCode(1315120) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动条件和操作信息设置：确认卡组存在符合条件的怪兽，并声明将卡组中的1张卡加入手卡。
function c1315120.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在至少1张满足检索条件的「科技属」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c1315120.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明本效果处理时从卡组将1张卡加入手卡，供其他效果/卡检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理：从卡组选择1张符合条件的「科技属」怪兽加入手卡，并让对方确认。
function c1315120.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足筛选条件的「科技属」怪兽（不包含「科技属 突击兵」自身）。
	local g=Duel.SelectMatchingCard(tp,c1315120.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择到的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
