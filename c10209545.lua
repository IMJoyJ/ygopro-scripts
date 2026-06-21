--朽ち果てた武将
-- 效果：
-- 这张卡召唤成功时，可以从手卡特殊召唤1只「僵尸虎」。这张卡对对方直接攻击成功时，对方随机丢弃1张手卡。
function c10209545.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡特殊召唤1只「僵尸虎」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10209545,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c10209545.sptg)
	e1:SetOperation(c10209545.spop)
	c:RegisterEffect(e1)
	-- 这张卡对对方直接攻击成功时，对方随机丢弃1张手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10209545,1))  --"手牌丢弃"
	e2:SetCategory(CATEGORY_HANDES_OPPO)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c10209545.hdcon)
	e2:SetTarget(c10209545.hdtg)
	e2:SetOperation(c10209545.hdop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中卡名为「僵尸虎」且可以特殊召唤的怪兽
function c10209545.filter(c,e,tp)
	return c:IsCode(47693640) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的检测，确认怪兽区域有空位且手牌有可特殊召唤的「僵尸虎」
function c10209545.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上是否有可用于特殊召唤怪兽的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测手牌中是否存在至少1张可特殊召唤的「僵尸虎」
		and Duel.IsExistingMatchingCard(c10209545.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的效果分类为特殊召唤，操作的卡片在手牌，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的具体处理，从手牌选择并特殊召唤「僵尸虎」
function c10209545.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若怪兽区域已无可用空格，则直接返回不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张满足特殊召唤条件的「僵尸虎」
	local g=Duel.SelectMatchingCard(tp,c10209545.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 丢弃对方手牌效果的发动条件判定（直接攻击对对方造成战斗伤害时）
function c10209545.hdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认是直接攻击对对方造成战斗伤害
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 丢弃对方手牌效果的检测与效果分类设置
function c10209545.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置丢弃对方手牌的操作信息，涉及对方的1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,0,0,1-tp,1)
end
-- 丢弃对方手牌效果的具体处理，对方随机选择1张手牌丢弃
function c10209545.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方玩家的所有手牌
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 以效果丢弃的原因将选中的手牌送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
