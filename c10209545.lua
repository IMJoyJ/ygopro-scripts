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
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c10209545.hdcon)
	e2:SetTarget(c10209545.hdtg)
	e2:SetOperation(c10209545.hdop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数，用于检查卡片是否为「僵尸虎」且可以被特殊召唤
function c10209545.filter(c,e,tp)
	return c:IsCode(47693640) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义特殊召唤效果的目标函数，用于检查发动条件和选择对象
function c10209545.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的「僵尸虎」可以特殊召唤
		and Duel.IsExistingMatchingCard(c10209545.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，声明此效果将处理特殊召唤，目标数量为1，来自手牌
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义特殊召唤效果的处理函数，执行实际的特殊召唤操作
function c10209545.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查如果没有可用的怪兽区域空格则终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 让玩家从手牌中选择1张满足条件的「僵尸虎」
	local g=Duel.SelectMatchingCard(tp,c10209545.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「僵尸虎」以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义手牌丢弃效果的条件函数，检查是否为直接攻击造成的伤害
function c10209545.hdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查受到伤害的是对方玩家且此次攻击为直接攻击（没有攻击对象）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 定义手牌丢弃效果的目标函数，设置操作信息
function c10209545.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，声明此效果将处理手牌丢弃，目标为对方玩家1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 定义手牌丢弃效果的处理函数，执行实际的丢弃操作
function c10209545.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方玩家手牌区域的所有卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选择的1张对方手牌以丢弃方式送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
