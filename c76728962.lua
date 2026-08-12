--デスペラード・リボルバー・ドラゴン
-- 效果：
-- ①：自己场上的机械族·暗属性怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，自己·对方的战斗阶段才能发动。进行3次投掷硬币。选最多有表出现数量的场上的表侧表示怪兽破坏。3次都是表的场合，再让自己从卡组抽1张。这个效果发动的回合，这张卡不能攻击。
-- ③：这张卡被送去墓地的场合才能发动。把持有进行投掷硬币效果的1只7星以下的怪兽从卡组加入手卡。
function c76728962.initial_effect(c)
	-- ①：自己场上的机械族·暗属性怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76728962,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c76728962.condition)
	e1:SetTarget(c76728962.target)
	e1:SetOperation(c76728962.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己·对方的战斗阶段才能发动。进行3次投掷硬币。选最多有表出现数量的场上的表侧表示怪兽破坏。3次都是表的场合，再让自己从卡组抽1张。这个效果发动的回合，这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76728962,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_COIN+CATEGORY_DRAW)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c76728962.descon)
	e2:SetCost(c76728962.descost)
	e2:SetTarget(c76728962.destg)
	e2:SetOperation(c76728962.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。把持有进行投掷硬币效果的1只7星以下的怪兽从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(76728962,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(c76728962.thtg)
	e3:SetOperation(c76728962.thop)
	c:RegisterEffect(e3)
end
-- 过滤出因战斗或效果破坏、原本在场上是表侧表示的自己场上的机械族·暗属性怪兽
function c76728962.filter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and bit.band(c:GetPreviousRaceOnField(),RACE_MACHINE)~=0
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_DARK)~=0 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 检查被破坏的卡片中是否存在满足过滤条件的怪兽
function c76728962.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c76728962.filter,1,nil,tp)
end
-- 效果①的发动准备，检查怪兽区域空位数以及自身是否能特殊召唤
function c76728962.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理，将手卡中的这张卡特殊召唤
function c76728962.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动条件，检查当前是否处于战斗阶段
function c76728962.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否在战斗阶段开始到战斗阶段结束之间
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 效果②的代价处理，检查攻击宣言次数并对自身施加不能攻击的限制
function c76728962.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果②的发动准备，检查场上是否存在表侧表示怪兽，并设置投硬币和抽卡的操作信息
function c76728962.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置投掷3次硬币的操作信息
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
	-- 设置抽1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理，进行3次投硬币，选择最多有正面数量的表侧表示怪兽破坏，若3次都是正面则再抽1张卡
function c76728962.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有的表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 让发动效果的玩家进行3次投掷硬币
	local c1,c2,c3=Duel.TossCoin(tp,3)
	local ct=c1+c2+c3
	if ct==0 then return end
	if ct>g:GetCount() then ct=g:GetCount() end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=g:Select(tp,1,ct,nil)
	-- 手动为选中的破坏目标卡片显示被选择的动画效果
	Duel.HintSelection(dg)
	-- 破坏选中的怪兽，并判断是否成功破坏且3次硬币结果均为正面
	if Duel.Destroy(dg,REASON_EFFECT)~=0 and c1+c2+c3==3 then
		-- 中断当前效果处理，使后续的抽卡处理与破坏处理不视为同时进行
		Duel.BreakEffect()
		-- 让发动效果的玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤出卡组中持有投硬币效果的7星以下的怪兽
function c76728962.thfilter(c)
	-- 检查卡片是否具有投硬币的效果属性、是怪兽卡、等级在7星以下且可以加入手卡
	return c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(7) and c:IsAbleToHand()
end
-- 效果③的发动准备，检查卡组中是否存在符合条件的怪兽，并设置检索的操作信息
function c76728962.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76728962.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理，从卡组选择1只符合条件的怪兽加入手卡并给对方确认
function c76728962.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c76728962.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
