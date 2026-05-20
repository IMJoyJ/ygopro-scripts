--聖痕喰らいし竜
-- 效果：
-- 「阿不思的落胤」＋光·暗属性怪兽＋效果怪兽
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。自己·对方的墓地·除外状态的卡合计最多2张回到卡组。
-- ②：只要自己或对方的场上或墓地有「艾克莉西娅」怪兽存在，这张卡攻击力上升500，不受这张卡以外的效果影响。
-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1张「教导」、「铁兽」卡加入手卡。
local s,id,o=GetID()
-- 初始化此卡的效果，注册融合素材、召唤限制以及各个效果
function s.initial_effect(c)
	-- 将「阿不思的落胤」（卡号68468459）加入此卡的融合素材卡名列表，以便其他卡片检索或关联
	aux.AddMaterialCodeList(c,68468459)
	c:EnableReviveLimit()
	-- 设置融合召唤的手续，素材为「阿不思的落胤」＋光·暗属性怪兽＋效果怪兽
	aux.AddFusionProcMix(c,true,true,68468459,s.matfilter1,s.matfilter2,nil)
	-- ①：这张卡特殊召唤的场合才能发动。自己·对方的墓地·除外状态的卡合计最多2张回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- ②：只要自己或对方的场上或墓地有「艾克莉西娅」怪兽存在，这张卡攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.efcon)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 不受这张卡以外的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.efcon)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的回合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	-- 结束阶段才能发动。从卡组把1张「教导」、「铁兽」卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"检索"
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id+o)
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
-- 融合素材过滤函数1：光属性或暗属性怪兽
function s.matfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 融合素材过滤函数2：效果怪兽
function s.matfilter2(c)
	return c:IsFusionType(TYPE_EFFECT)
end
-- 过滤函数：可以回到卡组的卡片
function s.tdfilter(c)
	return c:IsAbleToDeck()
end
-- 效果①的准备阶段（Target），检查双方墓地或除外状态是否有可回到卡组的卡，并设置操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备时，检查双方墓地或除外状态是否存在至少1张可以回到卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
	-- 设置连锁的操作信息，表明此效果会使双方墓地或除外状态的卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果①的处理阶段（Operation），让玩家选择最多2张墓地或除外的卡回到卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从双方墓地或除外状态中选择1到2张可以回到卡组且不受「王家长眠之谷」影响的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,2,nil)
	if g:GetCount()>0 then
		-- 在场上/界面上闪烁显示被选中的卡片
		Duel.HintSelection(g)
		-- 将选中的卡片送回持有者的卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤函数：表侧表示存在（或在墓地）的「艾克莉西娅」怪兽
function s.effilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1d7) and c:IsType(TYPE_MONSTER)
end
-- 效果②的适用条件：检查双方场上或墓地是否存在「艾克莉西娅」怪兽
function s.efcon(e)
	-- 检查双方场上或墓地是否存在至少1张满足条件的「艾克莉西娅」怪兽
	return Duel.IsExistingMatchingCard(s.effilter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
end
-- 免疫效果的过滤函数：使此卡不受此卡以外的其他卡片效果影响
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 此卡被送去墓地时的处理：给此卡注册一个在回合结束前有效的标记，用于记录被送去墓地这一事件
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果③的发动条件：检查此卡在本回合是否被送去过墓地（即是否存在对应的标记）
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 过滤函数：卡组中可以加入手卡的「教导」或「铁兽」卡片
function s.thfilter(c)
	return c:IsSetCard(0x145,0x14d) and c:IsAbleToHand()
end
-- 效果③的准备阶段（Target），检查卡组中是否存在可检索的卡，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备时，检查自己卡组是否存在至少1张可以加入手卡的「教导」或「铁兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表明此效果会从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的处理阶段（Operation），从卡组将1张「教导」或「铁兽」卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「教导」或「铁兽」卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡片加入玩家手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
