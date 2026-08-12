--捕食植物テッポウリザード
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上有「捕食植物」怪兽或「凶饿毒」怪兽存在的场合才能发动。这张卡特殊召唤。那之后，可以从卡组把1张「融合」加入手卡。
-- ②：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的属性直到回合结束时变成暗属性。
-- ③：这张卡从墓地特殊召唤的场合才能发动。自己抽1张。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果
function s.initial_effect(c)
	-- 记录该卡拥有「捕食植物」或「凶饿毒」的卡名
	aux.AddCodeList(c,24094653)
	-- ①：这张卡在手卡存在，自己场上有「捕食植物」怪兽或「凶饿毒」怪兽存在的场合才能发动。这张卡特殊召唤。那之后，可以从卡组把1张「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的属性直到回合结束时变成暗属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变属性"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
	-- ③：这张卡从墓地特殊召唤的场合才能发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在「捕食植物」或「凶饿毒」的表侧表示怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10f3,0x1050)
end
-- 效果条件函数，判断是否满足①效果的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动时点处理，设置特殊召唤的卡为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤函数，用于检索卡组中「融合」卡
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- ①效果的处理函数，特殊召唤此卡并检索融合卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否在连锁中且能特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查卡组中是否存在「融合」卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否要将融合卡加入手牌
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择卡组中的一张「融合」卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续处理不同时进行
			Duel.BreakEffect()
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 过滤函数，用于判断是否为表侧表示且非暗属性的怪兽
function s.attfilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_DARK)
end
-- ②效果的发动时点处理，选择目标怪兽
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.attfilter(chkc) end
	-- 检查场上是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上的一只表侧表示怪兽作为目标
	Duel.SelectTarget(tp,s.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ②效果的处理函数，将目标怪兽属性变为暗属性
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and not tc:IsAttribute(ATTRIBUTE_DARK) then
		-- 将目标怪兽的属性改为暗属性，持续到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ATTRIBUTE_DARK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的发动条件函数，判断此卡是否从墓地特殊召唤
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- ③效果的发动时点处理，设置抽卡效果
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息，表示将进行抽卡处理
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ③效果的处理函数，执行抽卡效果
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
