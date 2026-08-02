--耀爛竜コラリアネクテス
local s,id,o=GetID()
-- 声明initial_effect函数，添加代码列表，注册展示特召和获得取对象抗性的效果
function s.initial_effect(c)
	-- 记录这张卡上记载着「海」的具体卡号
	aux.AddCodeList(c,22702055)
	-- 这张卡用抽卡以外的方法加入手卡的场合，把手卡1只水属性怪兽给对方观看才能发动。这张卡和观看的怪兽特殊召唤。
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
	-- 只要自己场上有「海」存在，自己场上的水属性连接怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.econ)
	e2:SetTarget(s.tgtg)
	-- 设置使对象怪兽不能成为对方效果对象的值
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 判断卡片加入手牌的原因是否不是由于抽卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- 过滤条件：判断是否为手牌中未公开的水属性怪兽
function s.costfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 将手牌1只未公开的水属性怪兽给对方确认作为效果发动的cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断手牌是否存在可供确认的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 提示选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手牌中选择1只水属性怪兽用于确认
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c,e,tp):GetFirst()
	-- 向对方确认选中的卡片
	Duel.ConfirmCards(1-tp,sc)
	-- 洗切自己手卡
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- 判断是否有2个以上怪兽区空位及青眼精灵龙是否在场，设置特殊召唤信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断怪兽区是否有1个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not e:GetHandler():IsPublic() end
	-- 设置特殊召唤2只手卡怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 执行特殊召唤这两只怪兽的操作，并加上水属性特召自肃
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(Card.IsRelateToChain,nil)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断怪兽区是否有足够的2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and fg:GetCount()==2 then
		-- 这张卡和观看的怪兽特殊召唤
		Duel.SpecialSummon(fg,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 将此回合不能特殊召唤水属性以外怪兽的誓约效果注册给玩家
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将誓约效果应用给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能特殊召唤水属性以外的怪兽
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤条件：判断场上是否存在表侧表示的「海」
function s.cfilter(c)
	return c:IsCode(22702055) and c:IsFaceup()
end
-- 只要自己场上有「海」存在
function s.econ(e)
	local tp=e:GetHandlerPlayer()
	-- 只要自己场上有「海」存在
	return Duel.IsEnvironment(22702055,tp)
		-- 判断场上是否存在特定卡名的「海」魔法卡
		or Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 自己场上的水属性连接怪兽
function s.tgtg(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_LINK)
end
