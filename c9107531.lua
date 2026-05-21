--エレクトロ・ガンナー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己把炎属性怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1只炎族·8星怪兽送去墓地。
-- ②：1回合1次，魔法卡发动的场合才能发动。自己场上的全部炎属性怪兽的攻击力上升300。
local s,id,o=GetID()
-- 注册卡片效果：①效果（召唤·特殊召唤时手卡特召+卡组送墓）和②效果（魔法卡发动时场上炎属性怪兽攻击力上升）。
function s.initial_effect(c)
	-- ①：自己把炎属性怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1只炎族·8星怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，魔法卡发动的场合才能发动。自己场上的全部炎属性怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己召唤·特殊召唤成功的表侧表示炎属性怪兽。
function s.spfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsSummonPlayer(tp) and c:IsFaceup()
end
-- 发动条件：自己召唤·特殊召唤炎属性怪兽成功的场合。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp)
end
-- 发动准备/效果处理：检查自身是否能特殊召唤以及怪兽区域是否有空位。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否有可用的怪兽区域空格。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置连锁信息：包含特殊召唤自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤条件：卡组中炎族·8星且能送去墓地的怪兽。
function s.tgfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsLevel(8) and c:IsAbleToGrave()
end
-- 效果处理：将这张卡从手卡特殊召唤，之后可以从卡组把1只炎族·8星怪兽送去墓地。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于手卡，则将其特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查卡组中是否存在满足条件的炎族·8星怪兽。
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否选择执行“从卡组把1只炎族·8星怪兽送去墓地”的效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否要从卡组送去墓地？"
		-- 中断当前效果处理，使后续的送去墓地处理与特殊召唤不视为同时进行。
		Duel.BreakEffect()
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家从卡组选择1只满足条件的炎族·8星怪兽。
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选中的怪兽因效果送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 发动条件：魔法卡发动时。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 过滤条件：自己场上表侧表示的炎属性怪兽。
function s.atkfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceup()
end
-- 发动准备：检查自己场上是否存在表侧表示的炎属性怪兽。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的炎属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：使自己场上全部炎属性怪兽的攻击力上升300。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上全部表侧表示的炎属性怪兽。
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力上升300
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(300)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
