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
-- 效果条件函数：检测效果持有者的控制者手牌数量是否≥1（即存在手卡时，该卡不能攻击）。
function c45531624.atcon(e)
	-- 判断效果持有者的控制者手牌数量是否大于等于1，作为不能攻击的发动条件。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)>=1
end
-- 特殊召唤用过滤函数：选择手牌中属于「精灵剑士」系列（0xe4）且能够被特殊召唤的怪兽。
function c45531624.spfilter(c,e,tp)
	return c:IsSetCard(0xe4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件判断函数：检查自己主要怪兽区是否有空位，且手牌中存在至少1只符合条件的「精灵剑士」怪兽，满足才能发动。
function c45531624.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用空格，作为发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查手牌中是否存在至少1张满足spfilter条件的「精灵剑士」怪兽，若有才可发动。
		and Duel.IsExistingMatchingCard(c45531624.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：将本效果登记为特殊召唤，预计从手牌特殊召唤1只怪兽（数量1，对象不特定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：实际执行特殊召唤。先确认场地空格，让玩家从手牌选择1只符合条件的「精灵剑士」怪兽，然后将其表侧表示特殊召唤到自己场上。
function c45531624.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己场上没有可用的怪兽区域，则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送“请选择要特殊召唤的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1张满足spfilter条件的「精灵剑士」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c45531624.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到召唤者自己场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 抽卡效果的发动条件函数：本卡给予对方战斗伤害，且攻击怪兽正是本卡自身。
function c45531624.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断受到战斗伤害的是对方玩家，且本次战斗的攻击怪兽是效果持有者自身，满足才可发动。
	return ep~=tp and Duel.GetAttacker()==e:GetHandler()
end
-- 计数过滤函数：统计自己场上表侧表示且属于「精灵剑士」系列（0xe4）的怪兽。
function c45531624.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe4)
end
-- 抽卡效果的目标/发动条件函数：统计自己场上符合条件的「精灵剑士」怪兽数量；检查其大于0且自己可抽那么多张卡；将抽卡玩家设为自己，并登记抽卡操作信息。
function c45531624.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己场上表侧表示的「精灵剑士」怪兽数量，作为抽卡张数。
	local ct=Duel.GetMatchingGroupCount(c45531624.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 发动合法性检查：场上存在至少1只符合条件的「精灵剑士」怪兽，且自己可以抽取对应数量的卡。
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 将本次效果的抽卡玩家设置为效果控制者自己。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息：本效果为抽卡效果，目标玩家为tp，预计抽ct张卡（具体张数在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 抽卡效果的处理函数：获取目标玩家，再次统计场上「精灵剑士」数量，然后让该玩家抽取对应数量的卡。
function c45531624.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中登记的目标玩家，即需要抽卡的玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次统计自己场上表侧表示的「精灵剑士」怪兽数量作为实际抽卡张数（效果处理时确定）。
	local d=Duel.GetMatchingGroupCount(c45531624.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
