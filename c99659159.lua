--竜操術
-- 效果：
-- ①：有「龙骑兵团」怪兽卡装备的自己场上的怪兽的攻击力上升500。
-- ②：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。从手卡把1只龙族「龙骑兵团」怪兽当作装备卡使用给作为对象的自己怪兽装备。
function c99659159.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：有「龙骑兵团」怪兽卡装备的自己场上的怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTarget(c99659159.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。从手卡把1只龙族「龙骑兵团」怪兽当作装备卡使用给作为对象的自己怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99659159,0))  --"装备"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c99659159.target)
	e3:SetOperation(c99659159.operation)
	c:RegisterEffect(e3)
end
-- 判断装备卡是否为表侧表示且属于「龙骑兵团」系列、原本种类为怪兽的卡，用于筛选能触发攻击力上升的装备卡。
function c99659159.atkcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 判断被检查的怪兽的装备区中是否存在至少1张符合条件的「龙骑兵团」怪兽装备卡，即是否满足攻击力上升的装备条件。
function c99659159.atktg(e,c)
	return c:GetEquipGroup():IsExists(c99659159.atkcfilter,1,nil)
end
-- 筛选手牌中符合条件的龙族「龙骑兵团」怪兽，作为②效果中可装备的卡。
function c99659159.filter(c)
	return c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- ②效果的发动条件和取对象判定：需要自己魔陷区有空位、自己场上有表侧表示怪兽可作为对象、手牌存在符合条件的龙族「龙骑兵团」怪兽。
function c99659159.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动时确认自己魔陷区存在可用的空格，用于放置从手牌装备的怪兽卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认自己场上存在1只表侧表示怪兽可以作为效果对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		-- 确认手牌存在至少1张符合条件的龙族「龙骑兵团」怪兽可供装备。
		and Duel.IsExistingMatchingCard(c99659159.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示“请选择表侧表示的卡”，用于选择对象时的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为②效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：从手牌选择1只龙族「龙骑兵团」怪兽装备给对象怪兽，并给该装备卡设置只能装备给该对象怪兽的限制。
function c99659159.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认魔陷区仍有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 取得②效果选择的自己场上表侧表示怪兽作为装备对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then return end
	-- 向玩家提示“请选择要装备的卡”，用于选择手牌怪兽时的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从手牌选择1只符合条件的龙族「龙骑兵团」怪兽作为装备卡。
	local sg=Duel.SelectMatchingCard(tp,c99659159.filter,tp,LOCATION_HAND,0,1,1,nil)
	if sg:GetCount()==0 then return end
	local sc=sg:GetFirst()
	-- 将选择的龙族「龙骑兵团」怪兽作为装备卡装备给对象怪兽。
	Duel.Equip(tp,sc,tc)
	-- ②：从手卡把1只龙族「龙骑兵团」怪兽当作装备卡使用给作为对象的自己怪兽装备。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c99659159.eqlimit)
	e1:SetLabelObject(tc)
	sc:RegisterEffect(e1)
end
-- 限制该装备卡只能装备给原定的对象怪兽，防止装备对象被改变。
function c99659159.eqlimit(e,c)
	return e:GetLabelObject()==c
end
