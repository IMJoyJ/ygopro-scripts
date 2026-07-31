--雷盟－オーバーボルテージ
local s,id,o=GetID()
-- 初始化效果函数，注册两个效果：一是发动时选择场上表侧表示的卡破坏并禁止怪兽特殊召唤；二是墓地触发效果，当自身被效果破坏且破坏者为雷盟卡组时，可将自身加入手牌。
function s.initial_effect(c)
	-- 效果1：发动时选择场上表侧表示的卡破坏，属于魔法卡的永续效果，具有取对象特性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果2：墓地触发效果，当自身被效果破坏且破坏者为雷盟卡组时，可将自身加入手牌。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 效果1的目标选择函数，用于选择场上表侧表示的卡作为破坏对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc~=e:GetHandler() end
	-- 判断是否满足效果1的目标选择条件，即场上是否存在表侧表示的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家发送提示信息“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上表侧表示的卡作为破坏对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息，记录本次连锁将要破坏的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果1的发动处理函数，对选中的目标进行破坏，并禁止对方怪兽特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
	-- 创建并注册一个禁止对方怪兽特殊召唤的效果，仅限效果怪兽且不在手牌中。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将禁止特殊召唤的效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 禁止特殊召唤效果的过滤函数，限制效果怪兽不能特殊召唤。
function s.splimit(e,c)
	return c:IsType(TYPE_EFFECT) and not c:IsLocation(LOCATION_HAND)
end
-- 破坏原因过滤函数，用于判断是否为效果破坏。
function s.dcfilter(c)
	return c:IsReason(REASON_EFFECT)
end
-- 触发效果2的条件函数，判断是否为对方效果破坏且破坏者为雷盟卡组。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and rp==tp and eg:IsExists(s.dcfilter,1,c) and re:GetHandler():IsSetCard(0x1df)
end
-- 触发效果2的目标选择函数，判断自身是否能加入手牌。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息，记录本次连锁将要将自身加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 触发效果2的发动处理函数，将自身加入手牌并确认对方查看。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否与连锁相关且未受王家长眠之谷影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身送入手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认查看自身
		Duel.ConfirmCards(1-tp,c)
	end
end
