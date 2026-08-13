--鉄獣の炎工 キット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「铁兽炎工 姬特」以外的，「铁兽」怪兽或「护宝炮妖」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。除「铁兽炎工 姬特」外的以下怪兽之内1只从自己墓地守备表示特殊召唤。
-- ●「铁兽」怪兽
-- ●「护宝炮妖」怪兽
-- ●「阿不思的落胤」或者有那个卡名记述的怪兽
local s,id,o=GetID()
-- 初始化此卡效果：注册①从手卡特殊召唤的起动效果和②被送去墓地时从自己墓地特殊召唤的诱发效果，两个效果同名卡1回合各能用1次。
function s.initial_effect(c)
	-- 登记卡名：将卡号68468459（阿不思的落胤）记入此卡的记述卡名，使此卡也被视为“有阿不思的落胤卡名记述的怪兽”。
	aux.AddCodeList(c,68468459)
	-- ①：自己场上有「铁兽炎工 姬特」以外的，「铁兽」怪兽或「护宝炮妖」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。除「铁兽炎工 姬特」外的以下怪兽之内1只从自己墓地守备表示特殊召唤。●「铁兽」怪兽 ●「护宝炮妖」怪兽 ●「阿不思的落胤」或者有那个卡名记述的怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 定义①效果的过滤条件：怪兽需属于「铁兽」或「护宝炮妖」系列、表侧表示且卡名不是「铁兽炎工 姬特」。
function s.cfilter(c)
	return c:IsSetCard(0x14d,0x155) and c:IsFaceup() and not c:IsCode(id)
end
-- ①效果的发动条件：自己场上存在至少1只满足s.cfilter的怪兽（「铁兽」或「护宝炮妖」表侧怪兽且非此卡自身）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己场上是否存在满足条件的表侧「铁兽」/「护宝炮妖」怪兽（非此卡自身）。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动合法性检测：自己主要怪兽区域有空位，且此卡自身可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：此效果要把这张卡自身特殊召唤，数量为1，供连锁处理时判定（如星尘龙等）使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若此卡仍与当前连锁相关，则将其以表侧攻击表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 执行特殊召唤：将此卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果选择墓地怪兽的过滤条件：不是此卡自身，属于「铁兽」或「护宝炮妖」系列，或是「阿不思的落胤」或有该卡名记述的怪兽，且可以表侧守备表示特殊召唤。
function s.spfilter(c,e,tp)
	return not c:IsCode(id)
		-- 筛选条件：目标属于「铁兽」/「护宝炮妖」系列，或是「阿不思的落胤」或者有那个卡名记述的怪兽。
		and (c:IsSetCard(0x14d,0x155) or aux.IsCodeOrListed(c,68468459))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果发动合法性检查：自己主要怪兽区域有空位，且自己墓地存在满足s.spfilter条件的怪兽（可供特殊召唤）。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张满足s.spfilter的怪兽作为特殊召唤候选。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将不取对象地从自己墓地特殊召唤1只怪兽，目标在效果处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：若场上空格足够，则从自己墓地选择1只符合条件且不受王家长眠之谷影响的怪兽，以表侧守备表示特殊召唤到自己场上。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的主要怪兽区域空格，则结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送选择提示消息，要求玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家在自己墓地选择1张满足过滤条件且不受王家长眠之谷影响的怪兽卡作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
