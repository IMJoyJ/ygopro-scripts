--マドルチェ・チケット
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在魔法与陷阱区域存在的状态，自己的场上（表侧表示）·墓地的「魔偶甜点」卡因效果回到自己的手卡·卡组的场合发动。从卡组把1只「魔偶甜点」怪兽加入手卡。自己场上有天使族「魔偶甜点」怪兽存在的场合，也能不加入手卡攻击表示特殊召唤。
function c60470713.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡在魔法与陷阱区域存在的状态，自己的场上（表侧表示）·墓地的「魔偶甜点」卡因效果回到自己的手卡·卡组的场合发动。从卡组把1只「魔偶甜点」怪兽加入手卡。自己场上有天使族「魔偶甜点」怪兽存在的场合，也能不加入手卡攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60470713,0))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,60470713)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCondition(c60470713.condition)
	e2:SetTarget(c60470713.target)
	e2:SetOperation(c60470713.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_HAND)
	c:RegisterEffect(e3)
end
-- 过滤条件：属于自己且回到自己手卡或卡组的、原本在自己墓地或场上表侧表示存在的、非额外卡组的「魔偶甜点」卡
function c60470713.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp)
		and (c:IsPreviousLocation(LOCATION_GRAVE) or (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)))
		and c:IsSetCard(0x71) and not c:IsLocation(LOCATION_EXTRA)
end
-- 触发条件：因效果导致有满足过滤条件的卡回到手卡或卡组
function c60470713.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and eg:IsExists(c60470713.cfilter,1,nil,tp)
end
-- 效果的目标处理：作为必发效果，直接返回true
function c60470713.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 过滤条件：自己场上表侧表示的天使族「魔偶甜点」怪兽
function c60470713.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x71) and c:IsRace(RACE_FAIRY)
end
-- 过滤条件：卡组中的「魔偶甜点」怪兽，且满足能加入手卡或（在满足特殊召唤条件时）能以表侧攻击表示特殊召唤
function c60470713.filter(c,e,tp,chk)
	return c:IsSetCard(0x71) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK))
end
-- 效果的处理：检查是否满足特殊召唤条件，从卡组选择1只「魔偶甜点」怪兽，根据条件和玩家选择将其加入手卡或特殊召唤
function c60470713.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，且存在表侧表示的天使族「魔偶甜点」怪兽
	local b=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c60470713.mfilter,tp,LOCATION_MZONE,0,1,nil)
	-- 给玩家发送“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的「魔偶甜点」怪兽
	local g=Duel.SelectMatchingCard(tp,c60470713.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,b)
	local tc=g:GetFirst()
	if tc then
		if b and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
			-- 如果该怪兽不能加入手卡，或者玩家在提示窗口中选择将其特殊召唤（选项1为特殊召唤）
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的怪兽区域
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		else
			-- 将选择的怪兽加入玩家手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
