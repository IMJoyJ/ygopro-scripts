--サベージ・コロシアム
-- 效果：
-- 场上存在的怪兽进行攻击的场合，那只怪兽的控制者在伤害步骤结束时回复300基本分。只要这张卡在场上存在，可以攻击的怪兽必须作出攻击。结束阶段时，回合玩家的场上表侧攻击表示存在的没有攻击宣言的怪兽全部破坏。
function c32391631.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上存在的怪兽进行攻击的场合，那只怪兽的控制者在伤害步骤结束时回复300基本分。
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
	-- 只要这张卡在场上存在，可以攻击的怪兽必须作出攻击。
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
-- 伤害步骤结束时的触发条件：判定当前攻击的怪兽是否仍与本次战斗关联，只有仍有关联才处理回复效果。
function c32391631.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否仍与本次战斗关联，防止攻击怪兽已离场时仍错误触发回复。
	return Duel.GetAttacker():IsRelateToBattle()
end
-- 设置回复效果的操作信息：将回复对象玩家设为当前回合玩家，回复数值设为300，并登记回复类操作信息。
function c32391631.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把当前连锁的对象玩家设为当前回合玩家（即攻击怪兽的控制者）。
	Duel.SetTargetPlayer(Duel.GetTurnPlayer())
	-- 把当前连锁的对象参数设为300，表示要回复的LP数值。
	Duel.SetTargetParam(300)
	-- 登记回复效果的操作信息：目标玩家为当前回合玩家，回复量为300，用于效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,Duel.GetTurnPlayer(),300)
end
-- 回复效果的处理：确认攻击怪兽仍与本次战斗关联后，从连锁信息中取得目标玩家和回复量，并执行回复300LP。
function c32391631.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 若攻击怪兽已经不在场上或与本次战斗无关，则不进行回复处理。
	if not Duel.GetAttacker():IsRelateToBattle() then return end
	-- 取出本次连锁中保存的目标玩家和回复参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让目标玩家回复对应的LP数值。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 筛选出当前回合玩家场上表侧攻击表示且本回合没有进行过攻击宣言的怪兽。
function c32391631.desfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:GetAttackAnnouncedCount()==0
end
-- 破坏效果的目标设定：无条件可发动，登记将满足条件的怪兽全部破坏的操作信息。
function c32391631.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前回合玩家场上满足条件（表侧攻击且未攻击宣言）的怪兽群，并排除效果所属卡自身。
	local g=Duel.GetMatchingGroup(c32391631.desfilter,Duel.GetTurnPlayer(),LOCATION_MZONE,0,e:GetHandler())
	-- 将待破坏的怪兽组及数量写入操作信息，表明该效果预定破坏这些怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理：按条件重新筛选出当前应破坏的怪兽，并将其全部破坏。
function c32391631.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取当前回合玩家场上表侧攻击且未攻击宣言的怪兽群（排除效果发动者自身）。
	local g=Duel.GetMatchingGroup(c32391631.desfilter,Duel.GetTurnPlayer(),LOCATION_MZONE,0,aux.ExceptThisCard(e))
	-- 以效果原因将这些怪兽全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
