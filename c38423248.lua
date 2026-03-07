--召喚獣マギストス・セリオン
-- 效果：
-- 「召唤师 阿莱斯特」＋融合·同调·超量·连接怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己墓地1只融合·同调·超量·连接怪兽和场上1只怪兽为对象才能发动。那些怪兽除外。
-- ②：融合召唤的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只魔法师族·4星怪兽特殊召唤。那之后，可以把这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤限制并注册两个诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为86120751的「召唤师 阿莱斯特」和1只融合·同调·超量·连接怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK),1,true,true)
	-- ①：这张卡特殊召唤的场合，以自己墓地1只融合·同调·超量·连接怪兽和场上1只怪兽为对象才能发动。那些怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：融合召唤的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只魔法师族·4星怪兽特殊召唤。那之后，可以把这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.material_type=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK
-- 除外效果的过滤函数，用于筛选墓地中的融合·同调·超量·连接怪兽
function s.rmfilter(c,tp)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		and c:IsAbleToRemove()
end
-- 除外效果的目标选择函数，检查是否满足选择条件
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否满足选择墓地融合·同调·超量·连接怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		-- 检查是否满足选择场上的怪兽的条件
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择墓地中的融合·同调·超量·连接怪兽作为除外对象
	local g1=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上的怪兽作为除外对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置除外效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
end
-- 除外效果的处理函数，将符合条件的卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	-- 筛选出与连锁相关的融合·同调·超量·连接怪兽
	local tg=g:Filter(aux.NecroValleyFilter(aux.AND(Card.IsRelateToChain,Card.IsType)),nil,TYPE_MONSTER)
	if tg:GetCount()>0 then
		-- 将符合条件的卡除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 特殊召唤效果的发动条件函数，判断是否为融合召唤且被破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 特殊召唤效果的过滤函数，用于筛选魔法师族4星怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标选择函数，检查是否满足选择条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足选择魔法师族4星怪兽的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足场上有特殊召唤空间的条件
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的处理函数，特殊召唤魔法师族4星怪兽并可装备
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查场上是否有特殊召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择魔法师族4星怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤操作
	if tc and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查场上是否有装备空间
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否满足装备条件
		and c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否装备？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 尝试将装备卡装备给目标怪兽
		if not Duel.Equip(tp,c,tc) then return end
		-- 设置装备卡的装备限制效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置装备卡的攻击力提升效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制效果的判断函数，确保只能装备给指定怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
