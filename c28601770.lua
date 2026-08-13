--ミストデーモン
-- 效果：
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡的①的方法召唤的场合，结束阶段发动。这张卡破坏，自己受到1000伤害。
function c28601770.initial_effect(c)
	-- ①：这张卡可以不用解放作召唤。②：这张卡的①的方法召唤的场合，结束阶段发动。这张卡破坏，自己受到1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28601770,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c28601770.ntcon)
	e1:SetOperation(c28601770.ntop)
	c:RegisterEffect(e1)
end
-- 该函数是①效果『不用解放作召唤』的召唤手续条件判定：c为nil时返回真用于规则询问；实际召唤需不解放（minc==0）、怪兽等级不低于5星，且控制者场上有空余的怪兽区域。
function c28601770.ntcon(e,c,minc)
	if c==nil then return true end
	-- 具体判定：minc==0（无解放）、c:IsLevelAbove(5)（5星以上）且Duel.GetLocationCount(...)>0（有可用的怪兽区域）。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 该函数在执行①的无解放召唤时被调用：为这张卡注册一个结束阶段必定发动的诱发效果，效果为破坏这张卡并对控制者造成1000伤害。
function c28601770.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- ②：这张卡的①的方法召唤的场合，结束阶段发动。这张卡破坏，自己受到1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28601770,1))  --"破坏并伤害"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(c28601770.destg)
	e1:SetOperation(c28601770.desop)
	e1:SetReset(RESET_EVENT+0xee0000)
	c:RegisterEffect(e1)
end
-- ②效果的发动判定与操作信息设置：合法时返回true，并设置本次操作信息——破坏这张卡（1张）和对自己造成1000伤害。
function c28601770.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果将破坏这张卡自身（数量1），使其他卡能正确对应这次破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次效果将对控制者tp造成1000点效果伤害，使其他卡能响应这次伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
-- ②效果的解决处理：若这张卡仍与效果关联且表侧表示，则将其用效果破坏；破坏成功时，对自己造成1000点伤害。
function c28601770.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡仍在场上且与效果关联，然后以效果破坏该卡；若实际破坏数量不为0则继续。
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 对这张卡的控制者tp造成1000点效果伤害。
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end
