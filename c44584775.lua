--ダメージ＝レプトル
-- 效果：
-- 1回合1次，爬虫类族怪兽的战斗让自己受到战斗伤害时才能发动。把持有那个时候受到的伤害数值以下的攻击力的1只爬虫类族怪兽从卡组特殊召唤。
function c44584775.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，爬虫类族怪兽的战斗让自己受到战斗伤害时才能发动。把持有那个时候受到的伤害数值以下的攻击力的1只爬虫类族怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44584775,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c44584775.condition)
	e2:SetTarget(c44584775.target)
	e2:SetOperation(c44584775.activate)
	c:RegisterEffect(e2)
end
-- 判定效果发动条件：战斗伤害的承受者是自己（ep==tp），且参与战斗的怪兽中有爬虫类族（攻击怪兽或攻击对象为爬虫类）。
function c44584775.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前造成战斗伤害的战斗中攻击一侧的怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗中被攻击的怪兽；若无攻击对象（直接攻击）则为 nil。
	local d=Duel.GetAttackTarget()
	return ep==tp and (a:IsRace(RACE_REPTILE) or (d and d:IsRace(RACE_REPTILE)))
end
-- 定义卡组中可特殊召唤的候选怪兽条件：攻击力不大于所受伤害数值、是爬虫类族、且能被当前效果特殊召唤。
function c44584775.filter(c,e,tp,dam)
	return c:IsAttackBelow(dam) and c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动前合法性判定：确认己方主怪兽区有空格，且卡组中存在符合条件的爬虫类族怪兽，则效果可以发动。
function c44584775.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动判定（chk==0）时，检查己方主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少 1 张满足筛选条件的爬虫类族怪兽，作为发动前提。
		and Duel.IsExistingMatchingCard(c44584775.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ev) end
	-- 将本次连锁的操作信息登记为“从卡组特殊召唤 1 只怪兽”，以便相关卡牌和规则进行响应判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：若无空位则直接结束；否则提示玩家从卡组选择 1 只符合条件的爬虫类族怪兽，表侧表示特殊召唤到自己场上。
function c44584775.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认己方主要怪兽区有空位；若无空位则特殊召唤处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，要求玩家选择一张要特殊召唤的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中筛选并选择 1 张满足攻击力和种族条件的爬虫类族怪兽。
	local g=Duel.SelectMatchingCard(tp,c44584775.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ev)
	if g:GetCount()>0 then
		-- 把选择的怪兽以表侧表示特殊召唤到己方场上；不检查召唤条件、不进行苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
