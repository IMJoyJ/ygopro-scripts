--竜の影光
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●手卡1只龙族·8星怪兽回到卡组，和那只怪兽属性不同的1只龙族·8星怪兽从卡组加入手卡。
-- ●以自己场上1只龙族怪兽为对象才能发动。那只怪兽的攻击力上升自身的等级×200。
-- ●自己场上的龙族怪兽为对象的卡的效果发动时才能发动。那个效果无效。
local s,id,o=GetID()
-- 初始化函数，注册卡片发动的三个可选效果（检索、上升攻击力、无效效果）
function s.initial_effect(c)
	-- ●手卡1只龙族·8星怪兽回到卡组，和那只怪兽属性不同的1只龙族·8星怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ●以自己场上1只龙族怪兽为对象才能发动。那只怪兽的攻击力上升自身的等级×200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ●自己场上的龙族怪兽为对象的卡的效果发动时才能发动。那个效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中与指定属性不同、且可以加入手牌的8星龙族怪兽
function s.thfilter(c,att)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(8) and c:IsAbleToHand()
		and not c:IsAttribute(att)
end
-- 过滤手牌中可以回到卡组、且卡组中存在与其属性不同的8星龙族怪兽的8星龙族怪兽
function s.tdfilter(c,tp)
	return c:IsAbleToDeck() and c:IsRace(RACE_DRAGON) and c:IsLevel(8)
		-- 检查卡组中是否存在与该卡属性不同的、满足检索条件的怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
-- 效果①中“手牌怪兽回卡组并检索不同属性怪兽”效果的发动准备与合法性检查函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足返回卡组条件的8星龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁信息，表明此效果包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①中“手牌怪兽回卡组并检索不同属性怪兽”效果的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手牌选择1只满足条件的8星龙族怪兽
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 给对方玩家确认选中的手牌怪兽
		Duel.ConfirmCards(1-tp,tc)
		-- 将选中的怪兽送回卡组并洗牌，若成功送回卡组则继续处理
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) then
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从卡组选择1只与返回卡组的怪兽属性不同的8星龙族怪兽
			local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetAttribute())
			-- 将选中的怪兽加入玩家手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的怪兽
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
-- 过滤场上表侧表示且等级在1星以上的龙族怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsLevelAbove(1)
end
-- 效果①中“提升龙族怪兽攻击力”效果的发动准备与对象选择函数
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的龙族怪兽作为效果对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①中“提升龙族怪兽攻击力”效果的处理函数
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		local atk=tc:GetLevel()*200
		-- 那只怪兽的攻击力上升自身的等级×200。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
	end
end
-- 过滤自己场上表侧表示的龙族怪兽，用于判断是否被选为效果对象
function s.negfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_DRAGON) and c:IsControler(tp) and c:IsFaceup()
end
-- 效果①中“无效以龙族怪兽为对象的效果”效果的发动条件判断函数
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.negfilter,1,nil,tp)
		-- 检查当前连锁的效果是否可以被无效
		and Duel.IsChainDisablable(ev)
end
-- 效果①中“无效以龙族怪兽为对象的效果”效果的发动准备与合法性检查函数
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁信息，表明此效果包含使效果无效的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果①中“无效以龙族怪兽为对象的效果”效果的处理函数
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的效果无效
	Duel.NegateEffect(ev)
end
