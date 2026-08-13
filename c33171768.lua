--サイキッカー・オラクル
-- 效果：
-- 念动力族怪兽＋同调·超量·连接怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡融合召唤时适用。这张卡的攻击力直到下个回合的结束时上升那些作为融合素材的同调·超量·连接怪兽数量×1000。
-- ②：对方把怪兽特殊召唤之际才能发动。那个无效，那些怪兽除外。
-- ③：融合召唤的这张卡被送去墓地的场合，从自己墓地把1张「瞬间移动」通常·速攻魔法卡除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果：添加融合素材条件（念动力族怪兽＋同调·超量·连接怪兽）；注册素材检查效果（用于①攻击力上升）、②无效对方特殊召唤并除外、③除外「瞬间移动」从墓地特殊召唤自身。
function s.initial_effect(c)
	-- 为这张卡添加融合召唤手续：以念动力族怪兽1只与同调·超量·连接怪兽1只作为融合素材。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHO),aux.FilterBoolFunction(Card.IsFusionType,TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK),true)
	-- ①：这张卡融合召唤时适用。这张卡的攻击力直到下个回合的结束时上升那些作为融合素材的同调·超量·连接怪兽数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合各能使用1次。②：对方把怪兽特殊召唤之际才能发动。那个无效，那些怪兽除外。
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
	-- 这个卡名的③的效果1回合各能使用1次。③：融合召唤的这张卡被送去墓地的场合，从自己墓地把1张「瞬间移动」通常·速攻魔法卡除外才能发动。这张卡特殊召唤。
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
-- 定义过滤器：筛选融合素材中属于同调·超量·连接怪兽的卡。
function s.matfilter(c)
	return c:IsFusionType(TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 素材检查处理：统计实际融合素材中同调·超量·连接怪兽数量，为这张卡生成攻击力上升（数量×1000）的效果，持续到下个回合结束。
function s.matcheck(e,c)
	local g=c:GetMaterial():Filter(s.matfilter,nil)
	local atk=g:GetCount()
	-- ①：这张卡融合召唤时适用。这张卡的攻击力直到下个回合的结束时上升那些作为融合素材的同调·超量·连接怪兽数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))  --"「念动力体先知」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetValue(atk*1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
	c:RegisterEffect(e1)
end
-- ②的发动条件：对方把怪兽特殊召唤之际，且当前不在连锁处理中（即直接连锁该特殊召唤）。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定：发动者为对方（tp~=ep）且当前连锁数为0，满足特殊召唤之际的插入时点。
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- ②发动时点：确认可以除外后，将操作信息登记为无效那次特殊召唤并除外那些怪兽。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：当前玩家是否能够进行除外操作。
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	-- 登记操作信息：本次效果包含‘无效那次特殊召唤’，对象为被特殊召唤的怪兽群。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 登记操作信息：本次效果包含‘除外’，对象为那些怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
end
-- ②效果处理：使那次特殊召唤无效，并将那些怪兽表侧表示除外。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效eg这组怪兽的特殊召唤。
	Duel.NegateSummon(eg)
	-- 将eg中的怪兽以表侧表示形式除外。
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end
-- ③的发动条件：这张卡曾以融合召唤方式从场上被送去墓地（不是从手牌/卡组直接送墓）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 定义③代价的过滤条件：从自己墓地选择1张卡名属于「瞬间移动」的通常魔法卡或速攻魔法卡，且可作为除外代价。
function s.cfilter(c)
	return (c:GetType()==TYPE_SPELL or c:IsType(TYPE_QUICKPLAY)) and c:IsSetCard(0x1cc) and c:IsAbleToRemoveAsCost()
end
-- ③的发动代价：从自己墓地选择并除外1张符合条件的「瞬间移动」通常·速攻魔法卡。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己墓地是否存在至少1张符合条件的「瞬间移动」通常·速攻魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 显示选择提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张符合条件的「瞬间移动」通常·速攻魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将所选的卡以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③发动时点：确认自己主要怪兽区域有空位，且这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区的可用空格数是否大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次效果将特殊召唤这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果处理：在这张卡仍与连锁相关且不受墓地效果限制时，将其特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定这张卡仍与本次连锁关联，且不受王家长眠之谷等影响，可以特殊召唤。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
