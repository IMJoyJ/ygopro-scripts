--古代の機械弩士
-- 效果：
-- 机械族·地属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1只「古代的机械」怪兽或1张「齿车街」加入手卡。
-- ②：以自己场上1张魔法·陷阱卡和对方场上1只表侧表示怪兽为对象才能发动。那张自己的卡破坏，那只对方怪兽的攻击力·守备力直到回合结束时变成0。
function c10547580.initial_effect(c)
	-- 为卡片添加连接召唤手续，需要2个满足条件的连接素材
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
-- 连接素材过滤函数，筛选地属性机械族怪兽
function c10547580.mfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_EARTH) and c:IsLinkRace(RACE_MACHINE)
end
-- 效果发动条件判断函数，判断是否为连接召唤
function c10547580.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤函数，筛选「古代的机械」怪兽或「齿车街」
function c10547580.thfilter(c)
	return ((c:IsSetCard(0x7) and c:IsType(TYPE_MONSTER)) or c:IsCode(37694547)) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，设置检索目标
function c10547580.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，检查卡组是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c10547580.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定检索效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，执行检索操作
function c10547580.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要检索的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c10547580.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 破坏对象过滤函数，筛选攻击力或守备力大于0的怪兽
function c10547580.desfilter(c)
	return c:IsFaceup() and (c:IsAttackAbove(1) or c:IsDefenseAbove(1))
end
-- 效果发动时的处理函数，设置破坏和改变攻击力守备力的效果目标
function c10547580.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足破坏对象条件，检查自己场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,0,1,nil,TYPE_SPELL+TYPE_TRAP)
		-- 判断是否满足破坏对象条件，检查对方场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c10547580.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 选择自己场上的魔法·陷阱卡作为破坏对象
	local g1=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,0,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	e:SetLabelObject(g1:GetFirst())
	-- 选择对方场上的怪兽作为攻击力守备力归零的对象
	local g2=Duel.SelectTarget(tp,c10547580.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定破坏效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
end
-- 效果发动时的处理函数，执行破坏和改变攻击力守备力的操作
function c10547580.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 获取当前连锁中指定的目标卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	-- 判断破坏和改变攻击力守备力的效果是否可以正常处理
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and Duel.Destroy(tc,REASON_EFFECT)~=0 and lc:IsRelateToEffect(e)
		and lc:IsControler(1-tp) and lc:IsFaceup() then
		-- 设置对方怪兽攻击力归零的效果
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
