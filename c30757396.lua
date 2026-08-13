--ブラッド・メフィスト
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 对方的准备阶段时，可以给与对方基本分对方场上存在的卡每1张300分伤害。此外，对方把魔法·陷阱卡盖放时，给与对方基本分300分伤害。
function c30757396.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整怪兽（不限）+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对方的准备阶段时，可以给与对方基本分对方场上存在的卡每1张300分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30757396,0))  --"给与对方伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c30757396.damcon)
	e1:SetTarget(c30757396.damtg)
	e1:SetOperation(c30757396.damop)
	c:RegisterEffect(e1)
	-- 此外，对方把魔法·陷阱卡盖放时，给与对方基本分300分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30757396,0))  --"给与对方伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SSET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c30757396.damcon2)
	e2:SetTarget(c30757396.damtg2)
	e2:SetOperation(c30757396.damop2)
	c:RegisterEffect(e2)
end
-- 定义第一个效果（对方准备阶段伤害）的发动条件函数
function c30757396.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果发动条件：当前不是这张卡的控制者的回合，即对方的准备阶段
	return tp~=Duel.GetTurnPlayer()
end
-- 定义第一个效果（对方准备阶段伤害）的目标函数，设置伤害对象与伤害信息
function c30757396.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计对方场上存在的卡片数量，作为伤害计算依据
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if chk==0 then return ct>0 end
	-- 将效果对象玩家设为对方
	Duel.SetTargetPlayer(1-tp)
	-- 登记效果处理时将给对方造成 ct×300 点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- 定义第一个效果（对方准备阶段伤害）的处理函数，实际造成伤害
function c30757396.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中记录的对象玩家（伤害对象）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果处理时重新统计对方场上卡片数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 给对象玩家造成 ct×300 点效果伤害
	Duel.Damage(p,ct*300,REASON_EFFECT)
end
-- 定义第二个效果（对方盖放魔陷时伤害）的发动条件函数
function c30757396.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 定义第二个效果（对方盖放魔陷时伤害）的目标函数，设置对象玩家和伤害参数
function c30757396.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果对象玩家设为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害参数为300
	Duel.SetTargetParam(300)
	-- 登记效果处理时将给对方造成300点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 定义第二个效果（对方盖放魔陷时伤害）的处理函数，实际造成伤害
function c30757396.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中记录的对象玩家和伤害参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给对象玩家造成 d 点效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
