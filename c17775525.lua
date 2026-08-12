--超重蒸鬼テツドウ－O
-- 效果：
-- 「超重武者」调整＋调整以外的「超重武者」怪兽2只以上
-- 这个卡名在规则上也当作「超重武者」卡使用。
-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ②：1回合1次，把最多2张手卡丢弃，以丢弃数量的对方场上的卡为对象才能发动。那些卡破坏。
-- ③：1回合1次，自己主要阶段才能发动。双方墓地的魔法·陷阱卡全部除外，给与对方除外数量×200伤害。
function c17775525.initial_effect(c)
	-- 添加同调召唤手续，需要1只调整（超重武者）和2只以上调整以外的超重武者怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x9a),aux.NonTuner(Card.IsSetCard,0x9a),2)
	c:EnableReviveLimit()
	-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把最多2张手卡丢弃，以丢弃数量的对方场上的卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17775525,0))  --"卡片破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c17775525.cost)
	e2:SetTarget(c17775525.target)
	e2:SetOperation(c17775525.operation)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己主要阶段才能发动。双方墓地的魔法·陷阱卡全部除外，给与对方除外数量×200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17775525,1))  --"魔陷除外"
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c17775525.rmtg)
	e3:SetOperation(c17775525.rmop)
	c:RegisterEffect(e3)
end
-- 检查玩家手牌是否存在可丢弃的卡，计算最多可丢弃的卡数并执行丢弃操作
function c17775525.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 获取对方场上满足条件的卡的数量
	local rt=Duel.GetTargetCount(nil,tp,0,LOCATION_ONFIELD,nil)
	if rt>2 then rt=2 end
	-- 执行丢弃手牌操作，丢弃1~2张手牌
	local cg=Duel.DiscardHand(tp,Card.IsDiscardable,1,rt,REASON_COST+REASON_DISCARD,nil)
	e:SetLabel(cg)
end
-- 设置效果目标，选择对方场上的卡作为破坏对象
function c17775525.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查是否存在对方场上的卡可作为目标
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置效果操作信息，确定破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 执行效果操作，破坏选定的卡
function c17775525.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount()>0 then
		-- 破坏目标卡组中的卡
		Duel.Destroy(rg,REASON_EFFECT)
	end
end
-- 定义过滤函数，筛选墓地中的魔法或陷阱卡
function c17775525.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 设置效果目标，检索双方墓地中的魔法或陷阱卡
function c17775525.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在双方墓地中的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c17775525.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 获取双方墓地中的魔法或陷阱卡
	local g=Duel.GetMatchingGroup(c17775525.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 设置效果操作信息，确定除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	-- 设置效果操作信息，确定给予的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*200)
end
-- 执行效果操作，除外双方墓地中的魔法或陷阱卡并造成伤害
function c17775525.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方墓地中的魔法或陷阱卡
	local g=Duel.GetMatchingGroup(c17775525.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 除外选定的卡
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if ct>0 then
		-- 给与对方相应数量×200的伤害
		Duel.Damage(1-tp,ct*200,REASON_EFFECT)
	end
end
