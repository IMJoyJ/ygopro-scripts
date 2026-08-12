--雷盟－オーバーボルテージ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以场上1张表侧表示卡为对象才能发动。那张卡破坏。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
-- ②：这张卡在墓地存在的状态，自己的「雷盟」卡的效果把卡破坏的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册该卡的两个效果：e1为取对象的破坏型魔陷发动效果（自由时点，效果分类破坏，提示文字「发动」，对象与处理分别由s.target和s.activate负责）；e2为墓地的诱发选发效果（破坏事件触发，场合型延迟标记，效果分类回手牌，同名效果1回合1次，条件、对象与处理分别由s.thcon、s.thtg、s.thop负责）
function s.initial_effect(c)
	-- ①：以场上1张表侧表示卡为对象才能发动。那张卡破坏。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的状态，自己的「雷盟」卡的效果把卡破坏的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
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
-- ①效果的对象选择处理：检查能否选取场上这张卡以外的1张表侧表示卡为对象；可以发动时提示「请选择要破坏的卡」，选择场上这张卡以外的1张表侧表示卡为对象，并登记破坏分类的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc~=e:GetHandler() end
	-- 发动条件检查：场上存在这张卡以外的、可以作为对象的表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向发动玩家提示「请选择要破坏的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上这张卡以外的1张表侧表示卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 登记破坏分类的操作信息，确定要破坏的卡为所选对象，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的处理：取回当前连锁的对象卡，若其仍与连锁相关则以效果原因破坏；之后注册一个仅对自身玩家生效、直到回合结束阶段为止的限制效果，禁止从手卡以外把效果怪兽特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 若对象卡仍与连锁相关，则以效果原因将其破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
	-- 这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。②：这张卡在墓地存在的状态，自己的「雷盟」卡的效果把卡破坏的场合才能发动。这张卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把该特殊召唤限制效果作为发动玩家的玩家效果注册到全局环境，直到回合结束
	Duel.RegisterEffect(e1,tp)
end
-- 限制判定：被限制的卡是效果怪兽且不在手卡，即自己不是从手卡中不能把效果怪兽特殊召唤
function s.splimit(e,c)
	return c:IsType(TYPE_EFFECT) and not c:IsLocation(LOCATION_HAND)
end
-- 被破坏的卡的过滤条件：该卡是因效果而被破坏的
function s.dcfilter(c)
	return c:IsReason(REASON_EFFECT)
end
-- ②效果的发动条件：效果原因的发动者是自己（rp==tp），被破坏的卡中存在因效果破坏的卡，且该效果的来源卡是「雷盟」卡（系列编号0x1df）
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and rp==tp and eg:IsExists(s.dcfilter,1,c) and re:GetHandler():IsSetCard(0x1df)
end
-- ②效果的目标处理：发动条件为这张卡可以加入手卡；可发动时登记回手牌分类的操作信息，确定处理对象为这张卡本身
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 登记回手牌分类的操作信息，确定要加入手卡的卡是这张卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的处理：若这张卡仍与连锁相关且不受「王家长眠之谷」影响，则以效果原因把它加入持有者手卡，并让对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与连锁相关，并且不受「王家长眠之谷」的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 以效果原因把这张卡加入持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 让对方玩家确认这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end
