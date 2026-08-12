--ギラギランサー
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。只要这张卡在场上表侧表示存在，自己在每次结束阶段受到500分伤害。
function c76436988.initial_effect(c)
	-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c76436988.spcon)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，自己在每次结束阶段受到500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76436988,0))  --"500伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c76436988.damtg)
	e2:SetOperation(c76436988.damop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件判断：判断自己场上没有怪兽、对方场上有怪兽，且自己场上有可用的怪兽区域
function c76436988.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否大于0
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 结束阶段伤害效果的发动准备：设置受到伤害的玩家为自己，伤害数值为500，并向系统申报伤害操作信息
function c76436988.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为500
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息为：对玩家tp造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,500)
end
-- 结束阶段伤害效果的处理：若此卡仍在场上表侧表示存在，则获取目标玩家和伤害值，并给予该玩家对应的效果伤害
function c76436988.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 获取当前连锁中设定的目标玩家和伤害参数
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 对目标玩家造成指定数值的效果伤害
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
