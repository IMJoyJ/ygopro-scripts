--サベージ・コロシアム
-- 效果：
-- 场上存在的怪兽进行攻击的场合，那只怪兽的控制者在伤害步骤结束时回复300基本分。只要这张卡在场上存在，可以攻击的怪兽必须作出攻击。结束阶段时，回合玩家的场上表侧攻击表示存在的没有攻击宣言的怪兽全部破坏。
function c32391631.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，可以攻击的怪兽必须作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32391631,0))  --"LP回复"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c32391631.reccon)
	e2:SetTarget(c32391631.rectg)
	e2:SetOperation(c32391631.recop)
	c:RegisterEffect(e2)
	-- 场上存在的怪兽进行攻击的场合，那只怪兽的控制者在伤害步骤结束时回复300基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_MUST_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	c:RegisterEffect(e3)
	-- 结束阶段时，回合玩家的场上表侧攻击表示存在的没有攻击宣言的怪兽全部破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(32391631,1))  --"破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetTarget(c32391631.destg)
	e5:SetOperation(c32391631.desop)
	c:RegisterEffect(e5)
end
-- 判断攻击怪兽是否参与了战斗
function c32391631.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击怪兽必须参与了战斗
	return Duel.GetAttacker():IsRelateToBattle()
end
-- 设置LP回复效果的目标玩家和回复值
function c32391631.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前回合玩家
	Duel.SetTargetPlayer(Duel.GetTurnPlayer())
	-- 设置效果的目标参数为300
	Duel.SetTargetParam(300)
	-- 设置连锁操作信息为回复效果
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,Duel.GetTurnPlayer(),300)
end
-- 执行LP回复效果
function c32391631.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 若攻击怪兽未参与战斗则不执行效果
	if not Duel.GetAttacker():IsRelateToBattle() then return end
	-- 获取连锁中设置的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 破坏效果的过滤函数，筛选表侧攻击表示且未攻击宣言的怪兽
function c32391631.desfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:GetAttackAnnouncedCount()==0
end
-- 设置破坏效果的目标卡片组
function c32391631.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c32391631.desfilter,Duel.GetTurnPlayer(),LOCATION_MZONE,0,e:GetHandler())
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果
function c32391631.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽组（排除自身）
	local g=Duel.GetMatchingGroup(c32391631.desfilter,Duel.GetTurnPlayer(),LOCATION_MZONE,0,aux.ExceptThisCard(e))
	-- 将目标怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
