--白き森の魔女
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「白森林」怪兽加入手卡。那个场合，这个回合，自己不能把暗属性怪兽从额外卡组特殊召唤。
-- ②：自己的「白森林」怪兽在1回合各有1次不会被战斗破坏。
-- ③：以自己场上1只「白森林」怪兽为对象才能发动。这个回合，那只怪兽当作调整使用。
local s,id,o=GetID()
-- 注册这张卡的3个效果：①发动时的检索并附加暗属性自肃；②自己的「白森林」怪兽一回合一次战斗破坏耐性；③起动效果使对象怪兽变成调整。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「白森林」怪兽加入手卡。
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
	-- 这个卡名的③的效果1回合只能使用1次。③：以自己场上1只「白森林」怪兽为对象才能发动。这个回合，那只怪兽当作调整使用。
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
-- 定义检索过滤器：从卡组中筛选出「白森林」怪兽且能够加入手卡的卡。
function s.filter(c)
	return c:IsSetCard(0x1b1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的处理：若卡组存在符合条件的「白森林」怪兽且玩家选择是，则从卡组选1张加入手卡并给对方确认，之后给自己附加本回合不能从额外卡组特殊召唤暗属性怪兽的自肃。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足s.filter的「白森林」怪兽。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 若存在可检索的卡且玩家确认发动检索，则继续处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否从卡组把卡加入手卡？"
		-- 显示选择提示，让玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡加入其持有者的手卡（即自己手卡）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,sg)
		-- 那个场合，这个回合，自己不能把暗属性怪兽从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.limit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将自肃效果注册到当前玩家tp，使其在本回合内受到该限制。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃的判定条件：从额外卡组特殊召唤的怪兽是暗属性时不能特殊召唤。
function s.limit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- ②的耐性对象判定：自己的「白森林」怪兽。
function s.indtg(e,c)
	return c:IsSetCard(0x1b1)
end
-- ②的耐性次数：当破坏原因为战斗时，提供1次不会被战斗破坏的次数。
function s.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- ③的对象筛选：自己场上的表侧表示且不是调整的「白森林」怪兽。
function s.tnfilter(c)
	return c:IsSetCard(0x1b1) and c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
-- ③的发动目标处理：不能取对象时直接判定；合法时选择自己场上1只符合条件的「白森林」怪兽作为对象。
function s.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tnfilter(chkc) end
	-- 发动时检查自己场上是否存在至少1只符合条件的「白森林」怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.tnfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择对象的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的「白森林」怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,s.tnfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ③的效果处理：对象怪兽直到回合结束获得调整种类。
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取③效果选择的唯一对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 这个回合，那只怪兽当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
