--超重蒸鬼テツドウ－O
-- 效果：
-- 「超重武者」调整＋调整以外的「超重武者」怪兽2只以上
-- 这个卡名在规则上也当作「超重武者」卡使用。
-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ②：1回合1次，把最多2张手卡丢弃，以丢弃数量的对方场上的卡为对象才能发动。那些卡破坏。
-- ③：1回合1次，自己主要阶段才能发动。双方墓地的魔法·陷阱卡全部除外，给与对方除外数量×200伤害。
function c17775525.initial_effect(c)
	-- 设定同调召唤条件：以1只「超重武者」调整为素材，加上2只以上调整以外的「超重武者」怪兽作为同调素材。
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
-- ②效果的代价处理：先检查手牌是否有可丢弃的卡，再根据对方场上卡数决定最多丢弃张数（上限2），然后让玩家丢弃1至rt张手牌作为代价，并将丢弃结果记录到效果e中。
function c17775525.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方手牌是否存在至少1张可以丢弃的卡，若不存在则代价不合法，不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 统计对方场上可以作为效果对象的卡的数量，用于决定最多能丢弃几张手牌（因为对象数量等于丢弃数）。
	local rt=Duel.GetTargetCount(nil,tp,0,LOCATION_ONFIELD,nil)
	if rt>2 then rt=2 end
	-- 玩家选择并丢弃1到rt张可丢弃的手牌作为代价（理由为COST和DISCARD），返回被丢弃的卡组并记录在e中。
	local cg=Duel.DiscardHand(tp,Card.IsDiscardable,1,rt,REASON_COST+REASON_DISCARD,nil)
	e:SetLabel(cg)
end
-- ②效果的取对象处理函数：根据代价丢弃的卡数，选择对方场上相同数量的卡作为对象，并设置破坏的操作信息。
function c17775525.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张可以作为对象的卡；若没有则不满足发动条件。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 向玩家显示选择提示，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择ct张卡（ct为代价丢弃的张数）作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 写入操作信息：本次连锁将破坏g中的ct张卡，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- ②效果的解决处理函数：取得连锁对象，筛选出仍与效果关联的卡，并破坏它们。
function c17775525.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理时记录的对象卡组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount()>0 then
		-- 将对象中仍然与效果相关的卡破坏，破坏原因为效果。
		Duel.Destroy(rg,REASON_EFFECT)
	end
end
-- 筛选函数：判断一张卡是否为魔法·陷阱卡且可以被除外（用于③效果）。
function c17775525.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- ③效果的发动条件和操作信息设置函数：检查双方墓地存在可除外的魔法陷阱，并预先登记除外与伤害信息。
function c17775525.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方墓地是否存在至少1张可除外的魔法陷阱卡；若没有则不满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c17775525.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 取得双方墓地所有满足筛选条件的魔法陷阱卡。
	local g=Duel.GetMatchingGroup(c17775525.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 写入操作信息：本次连锁将除外g中的全部卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	-- 写入操作信息：本次连锁将给对方造成数量×200的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*200)
end
-- ③效果的解决处理函数：实际除外双方墓地的魔法陷阱，并按除外数量造成伤害。
function c17775525.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次取得当前双方墓地中满足条件的魔法陷阱卡（处理时可能发生变化）。
	local g=Duel.GetMatchingGroup(c17775525.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 将这些魔法陷阱卡表侧除外，并得到实际除外的数量ct。
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if ct>0 then
		-- 若除外数量大于0，则给对方玩家造成ct×200的效果伤害。
		Duel.Damage(1-tp,ct*200,REASON_EFFECT)
	end
end
