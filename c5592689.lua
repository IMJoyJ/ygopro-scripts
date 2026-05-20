--サクリファイス・ロータス
-- 效果：
-- 自己的结束阶段时这张卡在墓地存在，自己场上没有魔法·陷阱卡存在的场合，可以在自己场上表侧攻击表示特殊召唤。这张卡在场上表侧表示存在的场合，每次自己的准备阶段控制者受到1000分伤害。
function c5592689.initial_effect(c)
	-- 自己的结束阶段时这张卡在墓地存在，自己场上没有魔法·陷阱卡存在的场合，可以在自己场上表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5592689,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(c5592689.sscon)
	e1:SetTarget(c5592689.sstg)
	e1:SetOperation(c5592689.ssop)
	c:RegisterEffect(e1)
	-- 这张卡在场上表侧表示存在的场合，每次自己的准备阶段控制者受到1000分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5592689,1))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c5592689.dmcon)
	e2:SetTarget(c5592689.dmtg)
	e2:SetOperation(c5592689.dmop)
	c:RegisterEffect(e2)
end
-- 过滤函数：过滤场上的魔法·陷阱卡
function c5592689.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 特殊召唤效果的发动条件函数
function c5592689.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的结束阶段，且自己场上没有魔法·陷阱卡存在
	return tp==Duel.GetTurnPlayer() and not Duel.IsExistingMatchingCard(c5592689.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤效果的发动准备与合法性检测函数
function c5592689.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置连锁信息，表明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行函数
function c5592689.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，检查此卡是否仍与效果相关，且自己场上依然没有魔法·陷阱卡
	if e:GetHandler():IsRelateToEffect(e) and not Duel.IsExistingMatchingCard(c5592689.filter,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 将此卡在自己场上表侧攻击表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- 伤害效果的发动条件函数
function c5592689.dmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的准备阶段
	return Duel.GetTurnPlayer()==tp
end
-- 伤害效果的发动准备与目标设定函数
function c5592689.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置受到伤害的目标玩家为当前玩家（控制者）
	Duel.SetTargetPlayer(tp)
	-- 设置伤害数值参数为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁信息，表明此效果包含对控制者造成1000点伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 伤害效果的执行函数
function c5592689.dmop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果对目标玩家造成相应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
