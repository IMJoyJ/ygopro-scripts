--仕込み爆弾
-- 效果：
-- ①：给与对方为对方场上的卡数量×300伤害。
-- ②：场上的这张卡被对方破坏送去墓地的场合发动。给与对方1000伤害。
function c18252559.initial_effect(c)
	-- ①：给与对方为对方场上的卡数量×300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c18252559.target)
	e1:SetOperation(c18252559.activate)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被对方破坏送去墓地的场合发动。给与对方1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c18252559.damcon)
	e2:SetTarget(c18252559.damtg)
	e2:SetOperation(c18252559.damop)
	c:RegisterEffect(e2)
end
-- 效果作用：计算对方场上卡的数量并设置伤害值
function c18252559.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：对方场上存在卡牌
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)>0 end
	-- 设置连锁目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 计算伤害值为对方场上卡数量乘以300
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)*300
	-- 设置操作信息为对对方造成指定伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果作用：执行①效果的伤害处理
function c18252559.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次计算伤害值为对方场上卡数量乘以300
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)*300
	-- 对目标玩家造成计算出的伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
-- 效果作用：判断是否满足②效果的发动条件
function c18252559.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 效果作用：设置②效果的目标和伤害值
function c18252559.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁目标参数为1000
	Duel.SetTargetParam(1000)
	-- 设置操作信息为对对方造成1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果作用：执行②效果的伤害处理
function c18252559.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
