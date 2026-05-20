--マドルチェ・サロン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「魔偶甜点」怪兽召唤。
-- ②：这张卡在魔法与陷阱区域存在的状态，自己的场上（表侧表示）·墓地的「魔偶甜点」卡因效果回到自己的手卡·卡组的场合发动。从卡组把「魔偶甜点沙龙」以外的1张「魔偶甜点」魔法·陷阱卡在自己场上盖放。
function c71348837.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「魔偶甜点」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71348837,0))  --"使用「魔偶甜点沙龙」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置增加召唤次数效果的目标为「魔偶甜点」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x71))
	c:RegisterEffect(e2)
	-- ②：这张卡在魔法与陷阱区域存在的状态，自己的场上（表侧表示）·墓地的「魔偶甜点」卡因效果回到自己的手卡·卡组的场合发动。从卡组把「魔偶甜点沙龙」以外的1张「魔偶甜点」魔法·陷阱卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71348837,1))  --"卡组魔陷盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,71348837)
	e3:SetCondition(c71348837.secon)
	e3:SetOperation(c71348837.seop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(e4)
end
-- 过滤条件：属于自己的、原本在自己墓地或场上表侧表示的「魔偶甜点」卡（不含额外卡组）
function c71348837.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp)
		and (c:IsPreviousLocation(LOCATION_GRAVE) or (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)))
		and c:IsSetCard(0x71) and not c:IsLocation(LOCATION_EXTRA)
end
-- 发动条件：因效果导致有满足条件的卡回到手牌或卡组
function c71348837.secon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and eg:IsExists(c71348837.cfilter,1,nil,tp)
end
-- 过滤条件：卡组中「魔偶甜点沙龙」以外的、可盖放的「魔偶甜点」魔法·陷阱卡
function c71348837.sefilter(c)
	return c:IsSetCard(0x71) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and not c:IsCode(71348837)
end
-- 效果处理：从卡组选择1张「魔偶甜点沙龙」以外的「魔偶甜点」魔法·陷阱卡在自己场上盖放
function c71348837.seop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中检索并选择1张满足条件的「魔偶甜点」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c71348837.sefilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片在自己场上盖放
		Duel.SSet(tp,g)
	end
end
