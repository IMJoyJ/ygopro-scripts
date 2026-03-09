--殺戮聖徒レジーナ
-- 效果：
-- 幻想魔族怪兽＋6星以上的恶魔族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「杀戮圣徒 梦王鸦女」以外的自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：「杀戮圣徒 梦王鸦女」以外的「蓟花」卡或「罪宝」卡的效果发动时，以场上最多2张卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 初始化效果函数，设置融合召唤条件并注册两个效果
function s.initial_effect(c)
	-- 添加融合召唤手续，使用一张幻想魔族怪兽和一张6星以上恶魔族怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ILLUSION),s.mfilter,true)
	c:EnableReviveLimit()
	-- 设置效果①：墓地特殊召唤效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"墓地特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 设置效果②：破坏效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤函数，判断是否为6星以上恶魔族怪兽
function s.mfilter(c)
	return c:IsLevelAbove(6) and c:IsRace(RACE_FIEND)
end
-- 特殊召唤过滤函数，排除自身并满足幻想魔族且可特殊召唤的条件
function s.spfilter(c,e,tp)
	return not c:IsCode(id)
		and c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件判定函数，用于判断是否可以发动效果
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在符合条件的幻想魔族怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡片，从自己墓地选择一只符合条件的幻想魔族怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理函数，执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡片是否仍然存在于场上且未受王家长眠之谷影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件判定函数，判断是否为「蓟花」或「罪宝」卡的效果发动
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not re:GetHandler():IsCode(id) and re:GetHandler():IsSetCard(0x1bc,0x19e)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果②的发动条件判定函数，用于判断是否可以发动效果
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) end
	-- 判断场上是否存在至少一张可破坏的卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标卡片，从场上选择最多两张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置操作信息，确定将要破坏的卡数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的处理函数，执行破坏操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡片破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
