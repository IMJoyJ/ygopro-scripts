--魔道騎士ガイア
-- 效果：
-- 这个卡名在规则上也当作「暗黑骑士 盖亚」卡使用。这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合或者对方场上有攻击力2300以上的怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只龙族·5星怪兽守备表示特殊召唤。
function c34130561.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合或者对方场上有攻击力2300以上的怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34130561,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c34130561.ntcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只龙族·5星怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34130561,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,34130561)
	e2:SetTarget(c34130561.sptg)
	e2:SetOperation(c34130561.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤对方场上的表侧表示怪兽，判断其攻击力是否在2300以上，用于①效果中‘对方场上有攻击力2300以上的怪兽存在的场合’这一条件的判定。
function c34130561.ntfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2300)
end
-- ①效果的召唤规则条件：确认这张卡为5星以上，本次通常召唤无需解放（minc==0），自己主要怪兽区有空位，且满足自己场上无怪兽或对方场上有攻击力2300以上的表侧表示怪兽时，可以不解放作召唤。
function c34130561.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认本次召唤不需要通常召唤的解放（minc==0），且这张卡等级在5以上，同时自己主要怪兽区存在可用的空格，保证能够进行无解放召唤。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断条件中的或关系：要么自己场上没有怪兽（Duel.GetFieldGroupCount返回0），要么对方场上有至少1只攻击力2300以上的表侧表示怪兽（通过ntfilter过滤），二者满足其一即可。
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsExistingMatchingCard(c34130561.ntfilter,tp,0,LOCATION_MZONE,1,nil))
end
-- ②效果的选择过滤：从手卡·墓地中筛选出种族为龙族、等级为5星，并且能够以表侧守备表示进行特殊召唤的怪兽。
function c34130561.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动条件和目标设定：确认自己主要怪兽区有空位，并且手卡·墓地存在符合条件的龙族·5星怪兽；满足时登记特殊召唤的操作信息，作为后续效果处理依据。
function c34130561.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查（chk==0）：若自己主要怪兽区有空位，且手卡·墓地存在1只符合条件的龙族·5星怪兽，则允许发动并进入选择阶段。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c34130561.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本次效果处理中包含特殊召唤的操作信息：预定特殊召唤1只怪兽，来源为手卡·墓地，供神之警告、星尘龙等效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：若主要怪兽区有空位，则由玩家从手卡·墓地选择1只符合条件的龙族·5星怪兽，以表侧守备表示特殊召唤到自己的主要怪兽区。
function c34130561.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前的安全性检查：如果自己主要怪兽区没有可用的空格，则无法进行特殊召唤，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家发送选择提示，显示‘请选择要特殊召唤的卡’，并将HINTMSG_SPSUMMON写入选择缓存，用于选择卡片时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·墓地选择1只满足spfilter条件（龙族·5星且可守备表示特殊召唤）且不受王家长眠之谷影响的怪兽，作为特殊召唤对象；选择结果存入g。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c34130561.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的1只怪兽以表侧守备表示特殊召唤到自己场上，不进行召唤条件检查和苏生限制检查，完成②效果的处理。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
