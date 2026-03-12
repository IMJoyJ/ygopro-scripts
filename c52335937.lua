--エクソシスター・バト・マーテル
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：作为这张卡的发动时的效果处理，以下效果适用。
-- ●从卡组把2只「救祓少女」怪兽加入手卡。那之后，选自己1张手卡丢弃。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。进行1只在那只怪兽有卡名记述的「救祓少女」怪兽的召唤。
-- ③：怪兽被送去对方墓地的场合才能发动（伤害步骤也能发动）。对方把那之内的1只除外。
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果：①发动时检索并丢弃手牌；②场上的怪兽追加召唤；③对方怪兽送墓时除外一个
function s.initial_effect(c)
	-- 效果①：作为这张卡的发动时的效果处理，以下效果适用。从卡组把2只「救祓少女」怪兽加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果②：以自己场上1只表侧表示怪兽为对象才能发动。进行1只在那只怪兽有卡名记述的「救祓少女」怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"追加召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	-- 注册一个合并的延迟事件监听器，用于监听怪兽被送去墓地的事件
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_TO_GRAVE)
	-- 效果③：怪兽被送去对方墓地的场合才能发动（伤害步骤也能发动）。对方把那之内的1只除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"除外效果"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(custom_code)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 检索过滤函数，筛选「救祓少女」怪兽且能加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x172) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- 效果①的发动时处理函数，检查是否满足检索条件并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索2张「救祓少女」怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置操作信息为检索2张卡到手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果①的发动处理函数，执行检索和丢弃手牌的操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认是否有满足条件的卡可以检索
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择2张满足条件的卡从卡组加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,2,2,nil)
	-- 判断是否成功将卡加入手牌并执行后续操作
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 向对方确认已加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择1张可丢弃的手牌
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		if dg:GetCount()>0 then
			-- 中断当前效果处理，使之后的效果视为不同时处理
			Duel.BreakEffect()
			-- 将选中的手牌送去墓地
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 召唤目标过滤函数，判断是否能进行追加召唤
function s.cfilter(c,tp)
	return c:IsFaceup()
		-- 判断是否存在满足召唤条件的「救祓少女」怪兽
		and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,c)
end
-- 召唤过滤函数，判断是否为「救祓少女」且可召唤
function s.sumfilter(c,ec)
	-- 返回卡是否为「救祓少女」且可召唤
	return aux.IsCodeListed(ec,c:GetCode()) and c:IsSetCard(0x172) and c:IsSummonable(true,nil)
end
-- 效果②的发动时处理函数，设置目标并准备召唤
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc,tp) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息为召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②的发动处理函数，执行召唤操作
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER)) then return end
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的「救祓少女」怪兽进行召唤
	local sc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tc):GetFirst()
	if sc then
		-- 执行召唤操作
		Duel.Summon(tp,sc,true,nil)
	end
end
-- 效果③的发动条件函数，判断是否有对方怪兽被送去墓地
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 除外过滤函数，筛选对方墓地中的怪兽
function s.rmfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-tp) and c:IsAbleToRemove(1-tp) and c:IsType(TYPE_MONSTER)
end
-- 效果③的发动时处理函数，设置目标并准备除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local sg=eg:Filter(s.rmfilter,nil,tp)
	if chk==0 then return sg:GetCount()>0 end
	-- 设置操作信息的目标卡组
	Duel.SetTargetCard(sg)
	-- 设置操作信息为除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,1,0,0)
end
-- 效果③的发动处理函数，执行除外操作
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 筛选满足条件且未受王家长眠之谷影响的墓地怪兽
	local sg=eg:Filter(s.rmfilter,nil,tp):Filter(aux.NecroValleyFilter(Card.IsRelateToChain),nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=sg:Select(1-tp,1,1,nil)
	if rg and rg:GetCount()>0 then
		-- 显示被选为对象的卡
		Duel.HintSelection(rg)
		-- 将选中的卡除外
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT,1-tp)
	end
end
