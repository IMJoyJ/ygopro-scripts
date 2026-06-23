--星逢の神籬
-- 效果：
-- ①：1回合1次，可以发动。从自己场上的灵魂怪兽以及「灵魂鸟衍生物」之中让等级合计直到变成仪式召唤的怪兽的等级以上为止解放，从卡组把1只风属性仪式怪兽仪式召唤。
-- ②：1回合最多2次，自己场上的表侧表示的风属性怪兽回到自己手卡的场合，可以从以下效果选择1个发动。
-- ●自己的墓地·除外状态的1只灵魂怪兽或1张仪式魔法卡加入手卡。
-- ●从卡组把1张「星逢的天河」在自己场上盖放。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果，使卡能被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 定义仪式召唤所需参数：风属性、等级获取方式、等级比较关系、召唤区域、墓地过滤器、场上过滤器
	local t={aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND),Card.GetOriginalLevel,"Greater",LOCATION_DECK,nil,s.mfilter}
	-- ①：1回合1次，可以发动。从自己场上的灵魂怪兽以及「灵魂鸟衍生物」之中让等级合计直到变成仪式召唤的怪兽的等级以上为止解放，从卡组把1只风属性仪式怪兽仪式召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	-- 设置仪式召唤效果的目标处理函数
	e2:SetTarget(aux.RitualUltimateTarget(table.unpack(t)))
	-- 设置仪式召唤效果的操作处理函数
	e2:SetOperation(aux.RitualUltimateOperation(table.unpack(t)))
	c:RegisterEffect(e2)
	-- ②：1回合最多2次，自己场上的表侧表示的风属性怪兽回到自己手卡的场合，可以从以下效果选择1个发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(2)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	c:RegisterEffect(e3)
end
s.has_text_type=TYPE_SPIRIT
-- 过滤场上可作为仪式召唤素材的灵魂怪兽或灵魂鸟衍生物
function s.mfilter(c,tp)
	return (c:IsType(TYPE_SPIRIT) or c:IsCode(25415053)) and c:IsLocation(LOCATION_MZONE)
end
-- 判断怪兽是否为风属性且从场上回到手牌
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_WIND)~=0 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判断是否有满足条件的怪兽回到手牌
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤墓地或除外状态的可加入手牌的灵魂怪兽或仪式魔法卡
function s.filter(c)
	return c:IsFaceupEx() and (c:IsType(TYPE_SPIRIT) or c:GetType()&0x82==0x82) and c:IsAbleToHand()
end
-- 过滤可盖放的「星逢的天河」
function s.sfilter(c)
	return c:IsCode(20417688) and c:IsSSetable()
end
-- 设置效果选择目标时的处理逻辑，根据是否有可选卡决定效果类别和操作
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的墓地或除外状态的卡可加入手牌
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	-- 检查是否有满足条件的「星逢的天河」可盖放
	local b2=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 根据玩家选择决定效果处理方式
	local op=aux.SelectFromOptions(tp,{b1,1190},{b2,1153})
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetOperation(s.retrieve)
		-- 设置操作信息，用于提示将要处理的卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	else
		e:SetCategory(CATEGORY_SSET)
		e:SetOperation(s.ssettrap)
	end
end
-- 处理将墓地或除外状态的卡加入手牌的效果
function s.retrieve(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 处理将「星逢的天河」盖放的效果
function s.ssettrap(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的「星逢的天河」
	local tc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 将选中的卡盖放
	if tc then Duel.SSet(tp,tc) end
end
