--オオヤツ・ツマムヒメ
-- 效果：
-- ①：1回合1次，场上的这张卡成为攻击·效果的对象时才能发动。在自己场上把1只「点心衍生物」（植物族·光·1星·攻/守800）特殊召唤。
-- ②：1回合1次，对方把怪兽特殊召唤之际，把自己场上1只通常怪兽解放才能发动。那次特殊召唤无效，那些怪兽破坏。
local s,id,o=GetID()
-- 为这张卡注册全部效果：①效果包含两个触发变体（成为效果对象时、成为攻击对象时），均用于特殊召唤「点心衍生物」；②效果在对方特殊召唤怪兽之际，通过解放自己场上1只通常怪兽为代价，使那次特殊召唤无效并破坏那些怪兽。
function s.initial_effect(c)
	-- ①：1回合1次，场上的这张卡成为效果的对象时才能发动。在自己场上把1只「点心衍生物」（植物族·光·1星·攻/守800）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(s.tkecon)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCondition(s.tkbcon)
	c:RegisterEffect(e2)
	-- ②：1回合1次，对方把怪兽特殊召唤之际，把自己场上1只通常怪兽解放才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
-- s.tkecon为①效果“成为效果对象时”的触发条件：判定当前连锁的效果是取对象效果，且其对象中包含这张卡。
function s.tkecon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果所取的对象的卡片组，用于后续判断本卡是否在对象中。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(e:GetHandler())
end
-- s.tkbcon为①效果“成为攻击对象时”的触发条件：判定这张卡当前被选为攻击对象。
function s.tkbcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较当前攻击对象是否等于这张卡自身（e:GetHandler()为效果持有者）。
	return Duel.GetAttackTarget()==e:GetHandler()
end
-- s.tktg为①效果发动时的合法性检查：确认自己主要怪兽区有空位，且玩家能够特殊召唤「点心衍生物」。
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有空余区域（token特殊召唤需要空位）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查当前玩家是否允许特殊召唤指定的「点心衍生物」token（卡号id+o，植物族·光·1星·攻/守800）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,800,800,1,RACE_PLANT,ATTRIBUTE_LIGHT) end
	-- 向系统登记本次操作包含“衍生物生成”分类，用于满足相关效果检测（如不能特殊召唤token等）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 向系统登记本次操作包含“特殊召唤”分类，用于相关效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- s.tkop中效果处理前的条件复核：如果主要怪兽区没有空位或不能特殊召唤「点心衍生物」，则直接终止处理。
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区仍有空位，否则无法特殊召唤衍生物。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 效果处理时再次确认仍可特殊召唤该衍生物，若因其他效果导致不能特殊召唤则本次效果不处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,800,800,1,RACE_PLANT,ATTRIBUTE_LIGHT) then return end
	-- 创建1只「点心衍生物」token，其卡号使用脚本内衍生卡编号id+o，种族植物、属性光、等级1、攻击/守备800。
	local tk=Duel.CreateToken(tp,id+o)
	-- 将刚才创建的「点心衍生物」以表侧攻击表示特殊召唤到发动者tp的场上。
	Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP)
end
-- s.negcon为②效果的触发条件：当前不在连锁处理中（特殊召唤之际为不入连锁的时点），且发动特殊召唤的玩家是对方。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前连锁数为0（不是连锁处理中），并且特殊召唤的玩家ep是对方（1-tp）。
	return Duel.GetCurrentChain()==0 and ep==1-tp
end
-- s.negcost为②效果的发动代价：解放自己场上1只通常怪兽。先检查是否存在可解放的通常怪兽，再选择并解放。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上存在至少1只通常怪兽可以解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_NORMAL) end
	-- 从自己场上选择1只通常怪兽作为解放对象（选择1张满足通常怪兽类型的卡）。
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_NORMAL)
	-- 将选择的通常怪兽解放，作为发动本效果的代价。
	Duel.Release(g,REASON_COST)
end
-- s.negtg为②效果的目标设定：不取对象，仅登记操作信息，将这次特殊召唤的怪兽群eg作为无效和破坏的对象。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本次操作包含“特殊召唤无效”分类，对象为这次特殊召唤的怪兽群eg，数量为eg的数量。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	-- 向系统登记本次操作包含“破坏”分类，对象同样为这次特殊召唤的怪兽群eg，数量为eg的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
-- s.negop为②效果的解决处理：执行特殊召唤无效并破坏那些怪兽。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这次特殊召唤的怪兽们的特殊召唤无效化（即那次特殊召唤被无效）。
	Duel.NegateSummon(eg)
	-- 将那些（已被无效特殊召唤的）怪兽破坏，送去墓地。
	Duel.Destroy(eg,REASON_EFFECT)
end
