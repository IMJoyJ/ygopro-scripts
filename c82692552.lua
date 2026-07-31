--耀爛竜コラリアネクテス
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌非抽卡加手展示特召与自锁效果、②场地有「海」时水属性连接怪兽抗对象效果
function s.initial_effect(c)
	-- 记录此卡记载了「海」(22702055)的卡名
	aux.AddCodeList(c,22702055)
	-- ①：这张卡抽卡以外的方法加入手牌的场合，把这张卡和手牌1只水属性怪兽给对方观看才能发动。那2只特殊召唤。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有「海」存在，自己场上的水属性L怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.econ)
	e2:SetTarget(s.tgtg)
	-- 设置抗性类型：不会成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- ①效果发动条件：此卡不是通过抽卡加入手牌
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- Cost过滤条件：手牌中未公开且可特殊召唤的水属性怪兽
function s.costfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动Cost：展示手牌中包含自身在内的2只水属性怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- Cost检查：手牌中是否存在除自身外可特殊召唤的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 提示玩家选择要确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌选择1只满足条件的水属性怪兽
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c,e,tp):GetFirst()
	-- 向对方玩家确认选择的水属性怪兽
	Duel.ConfirmCards(1-tp,sc)
	-- 洗切手牌
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- ①效果发动准备：检查场地格数、青眼精灵龙限制与自身状态，设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查主要怪兽区域空位数是否大于1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not e:GetHandler():IsPublic() end
	-- 设置连锁操作信息：从手牌特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- ①效果处理：将展示的2只水属性怪兽特殊召唤，并注册本回合只能特召水属性怪兽的自锁
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(Card.IsRelateToChain,nil)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查主要怪兽区域空位数是否至少有2个
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and fg:GetCount()==2 then
		-- 将选中的2只怪兽表侧表示特殊召唤
		Duel.SpecialSummon(fg,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册本回合特殊召唤属性限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制条件：禁止特殊召唤水属性以外的怪兽
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤条件：场表侧表示的「海」(22702055)
function s.cfilter(c)
	return c:IsCode(22702055) and c:IsFaceup()
end
-- ②效果生效条件：场地环境或场上存在「海」
function s.econ(e)
	local tp=e:GetHandlerPlayer()
	-- 检查当前场地环境是否为「海」
	return Duel.IsEnvironment(22702055,tp)
		-- 检查场上是否存在表侧表示的「海」
		or Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②效果影响对象过滤：自己场上的水属性连接怪兽
function s.tgtg(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_LINK)
end
