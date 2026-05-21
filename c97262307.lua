--蕾禍ノ姫邪眼
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从手卡把1只昆虫族·植物族·爬虫类族怪兽特殊召唤。
-- ②：这张卡从手卡·墓地除外的场合才能发动。这个回合的结束阶段，自己抽出自己场上的昆虫族·植物族·爬虫类族怪兽的种族种类的数量。
local s,id,o=GetID()
-- 初始化函数，注册该卡片的效果①（手卡丢弃特召手卡昆虫/植物/爬虫类怪兽）与效果②（手卡/墓地除外时回合结束阶段依场上昆虫/植物/爬虫类种族数抽卡）
function s.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。从手卡把1只昆虫族·植物族·爬虫类族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·墓地除外的场合才能发动。这个回合的结束阶段，自己抽出自己场上的昆虫族·植物族·爬虫类族怪兽的种族种类的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.drcon)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价（Cost）函数，检查并执行将这张卡从手卡丢弃
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身从手卡丢弃送去墓地，作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤函数，筛选手卡中可以特殊召唤的昆虫族、植物族或爬虫类族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动目标（Target）函数，检查怪兽区域是否有空位以及手卡中是否存在可特召的对应种族怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在除自身以外、满足过滤条件的昆虫族·植物族·爬虫类族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 设置连锁处理中的操作信息为：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理（Operation）函数，从手卡选择1只昆虫族·植物族·爬虫类族怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的昆虫族·植物族·爬虫类族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件（Condition）函数，检查这张卡被除外前的原本位置是否是手卡或墓地
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果②的效果处理（Operation）函数，注册一个在回合结束阶段触发的延迟效果
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，自己抽出自己场上的昆虫族·植物族·爬虫类族怪兽的种族种类的数量。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.droperation)
	-- 将该回合结束阶段触发的延迟效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，筛选自己场上表侧表示的昆虫族、植物族或爬虫类族怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE)
end
-- 延迟效果的具体处理函数，计算自己场上昆虫族·植物族·爬虫类族怪兽的种族种类数量并抽对应数量的卡
function s.droperation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的昆虫族、植物族、爬虫类族怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local gc=g:GetClassCount(Card.GetRace)
	-- 向双方玩家展示发动效果的卡片
	Duel.Hint(HINT_CARD,0,id)
	-- 玩家因效果抽自身场上对应种族种类数量的卡
	Duel.Draw(tp,gc,REASON_EFFECT)
end
