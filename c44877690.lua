--氷結界の神精霊
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤·反转的回合的结束阶段发动。这张卡回到手卡。自己场上有其他的「冰结界」怪兽存在的场合，作为代替把以下效果发动。
-- ●这张卡召唤·反转的回合的结束阶段，以对方场上1只怪兽为对象发动。那只对方怪兽回到手卡。
function c44877690.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·反转的回合的结束阶段发动。这张卡回到手卡。自己场上有其他的「冰结界」怪兽存在的场合，作为代替把以下效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c44877690.retreg)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
end
-- 在召唤成功时，为此卡在结束阶段注册三种效果：无其他冰结界怪兽时强制回手、可选的灵魂回手（用于允许选择不返回的情况）、有其他冰结界怪兽时将对方怪兽回手的替代效果。
function c44877690.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(1104)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetReset(RESET_EVENT+0x1ee0000+RESET_PHASE+PHASE_END)
	e1:SetCondition(c44877690.retcon)
	-- 设置强制回手效果的目标判定函数：使用灵魂怪兽强制返回的通用判定，始终返回true（无需指定对象），用于结束阶段将此卡无选择地返回手牌。
	e1:SetTarget(aux.SpiritReturnTargetForced)
	-- 设置强制回手效果的实际处理函数：结束阶段若此卡仍在场上且与该效果关联，则将其返回持有者手牌。
	e1:SetOperation(aux.SpiritReturnOperation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- 设置可选回手效果的目标判定函数：使用灵魂怪兽可选返回的通用判定，当此卡可以选择不返回时也声明回手操作信息。
	e2:SetTarget(aux.SpiritReturnTargetOptional)
	c:RegisterEffect(e2)
	-- ●这张卡召唤·反转的回合的结束阶段，以对方场上1只怪兽为对象发动。那只对方怪兽回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetDescription(1104)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetReset(RESET_EVENT+0x1ee0000+RESET_PHASE+PHASE_END)
	e3:SetCondition(c44877690.retcon2)
	e3:SetTarget(c44877690.rettg2)
	e3:SetOperation(c44877690.retop2)
	c:RegisterEffect(e3)
end
-- 过滤函数：判定卡为表侧表示且具有「冰结界」字段（0x2f），用于检查自己场上是否存在其他冰结界怪兽。
function c44877690.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 普通回手效果（强制/可选）的发动条件：若自己场上有其他冰结界怪兽则不能发动，否则根据效果类型分别调用灵魂怪兽强制回手或可选回手的条件判定。
function c44877690.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测自己场上是否存在除自身以外表侧表示的「冰结界」怪兽，存在则使普通回手效果不发动。
	if Duel.IsExistingMatchingCard(c44877690.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then return false end
	if e:IsHasType(EFFECT_TYPE_TRIGGER_F) then
		-- 若当前效果为必发类型（TRIGGER_F），则使用灵魂怪兽强制返回条件判定：此卡没有不返回/可不返回效果时必须返回手牌。
		return aux.SpiritReturnConditionForced(e,tp,eg,ep,ev,re,r,rp)
	else
		-- 若当前效果为选发类型（TRIGGER_O），则使用灵魂怪兽可选返回条件判定：此卡拥有可不返回效果时允许选择返回手牌。
		return aux.SpiritReturnConditionOptional(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 替代效果（回对方怪兽）的发动条件：自己场上有其他表侧表示「冰结界」怪兽时才可以发动。
function c44877690.retcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否存在除自身以外表侧表示的「冰结界」怪兽，作为替代效果的发动条件。
	return Duel.IsExistingMatchingCard(c44877690.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 替代效果的发动时处理：选择对方场上1只可以加入手卡的怪兽作为对象（取对象），并设置将对象卡返回手牌的操作信息。
function c44877690.rettg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 向操作玩家显示提示文字「请选择要返回手牌的卡」，用于目标选择时的消息提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1只满足可加入手卡条件的怪兽，并将其登记为当前连锁的对象，用于后续效果处理。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为回手牌（CATEGORY_TOHAND），对象为已选择的卡组g，数量为g的数量，供连锁检测与效果处理使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 替代效果的实际处理：取得之前选择的对象怪兽，若其仍在对方场上且与当前效果关联，则将其返回持有者手牌。
function c44877690.retop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个（唯一）对象卡，即对方场上被选择的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsControler(1-tp) and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽送回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
