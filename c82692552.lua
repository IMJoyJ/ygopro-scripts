--耀爛竜コラリアネクテス
local s,id,o=GetID()
-- 初始化卡片效果：注册记述卡号「海」、①加入手牌特召自身与手牌水属性怪兽效果、②在有「海」存在时赋予水属性连接怪兽取对象抗性效果
function s.initial_effect(c)
	-- 注册关联卡号列表：包含卡号22702055（海）
	aux.AddCodeList(c,22702055)
	-- ①：抽牌以外的场合这张卡加入手牌的场合，把手牌1只水属性怪兽给对方确认才能发动。这张卡和确认的怪兽特殊召唤。
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
	-- ②：场上有「海」存在的场合，自己场上的水属性连接怪兽不会成为对方效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.econ)
	e2:SetTarget(s.tgtg)
	-- 设置卡片不会成为对方效果对象的通用判定函数
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- ①效果发动条件：此卡不是通过抽牌加入手牌
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- Cost展示及特召目标过滤条件：手牌中未公开的水属性怪兽且可特殊召唤
function s.costfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动Cost：选择手牌中1只满足条件的水属性怪兽给对方确认
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- Cost检查：手牌中是否存在除自身外可展示并特召的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌选择1只满足条件的水属性怪兽
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c,e,tp):GetFirst()
	-- 向对方玩家展示选中的怪兽卡
	Duel.ConfirmCards(1-tp,sc)
	-- 重新洗切手牌
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- ①效果发动准备：检查青眼精灵龙限制与怪兽区空位，设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not e:GetHandler():IsPublic() end
	-- 设置连锁操作信息：从手牌特殊召唤2张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- ①效果处理：将此卡与展示的水属性怪兽特殊召唤，并给予非水属性怪兽特召限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(Card.IsRelateToChain,nil)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 效果处理时确认怪兽区域仍有至少2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and fg:GetCount()==2 then
		-- 将自身与展示的怪兽表侧表示特殊召唤
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
	-- 给玩家注册直到回合结束时生效的特召限制誓约
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制过滤条件：限制只能特殊召唤水属性怪兽
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 「海」卡名存在检查过滤条件：卡名为22702055（海）且表侧表示
function s.cfilter(c)
	return c:IsCode(22702055) and c:IsFaceup()
end
-- ②效果生效条件：场地处于「海」环境或场上存在表侧表示的「海」
function s.econ(e)
	local tp=e:GetHandlerPlayer()
	-- 检查场地是否为「海」环境（包含视作「海」的场地卡）
	return Duel.IsEnvironment(22702055,tp)
		-- 检查自己场上是否存在表侧表示的卡名为「海」的卡
		or Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 抗性适用目标过滤条件：水属性的连接怪兽
function s.tgtg(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_LINK)
end
