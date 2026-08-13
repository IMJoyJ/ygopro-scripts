--隠し砦 ストロング・ホールド
-- 效果：
-- ①：这张卡发动后变成持有以下效果的效果怪兽（机械族·地·4星·攻0/守2000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ●这张卡的攻击力上升自己场上的「光之黄金柜」以及有那个卡名记述的怪兽数量×1000。
-- ●1回合1次，自己场上有「光之黄金柜」存在的场合，对方怪兽的攻击宣言时才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 注册本卡的全部效果：①发动后变成陷阱怪兽并特殊召唤；②作为怪兽时攻击力上升；③1回合1次对方怪兽攻击宣言且自己场上有「光之黄金柜」时破坏该怪兽。
function s.initial_effect(c)
	-- 将卡号79791878（光之黄金柜）登记为这张卡卡名记述的卡，使『有那个卡名记述的怪兽』的判定生效。
	aux.AddCodeList(c,79791878)
	-- ①：这张卡发动后变成持有以下效果的效果怪兽（机械族·地·4星·攻0/守2000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ●这张卡的攻击力上升自己场上的「光之黄金柜」以及有那个卡名记述的怪兽数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- ●1回合1次，自己场上有「光之黄金柜」存在的场合，对方怪兽的攻击宣言时才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 效果发动时的合法性检查：我方主要怪兽区有空位，且我方能够将这张卡作为机械族·地·4星·攻0/守2000的效果陷阱怪兽特殊召唤。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区域是否有空位（用于把这张卡特殊召唤到怪兽区）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且当前玩家能够特殊召唤这张卡为机械族·地·4星·攻0/守2000的陷阱怪兽（效果·陷阱怪兽）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置操作信息：本连锁将进行特殊召唤，对象为这张卡自身，数量为1张，供系统检测相关时点和限制使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若仍能特殊召唤，则将这张卡变成怪兽卡（效果·陷阱怪兽），并正面表示特殊召唤到我方主要怪兽区域。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认能否特殊召唤该陷阱怪兽，若不能则直接终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,4,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 以自身效果（SUMMON_VALUE_SELF）将这张卡正面表示特殊召唤到我的主要怪兽区。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 定义攻击力上升计数的筛选条件：自己场上表侧表示的「光之黄金柜」本身，以及效果文本中记述了「光之黄金柜」且位于怪兽区域的表侧表示怪兽。
function s.atkfilter(c)
	-- 卡名是79791878且表侧表示；或卡名记述了79791878且位于怪兽区域并表侧表示。
	return (c:IsCode(79791878) or (aux.IsCodeListed(c,79791878) and c:IsLocation(LOCATION_MZONE))) and c:IsFaceup()
end
-- 攻击力上升效果仅当这张卡以自身效果特殊召唤成怪兽（陷阱怪兽）时适用。
function s.atkcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 计算这张卡的攻击力上升值：统计自己场上符合条件的「光之黄金柜」或记述了该卡名的怪兽数量，每张上升1000攻击力。
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	-- 返回符合条件的卡的数量乘以1000，作为攻击力上升数值。
	return Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_ONFIELD,0,nil)*1000
end
-- 定义『自己场上有光之黄金柜』的判定过滤器：卡名为79791878且表侧表示。
function s.filter(c)
	return c:IsCode(79791878) and c:IsFaceup()
end
-- 破坏效果的发动条件：对方怪兽攻击宣言时，自己场上有表侧表示的「光之黄金柜」，且这张卡是以自身效果特殊召唤成的怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击者是对方怪兽，且自己场上有表侧表示的「光之黄金柜」。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
		and e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 破坏效果的目标选择：将攻击的对方怪兽设为对象；若该怪兽仍在场上，则登记为破坏对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得当前攻击宣言的怪兽，作为破坏候选对象。
	local tg=Duel.GetAttacker()
	if chk==0 then return tg:IsOnField() end
	-- 将攻击怪兽设为当前连锁的对象。
	Duel.SetTargetCard(tg)
	-- 登记操作信息：本效果将破坏该对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 效果处理：若对象怪兽仍与效果相关联，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁记录的对象怪兽（攻击怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
