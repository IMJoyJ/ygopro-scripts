--プラズマ戦士エイトム
-- 效果：
-- 这个卡名在规则上也当作「磁石战士」卡使用。这张卡不能通常召唤。「等离子战士 原子八雷王」1回合1次在把自己场上1只7星以上的怪兽解放的场合才能从手卡·墓地特殊召唤。
-- ①：1回合1次，把除「等离子战士 原子八雷王」外的1只「磁石战士」怪兽从卡组送去墓地才能发动。这个回合，这张卡的原本攻击力变成1500，可以直接攻击。
local s,id,o=GetID()
-- 初始化卡片效果：注册不能通常召唤的特殊召唤限制、从手卡·墓地解放自己场上1只7星以上怪兽来特殊召唤的规则效果（1回合1次），以及起动效果①（从卡组把1只「磁石战士」怪兽送去墓地，使这张卡原本攻击力变成1500并可直接攻击）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	-- 「等离子战士 原子八雷王」1回合1次在把自己场上1只7星以上的怪兽解放的场合才能从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把除「等离子战士 原子八雷王」外的1只「磁石战士」怪兽从卡组送去墓地才能发动。这个回合，这张卡的原本攻击力变成1500，可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"直接攻击"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.datcost)
	e2:SetTarget(s.dattg)
	e2:SetOperation(s.datop)
	c:RegisterEffect(e2)
end
-- 可解放怪兽的过滤条件：等级7以上，且该怪兽离场后自己场上仍有可用的怪兽区域
function s.cfilter(c,tp)
	return c:IsLevelAbove(7)
		-- 检查该怪兽离开后，自己场上是否还有可用的主要怪兽区域（避免解放后因无空格无法特殊召唤）
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤条件：确认自己场上存在1只以上满足条件的可解放怪兽（c为nil时仅进行条件检查，直接返回true）
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只7星以上且离场后仍有空怪兽区的可解放怪兽（作为特殊召唤手续）
	return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤的目标选择：从自己场上可解放的怪兽中筛选7星以上的，让玩家选择1只要解放的怪兽并记录下来；取消选择则特殊召唤不成立
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己场上可解放的卡组，并筛选出等级7以上且离场后仍有空怪兽区的怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.cfilter,nil,tp)
	-- 向玩家提示「请选择要解放的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的处理：取出之前选择的怪兽并将其解放，完成这张卡的特殊召唤手续
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rc=e:GetLabelObject()
	-- 以特殊召唤为由解放选中的那只怪兽
	Duel.Release(rc,REASON_SPSUMMON)
end
-- 代价的过滤条件：「磁石战士」系列怪兽、不是「等离子战士 原子八雷王」本身、且能作为代价送去墓地
function s.costfilter(c)
	return c:IsSetCard(0xe9,0x2066) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToGraveAsCost()
end
-- 效果①的代价：确认卡组存在满足条件的怪兽后，让玩家从卡组选择1只送去墓地作为发动代价
function s.datcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动前的检查：卡组中是否存在至少1只可作为代价送去墓地的满足条件的「磁石战士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家提示「请选择要送去墓地的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组选择1只满足条件的「磁石战士」怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的发动条件检查：仅当这张卡的原本攻击力不是1500或尚未获得直接攻击能力时才能发动（避免重复发动）
function s.dattg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetBaseAttack()~=1500 or not c:IsHasEffect(EFFECT_DIRECT_ATTACK) end
end
-- 效果①的处理：这张卡在场上表侧表示存在且与连锁关联的场合，注册两个持续到这个回合结束的效果——原本攻击力变成1500、可以直接攻击
function s.datop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		-- 这个回合，这张卡的原本攻击力变成1500，
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 可以直接攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
