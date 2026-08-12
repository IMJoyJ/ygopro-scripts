--サイキッカー・オラクル
-- 效果：
-- 念动力族怪兽＋同调·超量·连接怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡融合召唤时适用。这张卡的攻击力直到下个回合的结束时上升那些作为融合素材的同调·超量·连接怪兽数量×1000。
-- ②：对方把怪兽特殊召唤之际才能发动。那个无效，那些怪兽除外。
-- ③：融合召唤的这张卡被送去墓地的场合，从自己墓地把1张「瞬间移动」通常·速攻魔法卡除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤条件并注册三个效果
function s.initial_effect(c)
	-- 添加融合召唤手续，使用念动力族怪兽和同调·超量·连接怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHO),aux.FilterBoolFunction(Card.IsFusionType,TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK),true)
	-- 设置材料检查效果，用于记录融合素材类型并计算攻击力提升
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	-- 设置诱发即时效果②，对方特殊召唤怪兽时可发动，无效召唤并除外那些怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤无效"
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- 设置诱发选发效果③，融合召唤的这张卡被送去墓地时可发动，将1张「瞬间移动」除外并特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.material_type=TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK
-- 过滤函数，用于筛选融合素材中为同调·超量·连接类型的怪兽
function s.matfilter(c)
	return c:IsFusionType(TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 材料检查函数，统计融合素材中同调·超量·连接怪兽数量并提升攻击力
function s.matcheck(e,c)
	local g=c:GetMaterial():Filter(s.matfilter,nil)
	local atk=g:GetCount()
	-- 设置攻击力提升效果，提升值为融合素材数量×1000
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))  --"「念动力体先知」的效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetValue(atk*1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
	c:RegisterEffect(e1)
end
-- 判断效果②发动条件，确保是对方特殊召唤且当前无连锁处理
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方特殊召唤且当前无连锁处理时效果②可发动
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 设置效果②的发动时点目标，检查是否能除外对方怪兽
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能除外对方怪兽
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	-- 设置操作信息，标记将要无效召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息，标记将要除外怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
end
-- 执行效果②的操作，使召唤无效并除外怪兽
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使召唤无效
	Duel.NegateSummon(eg)
	-- 将怪兽除外
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end
-- 判断效果③发动条件，确认该卡是从场上送去墓地且为融合召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤函数，筛选墓地中的「瞬间移动」通常或速攻魔法卡
function s.cfilter(c)
	return (c:GetType()==TYPE_SPELL or c:IsType(TYPE_QUICKPLAY)) and c:IsSetCard(0x1cc) and c:IsAbleToRemoveAsCost()
end
-- 设置效果③的发动费用，从墓地选择1张「瞬间移动」除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能除外1张「瞬间移动」作为费用
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张「瞬间移动」除外
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果③的发动时点目标，检查是否能特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，标记将要特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果③的操作，将该卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否与当前连锁相关且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
