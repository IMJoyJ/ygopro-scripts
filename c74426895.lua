--憑依覚醒－ガギゴバイト
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以把自己场上的表侧表示的1只魔法师族怪兽和1只4星以下的水属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤时才能发动。对方手卡随机1张送去墓地。那之后，双方各自抽1张。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「水灵术」卡或「凭依」魔法·陷阱卡加入手卡。
function c74426895.initial_effect(c)
	-- ①：这张卡可以把自己场上的表侧表示的1只魔法师族怪兽和1只4星以下的水属性怪兽送去墓地，从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(c74426895.spcon)
	e1:SetTarget(c74426895.sptg)
	e1:SetOperation(c74426895.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤时才能发动。对方手卡随机1张送去墓地。那之后，双方各自抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74426895,0))
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,74426895)
	e2:SetCondition(c74426895.condition)
	e2:SetTarget(c74426895.hdtg)
	e2:SetOperation(c74426895.hdop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「水灵术」卡或「凭依」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74426895,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,74426896)
	e3:SetCondition(c74426895.thcon)
	e3:SetTarget(c74426895.thtg)
	e3:SetOperation(c74426895.thop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示且能送去墓地的怪兽
function c74426895.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 过滤4星以下的水属性怪兽
function c74426895.spfilter2(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(4)
end
-- 检查选取的卡片组是否满足：怪兽区域有足够空位，且包含1只魔法师族怪兽和1只4星以下的水属性怪兽
function c74426895.fselect(g,tp)
	-- 检查怪兽区空位，并验证卡组是否恰好由1只魔法师族怪兽和1只满足spfilter2过滤条件的怪兽组成
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsRace,RACE_SPELLCASTER,c74426895.spfilter2,nil)
end
-- 特殊召唤规则的条件判定函数
function c74426895.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有表侧表示且能送去墓地的怪兽
	local g=Duel.GetMatchingGroup(c74426895.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c74426895.fselect,2,2,tp)
end
-- 特殊召唤规则的释放目标选择函数
function c74426895.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有表侧表示且能送去墓地的怪兽
	local g=Duel.GetMatchingGroup(c74426895.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 给玩家发送“选择要送去墓地的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c74426895.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的具体执行操作
function c74426895.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽作为特殊召唤的消耗送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判定此卡是否是通过自身①的方法特殊召唤成功
function c74426895.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 丢弃手牌和抽卡效果的发动准备与合法性检测
function c74426895.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		-- 并且判定双方玩家是否都可以进行抽卡
		and Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置连锁信息：对方手牌送去墓地1张
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	-- 设置连锁信息：双方玩家各抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 丢弃手牌和抽卡效果的具体处理逻辑
function c74426895.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方的所有手牌
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	-- 将随机选取的对方手牌送去墓地，并判断是否成功送去墓地
	if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 then
		-- 中断当前效果处理，使后续的抽卡处理与送去墓地不视为同时进行
		Duel.BreakEffect()
		-- 自己因效果抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 对方因效果抽1张卡
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
-- 判定此卡是否是从场上送去墓地
function c74426895.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中属于「水灵术」卡或「凭依」魔法·陷阱卡且能加入手牌的卡
function c74426895.thfilter(c)
	return ((c:IsSetCard(0xc0) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsSetCard(0x514c)) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测
function c74426895.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在符合检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c74426895.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体处理逻辑
function c74426895.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送“选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合检索条件的卡
	local g=Duel.SelectMatchingCard(tp,c74426895.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选取的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
