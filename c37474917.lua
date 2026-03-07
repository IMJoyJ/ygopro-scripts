--カタパルト・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 把自己场上存在的1只名字带有「废品」的怪兽解放发动。给与对方基本分解放的怪兽的原本攻击力数值的伤害。这个效果1回合只能使用1次。
function c37474917.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 调整＋调整以外的怪兽1只以上
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37474917,0))  --"伤害"
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c37474917.cost)
	e1:SetTarget(c37474917.target)
	e1:SetOperation(c37474917.operation)
	c:RegisterEffect(e1)
end
-- 支付效果代价，解放1只名字带有「废品」的怪兽
function c37474917.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x43) end
	-- 选择1只名字带有「废品」的怪兽进行解放
	local sg=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x43)
	local atk=sg:GetFirst():GetTextAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	-- 实际执行解放操作
	Duel.Release(sg,REASON_COST)
end
-- 设置效果目标，确定伤害对象和伤害值
function c37474917.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁效果的目标参数为解放怪兽的攻击力
	Duel.SetTargetParam(e:GetLabel())
	-- 设置连锁效果的操作信息为造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 执行效果操作，对对方造成伤害
function c37474917.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
