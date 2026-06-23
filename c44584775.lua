--ダメージ＝レプトル
-- 效果：
-- 1回合1次，爬虫类族怪兽的战斗让自己受到战斗伤害时才能发动。把持有那个时候受到的伤害数值以下的攻击力的1只爬虫类族怪兽从卡组特殊召唤。
function c44584775.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发选发效果，对应一速的【……才能发动】
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
-- 爬虫类族怪兽的战斗让自己受到战斗伤害时才能发动
function c44584775.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	return ep==tp and (a:IsRace(RACE_REPTILE) or (d and d:IsRace(RACE_REPTILE)))
end
-- 过滤满足攻击力以下且为爬虫类族且可特殊召唤的卡
function c44584775.filter(c,e,tp,dam)
	return c:IsAttackBelow(dam) and c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件
function c44584775.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(c44584775.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ev) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤操作
function c44584775.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只爬虫类族怪兽
	local g=Duel.SelectMatchingCard(tp,c44584775.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ev)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
