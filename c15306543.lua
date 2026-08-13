--星逢の神籬
-- 效果：
-- ①：1回合1次，可以发动。从自己场上的灵魂怪兽以及「灵魂鸟衍生物」之中让等级合计直到变成仪式召唤的怪兽的等级以上为止解放，从卡组把1只风属性仪式怪兽仪式召唤。
-- ②：1回合最多2次，自己场上的表侧表示的风属性怪兽回到自己手卡的场合，可以从以下效果选择1个发动。
-- ●自己的墓地·除外状态的1只灵魂怪兽或1张仪式魔法卡加入手卡。
-- ●从卡组把1张「星逢的天河」在自己场上盖放。
local s,id,o=GetID()
-- initial_effect函数：为该卡依次注册效果，e1是魔法卡发动所需的ACTIVATE效果；e2是①效果的1回合1次仪式召唤起动效果；e3是②效果的1回合最多2次的风属性怪兽回手触发效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 构建终极仪式召唤公共参数表：素材筛选为风属性怪兽，等级取原始等级，按大于等于方式解放，从卡组仪式召唤，无墓地素材过滤，额外素材过滤条件s.mfilter（自己场上的灵魂怪兽/灵魂鸟衍生物）。
	local t={aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND),Card.GetOriginalLevel,"Greater",LOCATION_DECK,nil,s.mfilter}
	-- ①：1回合1次，可以发动。从自己场上的灵魂怪兽以及「灵魂鸟衍生物」之中让等级合计直到变成仪式召唤的怪兽的等级以上为止解放，从卡组把1只风属性仪式怪兽仪式召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	-- 设置①效果的Target处理：由RitualUltimate生成标准仪式召唤的目标选择逻辑，包括选择要仪式召唤的怪兽并筛选可解放的素材。
	e2:SetTarget(aux.RitualUltimateTarget(table.unpack(t)))
	-- 设置①效果的Operation处理：由RitualUltimate生成仪式召唤的执行逻辑，包括解放素材、从卡组特殊召唤仪式怪兽。
	e2:SetOperation(aux.RitualUltimateOperation(table.unpack(t)))
	c:RegisterEffect(e2)
	-- ②：1回合最多2次，自己场上的表侧表示的风属性怪兽回到自己手卡的场合，可以从以下效果选择1个发动。●自己的墓地·除外状态的1只灵魂怪兽或1张仪式魔法卡加入手卡。●从卡组把1张「星逢的天河」在自己场上盖放。
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
-- s.mfilter：作为①效果的追加素材过滤条件，筛选自己场上主要怪兽区的灵魂怪兽或卡号为25415053的「灵魂鸟衍生物」，这些卡可作为仪式解放素材。
function s.mfilter(c,tp)
	return (c:IsType(TYPE_SPIRIT) or c:IsCode(25415053)) and c:IsLocation(LOCATION_MZONE)
end
-- s.cfilter：判断回到手卡的怪兽是否满足触发条件：之前是表侧表示、持有风属性、之前在自己怪兽区且控制者是自己，并且现在仍由自己控制。
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_WIND)~=0 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- s.condition：检测本次加入手卡的事件组eg中是否存在至少1张满足s.cfilter的怪兽，即自己场上的表侧表示风属性怪兽是否回到了自己手卡。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- s.filter：筛选墓地·除外状态中可作为回收对象的卡：表侧表示/可确认的怪兽类型为灵魂怪兽，或类型位含0x82（仪式魔法卡）的卡，并且该卡能够加入手卡。
function s.filter(c)
	return c:IsFaceupEx() and (c:IsType(TYPE_SPIRIT) or c:GetType()&0x82==0x82) and c:IsAbleToHand()
end
-- s.sfilter：从卡组筛选卡名为「星逢的天河」（卡号20417688）且当前可以被盖放的卡。
function s.sfilter(c)
	return c:IsCode(20417688) and c:IsSSetable()
end
-- s.target：②效果发动时的Target处理：分别检测墓地·除外的回收素材（b1）和卡组的「星逢的天河」（b2）；若满足其一则让玩家选择要发动的选项，并动态设置本效果实际分类和操作函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地·除外状态是否存在至少1张满足s.filter的卡（灵魂怪兽或仪式魔法卡），作为选择回收选项的前提。
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	-- 检查自己卡组是否存在至少1张满足s.sfilter的「星逢的天河」，作为选择盖放选项的前提。
	local b2=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 让玩家从可用选项中选1个：{b1,1190}对应回收墓地·除外的卡，{b2,1153}对应从卡组盖放「星逢的天河」，返回值用于后续分支。
	local op=aux.SelectFromOptions(tp,{b1,1190},{b2,1153})
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetOperation(s.retrieve)
		-- 设置操作信息：若选择回收，则声明本连锁要处理加入手卡分类，目标位置为墓地+除外，数量为1，供相关卡进行连锁判定。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	else
		e:SetCategory(CATEGORY_SSET)
		e:SetOperation(s.ssettrap)
	end
end
-- s.retrieve：回收选项的实际处理：从自己墓地·除外状态选择1张符合条件的灵魂怪兽或仪式魔法卡加入手卡，并给对方确认。
function s.retrieve(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地·除外状态选择1张满足s.filter且不受王家长眠之谷影响的卡，返回选中组g。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡g加入其持有者的手卡（nil表示加入持有者手卡），原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡g，以确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- s.ssettrap：盖放选项的实际处理：从自己卡组选择1张「星逢的天河」盖放到自己魔陷区。
function s.ssettrap(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己卡组选择1张满足s.sfilter的「星逢的天河」，并取得第一张作为tc。
	local tc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 若tc存在，则将其以里侧表示盖放到自己场上（Duel.SSet）。
	if tc then Duel.SSet(tp,tc) end
end
