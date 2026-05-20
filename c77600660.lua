--サイコ・エンペラー
-- 效果：
-- 这张卡召唤·特殊召唤成功时，自己墓地存在的念动力族怪兽每有1只，自己回复500基本分。
function c77600660.initial_effect(c)
	-- 这张卡召唤成功时，自己墓地存在的念动力族怪兽每有1只，自己回复500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77600660,0))  --"LP回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(c77600660.rectg)
	e1:SetOperation(c77600660.recop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 定义效果发动的目标过滤与操作信息设置函数
function c77600660.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算自己墓地中念动力族怪兽的数量并乘以500，作为回复的数值
	local val=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_PSYCHO)*500
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为计算出的回复数值
	Duel.SetTargetParam(val)
	-- 设置操作信息为：玩家tp回复val数值的生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
end
-- 定义效果处理的执行函数
function c77600660.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新计算自己墓地中念动力族怪兽的数量并乘以500
	local val=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_PSYCHO)*500
	-- 获取当前连锁设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 以效果原因使目标玩家回复计算出的生命值
	Duel.Recover(p,val,REASON_EFFECT)
end
