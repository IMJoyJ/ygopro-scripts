--迷い花の森
-- 效果：
-- ①：有「星空蝶」装备的自己怪兽不受对方发动的效果影响。
-- ②：1回合1次，自己的「勇者衍生物」战斗破坏怪兽时才能发动。自己从卡组抽1张。
-- ③：这张卡的②的效果发动的回合的自己主要阶段才能发动1次。从自己的卡组·墓地选「迷幻花之森」以外的1张有「勇者衍生物」的衍生物名记述的场地魔法卡加入手卡。
function c91228233.initial_effect(c)
	-- 注册卡片记述了「勇者衍生物」的卡片密码。
	aux.AddCodeList(c,3285552)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：有「星空蝶」装备的自己怪兽不受对方发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c91228233.immtg)
	e1:SetValue(c91228233.immval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己的「勇者衍生物」战斗破坏怪兽时才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c91228233.drcon)
	e2:SetTarget(c91228233.drtg)
	e2:SetOperation(c91228233.drop)
	c:RegisterEffect(e2)
	-- ③：这张卡的②的效果发动的回合的自己主要阶段才能发动1次。从自己的卡组·墓地选「迷幻花之森」以外的1张有「勇者衍生物」的衍生物名记述的场地魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c91228233.thcon)
	e3:SetTarget(c91228233.thtg)
	e3:SetOperation(c91228233.thop)
	c:RegisterEffect(e3)
end
-- 过滤不受影响的怪兽：装备了「星空蝶」的自己场上的怪兽。
function c91228233.immtg(e,c)
	return c:GetEquipCount()>0 and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,92341815)
end
-- 免疫效果的判定：对方发动的效果。
function c91228233.immval(e,re)
	return re:IsActivated() and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- 抽卡效果的发动条件：自己场上的「勇者衍生物」在战斗中破坏了对方怪兽并送去墓地。
function c91228233.drcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsCode(3285552) and rc:IsControler(tp)
end
-- 抽卡效果的靶向与操作信息注册。
function c91228233.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的对象玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为抽1张卡。
	Duel.SetTargetParam(1)
	-- 注册连锁操作信息：玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的处理：执行抽卡并为本卡注册已发动过②效果的标记。
function c91228233.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁设定的目标玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行因效果抽卡。
	Duel.Draw(p,d,REASON_EFFECT)
	c:RegisterFlagEffect(91228233,RESET_PHASE+PHASE_END,0,1)
end
-- 检索效果的发动条件：本回合已发动过②效果，且当前为自己的主要阶段2。
function c91228233.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本卡是否带有②效果已发动的标记，且当前处于主要阶段2。
	return e:GetHandler():GetFlagEffect(91228233)>0 and Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 检索卡片的过滤条件：记述了「勇者衍生物」且卡名非「迷幻花之森」的场地魔法卡。
function c91228233.thfilter(c)
	-- 过滤出记述了「勇者衍生物」且卡名非「迷幻花之森」的、可以加入手牌的场地魔法卡。
	return aux.IsCodeListed(c,3285552) and c:IsType(TYPE_FIELD) and not c:IsCode(91228233) and c:IsAbleToHand()
end
-- 检索效果的靶向与操作信息注册。
function c91228233.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否存在满足条件的场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c91228233.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 注册连锁操作信息：从卡组或墓地将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索效果的处理：从卡组或墓地选择1张满足条件的卡加入手牌并给对方确认。
function c91228233.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组或墓地选择1张满足过滤条件（且不受王家长眠之谷影响）的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c91228233.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
