--夢蝉スイミンミン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有攻击表示的昆虫族怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
local s,id,o=GetID()
-- 创建并注册效果：e1为①的特殊召唤规则效果，e2为②的召唤成功时发动的诱发效果，e3为e2的克隆并改为特殊召唤成功时发动。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有攻击表示的昆虫族怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤成功的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断怪兽是否为攻击表示且为昆虫族，用于①条件中“攻击表示的昆虫族怪兽”的筛选。
function s.cfilter(c)
	return c:IsAttackPos() and c:IsRace(RACE_INSECT)
end
-- ①特殊召唤规则效果的条件：若c为空（规则召唤判定）则直接允许；否则需自己场上有空余怪兽区域，且存在攻击表示的昆虫族怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己的主要怪兽区域是否有空格，确保特殊召唤有可用区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张满足攻击表示且昆虫族条件的怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动条件和发动时操作：先检查能否选择场上可变更表示形式的怪兽，若能则提示选择并选定1只怪兽作为对象，同时设置操作信息为变更表示形式。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	-- 在效果发动时检查是否存在至少1只场上可以变更表示形式的怪兽，作为发动条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，提示玩家选择要变更表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择场上1只可以变更表示形式的怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的操作信息：效果分类为变更表示形式，对象为选中的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果处理时的操作：获取效果对象，若对象仍与该效果关联，则变更其表示形式。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一个效果对象（即选择的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 根据怪兽当前表示形式进行变更：表侧攻击表示变为表侧守备表示，其他表示形式均变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
