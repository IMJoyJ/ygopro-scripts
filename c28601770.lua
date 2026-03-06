--ミストデーモン
-- 效果：
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡的①的方法召唤的场合，结束阶段发动。这张卡破坏，自己受到1000伤害。
function c28601770.initial_effect(c)
	-- 注册一个召唤规则效果，允许此卡不解放作召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28601770,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c28601770.ntcon)
	e1:SetOperation(c28601770.ntop)
	c:RegisterEffect(e1)
end
-- 判断是否满足不解放作召唤的条件
function c28601770.ntcon(e,c,minc)
	if c==nil then return true end
	-- 满足条件：不需要解放，等级5以上，且场上存在可用区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 注册结束阶段触发效果，用于破坏自身并造成伤害
function c28601770.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 效果在结束阶段发动，破坏自身并给自己造成1000伤害
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
-- 设置效果的目标和处理信息
function c28601770.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将自身破坏的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置给自己造成1000伤害的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
-- 执行破坏并造成伤害的操作
function c28601770.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身存在且表侧表示，然后进行破坏
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 对自身控制者造成1000伤害
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end
