--白き森の魔女
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「白森林」怪兽加入手卡。那个场合，这个回合，自己不能把暗属性怪兽从额外卡组特殊召唤。
-- ②：自己的「白森林」怪兽在1回合各有1次不会被战斗破坏。
-- ③：以自己场上1只「白森林」怪兽为对象才能发动。这个回合，那只怪兽当作调整使用。
local s,id,o=GetID()
-- 初始化效果函数，创建3个效果并注册到卡片上
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「白森林」怪兽加入手卡。那个场合，这个回合，自己不能把暗属性怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「白森林」怪兽在1回合各有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	-- ③：以自己场上1只「白森林」怪兽为对象才能发动。这个回合，那只怪兽当作调整使用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"变成调整"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tntg)
	e3:SetOperation(s.tnop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于检索卡组中满足条件的「白森林」怪兽
function s.filter(c)
	return c:IsSetCard(0x1b1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动效果函数，从卡组检索1只「白森林」怪兽加入手牌，并在本回合禁止自己从额外卡组特殊召唤暗属性怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组卡片组
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 判断是否有满足条件的卡且玩家选择是否发动效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否从卡组把卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
		-- 创建并注册一个禁止自己从额外卡组特殊召唤暗属性怪兽的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.limit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果函数，判断是否为额外卡组的暗属性怪兽
function s.limit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 判断目标是否为「白森林」怪兽
function s.indtg(e,c)
	return c:IsSetCard(0x1b1)
end
-- 判断是否为战斗破坏，若是则返回1次不被破坏
function s.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 过滤函数，用于选择场上满足条件的「白森林」怪兽作为效果对象
function s.tnfilter(c)
	return c:IsSetCard(0x1b1) and c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
-- 选择效果对象函数，选择场上1只「白森林」怪兽作为对象
function s.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tnfilter(chkc) end
	-- 判断是否有满足条件的场上目标
	if chk==0 then return Duel.IsExistingTarget(s.tnfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只「白森林」怪兽作为对象
	Duel.SelectTarget(tp,s.tnfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，将目标怪兽变为调整
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 创建并注册一个使目标怪兽获得调整属性的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
