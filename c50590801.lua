--エルフェンノーツ～託選のアリスティア～
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次，①②的效果在同一连锁上不能发动。
-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
-- ②：自己场上有「耀圣」怪兽3只以上存在，对方把魔法·陷阱卡发动时才能发动。那个效果无效。自己场上有同调怪兽存在的场合，可以再把那张无效的卡破坏。
local s,id,o=GetID()
-- 初始化效果：e1为卡作为魔陷发动所需的基础效果（EFFECT_TYPE_ACTIVATE）；e2为①效果的诱发即时效果（取对象移动怪兽位置）；e3为②效果的诱发即时效果（无效并可能破坏魔陷）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"移动位置"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
	-- ②：自己场上有「耀圣」怪兽3只以上存在，对方把魔法·陷阱卡发动时才能发动。那个效果无效。自己场上有同调怪兽存在的场合，可以再把那张无效的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- s.mvtg为①效果的发动条件和对象选择函数，该段用于非连锁处理时的合法性检查：存在可选择的表侧怪兽、有空格、且该连锁上未发动过②。
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己的主要怪兽区域是否有可用的空格，以便目标怪兽可以移动到其他主要怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
		-- 检查自己是否带有id+o标记（即②效果是否已在本连锁发动过），该标记数量为0时①才可发动，实现“①②的效果在同一连锁上不能发动”。
		and Duel.GetFlagEffect(tp,id+o)==0 end
	-- 为发动玩家tp注册id标记，并在连锁结束时重置，用于阻止②在同一连锁上发动。
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 弹出选择提示，告知玩家需要选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示怪兽作为效果对象，并将其设定为当前连锁的取对象目标。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- s.mvop为①效果的处理函数，开头检查目标是否仍与连锁关联、是否还在自己的主要怪兽区，且存在可移动空格，不满足则效果不处理。
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这次效果取对象的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or not tc:IsLocation(LOCATION_MZONE) or tc:IsControler(1-tp)
		-- 若自己场上没有可供移动的主要怪兽区空格，则终止处理，不移动怪兽。
		or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 弹出提示，让玩家选择要移动到的位置。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家从自己的主要怪兽区域选择1个空位，返回该位置的位标记（seq）。
	local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(seq,2)
	-- 将目标怪兽移动到选定的主要怪兽区域（nseq由位标记换算为区域序号）。
	Duel.MoveSequence(tc,nseq)
end
-- 定义过滤器s.cfilter：卡片为表侧表示且具有「耀圣」字段（0x1d8）。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d8)
end
-- s.discon为②效果的发动条件判断函数，返回真时②效果才满足发动条件。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- ②效果发动条件其一：对方发动魔法·陷阱卡，且该连锁的发动可以被无效。
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- ②效果发动条件其二：自己场上存在3只以上表侧表示的「耀圣」怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- s.distg为②效果的发动合法性检查与操作信息设置函数，在chk==0时判定是否满足发动条件（同一连锁未发动过①），并注册标记、设置无效效果的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己身上的id标记数量为0，即同一连锁上没有发动过①，满足“①②的效果在同一连锁上不能发动”的限制。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 发动②时给自己注册id+o标记，连锁结束后重置，用于阻止①在同一连锁上发动。
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
	-- 设置本次连锁的操作信息为“无效效果”，目标是对方发动的魔法·陷阱卡（eg），表示后续处理将使其效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义过滤器s.cdfilter：卡片为表侧表示且为同调怪兽，用于检查自己场上是否存在同调怪兽。
function s.cdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- s.disop为②效果的处理函数：先无效对方效果，若满足条件（对方卡仍关联、可破坏、自己场上有同调怪兽）则再询问并破坏那张无效的卡。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 执行无效对方连锁效果，并确认对方发动的那张卡仍与连锁关联且可以被破坏。
	if Duel.NegateEffect(ev) and rc:IsRelateToChain(ev) and rc:IsDestructable()
		-- 确认自己场上有表侧表示的同调怪兽，满足追加破坏的条件。
		and Duel.IsExistingMatchingCard(s.cdfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否选择把那张被无效的卡破坏。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否破坏？"
		-- 中断当前效果处理（BreakEffect），使后续的破坏处理与之前的无效处理不视为同时进行，避免错过时点。
		Duel.BreakEffect()
		-- 以效果原因破坏那张被无效的对方魔法·陷阱卡。
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
