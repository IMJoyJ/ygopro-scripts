--古代の機械弩士
-- 效果：
-- 机械族·地属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1只「古代的机械」怪兽或1张「齿车街」加入手卡。
-- ②：以自己场上1张魔法·陷阱卡和对方场上1只表侧表示怪兽为对象才能发动。那张自己的卡破坏，那只对方怪兽的攻击力·守备力直到回合结束时变成0。
function c10547580.initial_effect(c)
	-- 为这张卡设定连接召唤手续：需要2只地属性机械族怪兽作为连接素材。
	aux.AddLinkProcedure(c,c10547580.mfilter,2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1只「古代的机械」怪兽或1张「齿车街」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10547580,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,10547580)
	e1:SetCondition(c10547580.thcon)
	e1:SetTarget(c10547580.thtg)
	e1:SetOperation(c10547580.thop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1张魔法·陷阱卡和对方场上1只表侧表示怪兽为对象才能发动。那张自己的卡破坏，那只对方怪兽的攻击力·守备力直到回合结束时变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10547580,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,10547581)
	e2:SetTarget(c10547580.destg)
	e2:SetOperation(c10547580.desop)
	c:RegisterEffect(e2)
end
-- 连接素材的过滤函数：素材怪兽必须同时具有地属性和机械族（代码中通过连接标记属性和种族进行判定）。
function c10547580.mfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_EARTH) and c:IsLinkRace(RACE_MACHINE)
end
-- 效果①的发动条件：这张卡以连接召唤方式特殊召唤成功（召唤类型为连接召唤）时才能发动。
function c10547580.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索对象过滤条件：满足「古代的机械」字段的怪兽或卡名「齿车街」，且可以被加入手卡。
function c10547580.thfilter(c)
	return ((c:IsSetCard(0x7) and c:IsType(TYPE_MONSTER)) or c:IsCode(37694547)) and c:IsAbleToHand()
end
-- 效果①的发动合法性检查：卡组存在至少1张符合条件的卡；并设定将1张卡从卡组加入手卡的操作信息。
function c10547580.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查卡组中是否存在至少1张满足检索条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c10547580.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：本次效果处理时将1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理：从卡组选择1张符合条件的卡加入手卡，若选择则将其加入持有者手卡并展示给对方确认。
function c10547580.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足thfilter过滤条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c10547580.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果选取对方怪兽的过滤条件：表侧表示，且攻击力或守备力至少为1。
function c10547580.desfilter(c)
	return c:IsFaceup() and (c:IsAttackAbove(1) or c:IsDefenseAbove(1))
end
-- ②效果的target函数：选择自己场上1张魔法·陷阱卡和对方场上1只满足条件的表侧表示怪兽为对象，并检查是否存在合法对象。
function c10547580.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1张魔法·陷阱卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,0,1,nil,TYPE_SPELL+TYPE_TRAP)
		-- 检查对方场上是否存在1只满足desfilter条件的表侧表示怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c10547580.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 选择自己场上的1张魔法·陷阱卡作为第一个效果对象。
	local g1=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,0,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	e:SetLabelObject(g1:GetFirst())
	-- 选择对方场上的1只满足条件的表侧表示怪兽作为第二个效果对象。
	local g2=Duel.SelectTarget(tp,c10547580.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设定操作信息：本次效果将破坏所选择的自己场上的那张魔法·陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
end
-- ②效果处理：若自己的魔法·陷阱卡仍与效果相关且破坏成功，且对方怪兽仍与效果相关、为对方场上表侧表示，则将该对方怪兽的攻击力·守备力直到回合结束时变成0。
function c10547580.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 获取当前连锁记录的效果对象卡组（包含自己魔陷与对方怪兽）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	-- 判定是否继续处理：自己的魔陷仍与效果相关、自己控制且破坏成功，且对方怪兽仍与效果相关、对方控制并表侧表示。
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and Duel.Destroy(tc,REASON_EFFECT)~=0 and lc:IsRelateToEffect(e)
		and lc:IsControler(1-tp) and lc:IsFaceup() then
		-- 那只对方怪兽的攻击力·守备力直到回合结束时变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		lc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		lc:RegisterEffect(e2)
	end
end
