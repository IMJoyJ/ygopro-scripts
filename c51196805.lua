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
	-- 此外，这张卡反转时，把最多有自己场上的名字带有「鬼计」的怪兽数量的卡从对方卡组上面里侧表示除外。
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
-- 检索满足条件的「鬼计」怪兽（名字带有鬼计的怪兽）
function c51196805.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 判断是否满足召唤条件（自己场上没有名字带有鬼计的怪兽）
function c51196805.sumcon(e)
	-- 当自己场上不存在名字带有鬼计的怪兽时，该卡不能被召唤
	return not Duel.IsExistingMatchingCard(c51196805.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 设置里侧守备表示效果的发动条件和处理函数
function c51196805.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(51196805)==0 end
	c:RegisterFlagEffect(51196805,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁操作信息：改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 执行里侧守备表示的效果处理
function c51196805.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 设置反转时除外卡牌效果的发动条件和处理函数
function c51196805.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：除外效果
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
-- 执行反转时除外卡牌的效果处理
function c51196805.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上名字带有鬼计的怪兽数量
	local ct1=Duel.GetMatchingGroupCount(c51196805.sfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取对方卡组顶部的卡的数量
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if ct1>ct2 then ct1=ct2 end
	if ct1==0 then return end
	local t={}
	for i=1,ct1 do t[i]=i end
	-- 提示玩家选择要除外的卡的数量
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(51196805,2))  --"请选择要除外的卡的数量"
	-- 让玩家宣言要除外的卡的数量
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 获取对方卡组最上方指定数量的卡
	local g=Duel.GetDecktopGroup(1-tp,ac)
	-- 禁止后续操作自动洗切卡组
	Duel.DisableShuffleCheck()
	-- 将目标卡牌以里侧表示从卡组除外
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
