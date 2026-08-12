--ダークインファント＠イグニスター
-- 效果：
-- 连接怪兽以外的「@火灵天星」怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「火灵天星“艾”心乐园岛」加入手卡。
-- ②：原本攻击力是2300的电子界族怪兽把效果发动时才能发动。这张卡的位置向作为这张卡所连接区的自己的主要怪兽区域移动。那之后，可以把这张卡的属性直到回合结束时变更为任意属性。
function c74567889.initial_effect(c)
	-- 在卡片中注册其效果记有「火灵天星“艾”心乐园岛」卡名
	aux.AddCodeList(c,59054773)
	-- 为这张卡添加连接召唤的手续
	aux.AddLinkProcedure(c,c74567889.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「火灵天星“艾”心乐园岛」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74567889,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,74567889)
	e1:SetCondition(c74567889.thcon)
	e1:SetTarget(c74567889.thtg)
	e1:SetOperation(c74567889.thop)
	c:RegisterEffect(e1)
	-- ②：原本攻击力是2300的电子界族怪兽把效果发动时才能发动。这张卡的位置向作为这张卡所连接区的自己的主要怪兽区域移动。那之后，可以把这张卡的属性直到回合结束时变更为任意属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74567889,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,74567890)
	e2:SetCondition(c74567889.seqcon)
	e2:SetTarget(c74567889.seqtg)
	e2:SetOperation(c74567889.seqop)
	c:RegisterEffect(e2)
end
-- 连接素材的过滤条件：非连接怪兽的「@火灵天星」怪兽
function c74567889.mfilter(c)
	return not c:IsLinkType(TYPE_LINK) and c:IsLinkSetCard(0x135)
end
-- 效果①的发动条件：这张卡连接召唤成功的场合
function c74567889.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索卡片的过滤条件：卡名为「火灵天星“艾”心乐园岛」且能加入手卡
function c74567889.thfilter(c)
	return c:IsCode(59054773) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查卡组是否存在目标卡并设置操作信息
function c74567889.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c74567889.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组将1张「火灵天星“艾”心乐园岛」加入手卡并给对方确认
function c74567889.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c74567889.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：原本攻击力是2300的电子界族怪兽把效果发动时
function c74567889.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:GetBaseAttack()==2300 and rc:IsRace(RACE_CYBERSE)
end
-- 效果②的发动准备：检查这张卡所连接区的自己的主要怪兽区域是否有空位
function c74567889.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=bit.band(e:GetHandler():GetLinkedZone(),0x1f)
		-- 检查指定的所连接区中是否存在可用的主要怪兽区域空格
		return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0
	end
end
-- 效果②的处理：将这张卡移动到所连接区的自己主要怪兽区域，之后可变更属性
function c74567889.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 若所连接区的可用主要怪兽区域已无空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)<=0 then return end
	local s=zone
	if s&(s-1)~=0 then
		local flag=bit.bxor(zone,0xff)
		-- 提示玩家选择要移动到的位置
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 让玩家在可用的所连接区中选择1个空格
		s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
	end
	local nseq=math.log(s,2)
	-- 将这张卡移动到选择的怪兽区域
	Duel.MoveSequence(c,nseq)
	-- 若成功移动位置，则询问玩家是否变更这张卡的属性
	if c:GetSequence()==nseq and Duel.SelectEffectYesNo(tp,c,aux.Stringid(74567889,2)) then  --"是否变更这张卡的属性？"
		-- 中断当前效果，使之后的效果处理（变更属性）视为不同时处理
		Duel.BreakEffect()
		-- 让玩家宣言1个与当前属性不同的任意属性
		local attr=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~c:GetAttribute())
		-- 可以把这张卡的属性直到回合结束时变更为任意属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(attr)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
