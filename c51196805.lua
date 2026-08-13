--ゴーストリック・スケルトン
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，这张卡反转时，把最多有自己场上的名字带有「鬼计」的怪兽数量的卡从对方卡组上面里侧表示除外。「鬼计骷髅」的这个效果1回合只能使用1次。
function c51196805.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c51196805.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51196805,0))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c51196805.postg)
	e2:SetOperation(c51196805.posop)
	c:RegisterEffect(e2)
	-- 此外，这张卡反转时，把最多有自己场上的名字带有「鬼计」的怪兽数量的卡从对方卡组上面里侧表示除外。「鬼计骷髅」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51196805,1))  --"里侧除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCountLimit(1,51196805)
	e3:SetCode(EVENT_FLIP)
	e3:SetTarget(c51196805.rmtg)
	e3:SetOperation(c51196805.rmop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片是否为表侧表示且字段为「鬼计」（0x8d），用于后续检查场上存在的「鬼计」怪兽。
function c51196805.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制的条件函数：当自己场上不存在任何表侧表示的「鬼计」怪兽时返回 true，使通常召唤被禁止；即只有存在「鬼计」怪兽的场合才能将这张卡表侧表示召唤。
function c51196805.sumcon(e)
	-- 检查自己场上是否存在至少 1 张满足 sfilter 过滤条件的「鬼计」怪兽，若不存在则结果为 true（触发不能召唤的限制）。
	return not Duel.IsExistingMatchingCard(c51196805.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 变成里侧守备的起动效果的发动条件与登记处理：条件检查时，要求自身可以变为里侧守备且本回合尚未发动过该效果（flag为0）；通过后为自身注册1回合1次的标识，并将操作信息设置为改变表示形式。
function c51196805.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(51196805)==0 end
	c:RegisterFlagEffect(51196805,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 将操作信息登记为：以这张卡为对象、数量1、改变表示形式（CATEGORY_POSITION），供规则检测及连锁后处理使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理时的操作函数：若这张卡仍在场上且与效果关联、并处于表侧表示，则将其变成里侧守备表示。
function c51196805.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 实际执行表示形式变更：把这张卡变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 反转时的诱发效果的目标函数：该效果为反转时必发效果，发动条件恒成立（chk==0返回true）；设置操作信息表示从对方卡组除外卡片。
function c51196805.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次操作信息登记为除外（CATEGORY_REMOVE），目标位置为对方卡组（1-tp），数量在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
-- 反转除外效果的结算操作：先计算可除外的上限——自己场上表侧表示的「鬼计」怪兽数量与对方卡组剩余卡数的最小值；若上限为 0 则直接结束，否则生成 1 到上限的可选数字列表，供玩家选择实际除外的数量。
function c51196805.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上表侧表示且字段为「鬼计」的怪兽数量，作为可除外张数的上限之一。
	local ct1=Duel.GetMatchingGroupCount(c51196805.sfilter,tp,LOCATION_MZONE,0,nil)
	-- 计算对方卡组当前剩余的卡片数量，防止除外数量超过对方卡组张数。
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if ct1>ct2 then ct1=ct2 end
	if ct1==0 then return end
	local t={}
	for i=1,ct1 do t[i]=i end
	-- 向操作玩家显示选择消息，提示其从可选数量中选择要除外的卡片数量。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(51196805,2))  --"请选择要除外的卡的数量"
	-- 让玩家从可选数字中宣言一个数，作为实际从对方卡组顶部里侧表示除外的卡片数。
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 从对方卡组最上方取出 ac 张卡，作为即将除外的对象。
	local g=Duel.GetDecktopGroup(1-tp,ac)
	-- 禁用系统自动洗牌检查：因为这些卡是从卡组顶端取出并除外，卡组剩余卡顺序不变，无需洗切。
	Duel.DisableShuffleCheck()
	-- 将取出的卡以里侧表示除外，除外原因为效果（REASON_EFFECT）。
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
