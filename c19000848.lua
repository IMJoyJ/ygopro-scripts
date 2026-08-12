--暁光のブイオ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1只恶魔族效果怪兽为对象才能发动。那只怪兽的效果无效，这张卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己的左端·右端的主要怪兽区域的怪兽不会被效果破坏。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把1张「扑天之叛逆」加入手卡。
local s,id,o=GetID()
-- 初始化函数：登记卡名列表，注册手卡发动的无效并特殊召唤效果（1回合1次）、送去墓地时的卡组检索效果（1回合1次）、以及左端·右端主要怪兽区域怪兽不会被效果破坏的永续效果
function s.initial_effect(c)
	-- 登记这张卡上记载着「扑天之叛逆」（卡号71593652）的卡名
	aux.AddCodeList(c,71593652)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡存在的场合，以自己场上1只恶魔族效果怪兽为对象才能发动。那只怪兽的效果无效，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡被送去墓地的场合才能发动。从卡组把1张「扑天之叛逆」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己的左端·右端的主要怪兽区域的怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选可以成为无效对象的恶魔族效果怪兽
function s.cfilter(c)
	-- 该卡为恶魔族，且是表侧表示、未被无效的效果怪兽时返回true
	return c:IsRace(RACE_FIEND) and aux.NegateEffectMonsterFilter(c)
end
-- ①效果的对象选择函数：确认对象合法性，并检查自己主要怪兽区域有空格、这张卡可以特殊召唤、且场上存在可取的恶魔族效果怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end
	-- 发动条件检测：自己主要怪兽区域有1个以上空格，且这张卡可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且自己怪兽区域存在1只以上可以作为对象的恶魔族效果怪兽
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送「请选择要无效的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择自己场上1只恶魔族效果怪兽作为效果对象
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：确定将这张卡（1张）特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：取得对象怪兽，若其表侧表示且可以被无效，则使其效果无效，之后这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的效果对象（那只恶魔族效果怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e) then
		-- 将与对象怪兽有关的连锁无效化（对象变成里侧时重置）
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果无效（注册使效果无效的永续状态）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽发动的效果无效（注册使效果发动无效的状态，对象变成里侧时重置）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if c:IsRelateToChain() then
			-- 将这张卡在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数：筛选卡组中可以加入手卡的「扑天之叛逆」（卡号71593652）
function s.thfilter(c)
	return c:IsCode(71593652) and c:IsAbleToHand()
end
-- ③效果的对象选择函数：确认卡组存在可加入手卡的「扑天之叛逆」，并设置检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：自己卡组存在1张以上可以加入手卡的「扑天之叛逆」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果的处理：从卡组选择1张「扑天之叛逆」加入手卡，并向对方展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送「请选择要加入手牌的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张满足条件的「扑天之叛逆」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡以效果原因加入持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡向对方玩家确认展示
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的适用对象判定：只有自己主要怪兽区域左端（0号位）或右端（4号位）的怪兽适用不会被效果破坏
function s.indtg(e,c)
	return c:GetSequence()==0 or c:GetSequence()==4
end
