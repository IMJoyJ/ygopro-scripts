--Angelechy Destrier
-- 效果：
-- 调整+调整以外的怪兽1只以上
-- 可以以其他纵列1只怪兽为对象；那只怪兽除外。
-- 这张卡被当作永续魔法卡使用在魔法与陷阱区域放置的场合：可以从卡组把1张「具象天使」魔法卡加入手卡。
-- 「战马之具象天使」的以上效果1回合各能使用1次。
-- 这张卡当作永续魔法卡使用中的场合，每次对方把卡的效果发动，给与对方500伤害。
local s,id,o=GetID()
-- 初始化卡片效果：设置同调召唤手续与苏生限制，并注册除外效果e1（起动效果、取对象）、移动检测e2（卡片进入魔陷区时触发自定义时点）、连锁处理结束检测e3、检索效果e4（自定义时点触发的诱发效果、1回合1次）、连锁发动检测e5、给与对方伤害的永续检测e6
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：素材为调整1只+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 可以以其他纵列1只怪兽为对象；那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外效果"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- 这张卡被当作永续魔法卡使用在魔法与陷阱区域放置的场合（检测这张卡移动到魔陷区且变成永续魔法卡的场合，为检索效果预置自定义时点）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_MOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetOperation(s.flagop)
	c:RegisterEffect(e2)
	-- 这张卡被当作永续魔法卡使用在魔法与陷阱区域放置的场合（在连锁处理结束时触发自定义时点，确保检索效果在连锁中放置的场合也能发动）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.raiseop)
	c:RegisterEffect(e3)
	-- 这张卡被当作永续魔法卡使用在魔法与陷阱区域放置的场合：可以从卡组把1张「具象天使」魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	-- 这张卡当作永续魔法卡使用中的场合，每次对方把卡的效果发动（登记卡片效果发动的标记，用于确认对方发动过卡的效果）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
	-- 这张卡当作永续魔法卡使用中的场合，每次对方把卡的效果发动，给与对方500伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(s.damcon)
	e6:SetOperation(s.damop)
	c:RegisterEffect(e6)
end
-- 过滤函数：筛选可以被除外且不属于这张卡同一纵列的卡
function s.rmfilter(c,g)
	return c:IsAbleToRemove() and not g:IsContains(c)
end
-- 除外效果的对象选择处理：取这张卡所在的纵列，检查场上是否存在可以成为对象的其他纵列怪兽，让玩家选择1只并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=c:GetColumnGroup()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc,g) and chkc~=c end
	-- 发动条件检测：检查双方怪兽区域是否存在可以成为对象、可除外且不在同一纵列的其他怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,g) end
	-- 向玩家提示「请选择要除外的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择双方怪兽区域1只可以除外且不在同一纵列的其他怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,g)
	-- 设置连锁操作信息：确定要除外这1只对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 除外效果的处理：取得对象怪兽，若其仍与连锁相关且是怪兽，则以表侧表示将其除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 以效果为由将对象怪兽表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 移动检测处理：这张卡移动到魔陷区且作为永续魔法卡放置时，若在连锁处理中则先登记标记延后触发，否则立即触发自定义时点以发动检索效果
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) or c:GetType()~=TYPE_SPELL+TYPE_CONTINUOUS then return end
	-- 判断当前是否处于连锁处理中（连锁序号大于0）
	if Duel.GetCurrentChain()>0 then
		c:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	else
		-- 以这张卡触发自定义时点（这张卡作为永续魔法卡在魔陷区放置的场合），供检索效果e4发动
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
-- 连锁处理结束时的检测处理：若这张卡是永续魔法卡且在连锁中登记过标记，则此时触发自定义时点
function s.raiseop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetType()~=TYPE_SPELL+TYPE_CONTINUOUS then return end
	if c:GetFlagEffect(id+o)~=0 then
		-- 以这张卡触发自定义时点，使检索效果能在连锁处理结束后发动
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
-- 检索效果发动条件：这张卡当前是作为永续魔法卡使用
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 检索过滤函数：筛选卡名带「具象天使」字段、可以加入手卡的魔法卡
function s.thfilter(c)
	return c:IsSetCard(0x1e2) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 检索效果的目标设置：检查卡组中是否存在可加入手卡的「具象天使」魔法卡，并设置检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：检查卡组中是否存在至少1张可加入手卡的「具象天使」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：预计从卡组把1张卡加入持有者手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：提示选择后让玩家从卡组选1张「具象天使」魔法卡，将其加入手卡并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「具象天使」魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果为由把选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 连锁发动检测处理：对方每次发动卡的效果时，给这张卡登记1回合有效的标记，用于判定给与伤害
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 伤害处理条件：这张卡作为永续魔法卡使用，且本次连锁是对方发动卡的效果（标记已登记）
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS and ep~=tp and c:GetFlagEffect(id)~=0
end
-- 伤害处理：显示卡片动画提示，给与对方500点效果伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 向对方显示这张卡发动的动画提示（不入连锁的伤害处理提示）
	Duel.Hint(HINT_CARD,0,id)
	-- 以效果为由给与对方玩家500点伤害
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
