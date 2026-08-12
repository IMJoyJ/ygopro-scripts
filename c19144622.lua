--妖精伝姫－マチリル
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：场上有原本攻击力是1850的魔法师族怪兽存在的场合才能发动。这张卡从手卡·墓地特殊召唤。这个回合，自己不是魔法师族怪兽不能特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「妖精传姬」魔法·陷阱卡或「妖精的传姬」加入手卡。
-- ③：支付500基本分才能发动。对方场上1只效果怪兽的卡名当作「妖精王子」使用。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：①特殊召唤、②检索、③改变卡名
function s.initial_effect(c)
	-- 记录该卡与「妖精传姬-玛奇莉勒」和「妖精的传姬」的关联
	aux.AddCodeList(c,91957038,19144623)
	-- ①：场上有原本攻击力是1850的魔法师族怪兽存在的场合才能发动。这张卡从手卡·墓地特殊召唤。这个回合，自己不是魔法师族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「妖精传姬」魔法·陷阱卡或「妖精的传姬」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：支付500基本分才能发动。对方场上1只效果怪兽的卡名当作「妖精王子」使用。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"改变卡名"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCost(s.codecost)
	e4:SetTarget(s.codetg)
	e4:SetOperation(s.codeop)
	c:RegisterEffect(e4)
end
-- 过滤函数：检查场上是否存在攻击力为1850且为魔法师族的表侧表示怪兽
function s.cfilter(c)
	return c:GetBaseAttack()==1850 and c:IsRace(RACE_SPELLCASTER) and c:IsFaceup()
end
-- 效果发动条件：场上存在攻击力为1850的魔法师族怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在攻击力为1850的魔法师族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 设置特殊召唤的处理目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，若满足条件则将该卡特殊召唤到场上，并设置不能特殊召唤非魔法师族怪兽的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否与连锁相关且未被王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将该卡以特殊召唤方式送入场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建并注册一个场上的效果，使玩家不能特殊召唤非魔法师族怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能特殊召唤非魔法师族怪兽的效果过滤函数
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_SPELLCASTER)
end
-- 过滤函数：检索卡组中「妖精传姬」魔法·陷阱卡或「妖精的传姬」
function s.thfilter(c)
	return (c:IsCode(91957038) or c:IsSetCard(0x1db) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- 设置检索效果的处理目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作，选择一张卡加入手牌并确认对方看到
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 支付500基本分的处理函数
function s.codecost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤函数：选择对方场上的表侧表示的效果怪兽
function s.codefilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsCode(19144623)
end
-- 设置改变卡名效果的处理目标
function s.codetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的表侧表示的效果怪兽
	local g=Duel.GetMatchingGroup(s.codefilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
end
-- 执行改变卡名操作，将选中的怪兽卡名改为「妖精王子」
function s.codeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要改变卡名的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的表侧表示的效果怪兽
	local g=Duel.SelectMatchingCard(tp,s.codefilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 显示选中的怪兽被选为对象
		Duel.HintSelection(g)
		-- 创建并注册一个使怪兽卡名改变的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(19144623)
		tc:RegisterEffect(e1)
	end
end
