--エルフの聖剣士
-- 效果：
-- 这张卡在规则上也当作「精灵剑士」卡使用。
-- ①：有自己手卡的场合，这张卡不能攻击。
-- ②：1回合1次，自己主要阶段才能发动。从手卡把1只「精灵剑士」怪兽特殊召唤。
-- ③：这张卡的攻击给与对方战斗伤害时才能发动。自己从卡组抽出自己场上的「精灵剑士」怪兽的数量。
function c45531624.initial_effect(c)
	-- ①：有自己手卡的场合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(c45531624.atcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。从手卡把1只「精灵剑士」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45531624,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c45531624.sptg)
	e2:SetOperation(c45531624.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击给与对方战斗伤害时才能发动。自己从卡组抽出自己场上的「精灵剑士」怪兽的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetDescription(aux.Stringid(45531624,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(c45531624.drcon)
	e3:SetTarget(c45531624.drtg)
	e3:SetOperation(c45531624.drop)
	c:RegisterEffect(e3)
end
-- 检查当前玩家手牌数量是否大于等于1
function c45531624.atcon(e)
	-- 检查当前玩家手牌数量是否大于等于1
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)>=1
end
-- 过滤函数，用于判断手牌中是否存在「精灵剑士」卡且可以特殊召唤
function c45531624.spfilter(c,e,tp)
	return c:IsSetCard(0xe4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件，检查是否有足够的召唤位置和满足条件的卡片
function c45531624.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的「精灵剑士」怪兽
		and Duel.IsExistingMatchingCard(c45531624.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理特殊召唤效果的发动，选择并特殊召唤符合条件的怪兽
function c45531624.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「精灵剑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c45531624.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为对方造成的战斗伤害且攻击怪兽为自身
function c45531624.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方造成的战斗伤害且攻击怪兽为自身
	return ep~=tp and Duel.GetAttacker()==e:GetHandler()
end
-- 过滤函数，用于判断场上是否存在「精灵剑士」怪兽且正面表示
function c45531624.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe4)
end
-- 设置抽卡效果的发动条件，计算场上「精灵剑士」怪兽数量并检查是否可以抽卡
function c45531624.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算场上「精灵剑士」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c45531624.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查是否可以抽卡
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置抽卡效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 处理抽卡效果的发动，根据场上「精灵剑士」怪兽数量进行抽卡
function c45531624.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算场上「精灵剑士」怪兽数量
	local d=Duel.GetMatchingGroupCount(c45531624.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 根据场上「精灵剑士」怪兽数量进行抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
