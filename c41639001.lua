--聖刻龍－ドラゴンヌート
-- 效果：
-- 场上表侧表示存在的这张卡成为魔法·陷阱·效果怪兽的效果的对象时发动。从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤。这个效果1回合只能使用1次。
function c41639001.initial_effect(c)
	-- 场上表侧表示存在的这张卡成为魔法·陷阱·效果怪兽的效果的对象时发动。从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41639001,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_QUICK_F)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c41639001.spcon)
	e1:SetTarget(c41639001.sptg)
	e1:SetOperation(c41639001.spop)
	c:RegisterEffect(e1)
end
-- 判定发动条件：当前连锁的效果是否为取对象效果，且该效果的对象中是否包含此卡。
function c41639001.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得当前连锁中被选为对象的卡片组，用于检查此卡是否为对象。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(c)
end
-- 定义可特殊召唤的怪兽的过滤条件：必须是龙族的通常怪兽，且能被效果特殊召唤。
function c41639001.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标处理：本效果不取对象，允许发动并登记特殊召唤的操作信息。
function c41639001.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次效果将进行特殊召唤的操作信息，数量为1，检索范围为手卡·卡组·墓地（0x13），持有者为自己。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 效果处理：若我方主要怪兽区有空位，则从手卡·卡组·墓地选1只龙族的通常怪兽，将其攻击力·守备力变成0并以表侧攻击表示特殊召唤。
function c41639001.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果我方主要怪兽区没有可用的空格，则无法进行特殊召唤，直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·卡组·墓地中选出1只符合条件的龙族通常怪兽（过滤条件为spfilter，且不受王家长眠之谷等效果影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41639001.spfilter),tp,0x13,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的怪兽以表侧攻击表示进行特殊召唤（分步特殊召唤的第一阶段）。
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 攻击力·守备力变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤处理，使分步特殊召唤的怪兽正式登场。若召唤成功则留在场上。
	Duel.SpecialSummonComplete()
end
