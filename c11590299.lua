--ドラ・ドラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤的场合才能发动。从卡组把1只4星以下的龙族·炎属性怪兽加入手卡。
-- ②：1回合1次，自己主要阶段才能发动。自己卡组最上面的卡翻开。翻开的卡是龙族·炎属性怪兽的场合，那只怪兽送去墓地，这张卡的攻击力上升自己场上的「龙宝龙」数量×1000。不是的场合，翻开的卡回到卡组最下面。
local s,id,o=GetID()
-- 为「龙宝龙」注册两个效果：①召唤成功时检索4星以下龙族·炎属性怪兽的诱发效果，②自己主要阶段翻卡顶并根据是否为龙族·炎属性怪兽送墓加攻或放回卡组底的起动效果。
function s.initial_effect(c)
	-- “这个卡名的①的效果1回合只能使用1次。①：这张卡召唤的场合才能发动。从卡组把1只4星以下的龙族·炎属性怪兽加入手卡。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- “②：1回合1次，自己主要阶段才能发动。自己卡组最上面的卡翻开。翻开的卡是龙族·炎属性怪兽的场合，那只怪兽送去墓地，这张卡的攻击力上升自己场上的「龙宝龙」数量×1000。不是的场合，翻开的卡回到卡组最下面。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"翻卡顶"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 定义①效果检索的过滤条件：等级4以下、龙族、炎属性且可以加入手卡的怪兽。
function s.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 设置①效果的发动条件和操作信息：发动前检查卡组中是否存在符合条件的怪兽，并告知系统本次效果要将卡组中的1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：己方卡组中不存在符合条件的怪兽则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：效果类别为回手牌，检索范围为卡组，数量为1张（用于后续效果连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果：提示玩家从卡组选择1只符合条件的怪兽加入手卡，并向对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从己方卡组中选择1张符合s.filter条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入其持有者的手卡，原因是效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡，使其确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义计算“自己场上的「龙宝龙」数量”的过滤条件：表侧表示且卡号为本卡的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(id)
end
-- 设置②效果的发动条件：自己场上有表侧表示的本卡，且卡组顶端有卡可以送去墓地时才能发动。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：必须满足场上有表侧表示的本卡且卡组顶端1张卡能送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 处理②效果：翻开卡组顶端1张；若是龙族·炎属性怪兽则送去墓地，并按自己场上表侧表示「龙宝龙」数量×1000提升攻击力；否则放回卡组最下面。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否能把卡组顶端1张卡送去墓地，不能则处理终止。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 向发动玩家展示卡组最上方1张卡。
	Duel.ConfirmDecktop(tp,1)
	-- 获取卡组最上方的1张卡作为翻开的卡。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_DRAGON) and tc:IsAttribute(ATTRIBUTE_FIRE) then
		-- 禁用本次操作后的自动洗切卡组检测，因为这里只是翻开并送墓/移动卡组顶端卡，不涉及检索洗切。
		Duel.DisableShuffleCheck()
		-- 将翻开的卡以效果+翻开（REASON_REVEAL）的原因送去墓地；若未能送入墓地或该卡不在墓地，则不再进行攻击力上升处理。
		if Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)==0 or not tc:IsLocation(LOCATION_GRAVE) then return end
		-- 统计自己场上表侧表示「龙宝龙」的数量并乘以1000，得到攻击力上升数值。
		local atk=Duel.GetMatchingGroupCount(s.cfilter,c:GetControler(),LOCATION_ONFIELD,0,nil)*1000
		if c:IsRelateToEffect(e) and c:IsFaceup() and atk>0 then
			-- “这张卡的攻击力上升自己场上的「龙宝龙」数量×1000。”
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			c:RegisterEffect(e2)
		end
	else
		-- 若翻开的卡不是龙族·炎属性怪兽，则将其移动到卡组最下面。
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
