--聖刻龍－ドラゴンヌート
-- 效果：
-- 场上表侧表示存在的这张卡成为魔法·陷阱·效果怪兽的效果的对象时发动。从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤。这个效果1回合只能使用1次。
function c41639001.initial_effect(c)
	-- 创建一个诱发即时必发效果，效果描述为“特殊召唤”，类型为快速效果，分类为特殊召唤，属性为伤害步骤可发动，触发事件为连锁发动，发动位置为怪兽区域，限制每回合只能发动一次，条件为c41639001.spcon，目标为c41639001.sptg，效果处理为c41639001.spop
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
-- 当连锁的发动效果具有取对象属性且该效果的对象包含此卡时，满足发动条件
function c41639001.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(c)
end
-- 过滤条件：满足通常怪兽、龙族且可以特殊召唤的卡片
function c41639001.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时要特殊召唤1只怪兽，对象为玩家自己，位置为手卡·卡组·墓地
function c41639001.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为特殊召唤1只怪兽，对象为玩家自己，位置为手卡·卡组·墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 若场上没有空位则不发动；提示玩家选择要特殊召唤的卡，从手卡·卡组·墓地选择1只龙族通常怪兽，特殊召唤之，并将该怪兽攻击力和守备力设为0
function c41639001.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若玩家场上没有空位则不发动
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择1只满足条件的龙族通常怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41639001.spfilter),tp,0x13,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 特殊召唤该怪兽，若成功则继续设置其攻击力和守备力为0
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 设置该怪兽的攻击力为0
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
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
