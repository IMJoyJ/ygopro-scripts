--サーマル・ジェネクス
-- 效果：
-- 「次世代控制员」＋调整以外的炎属性怪兽1只以上
-- ①：这张卡的攻击力上升自己墓地的炎属性怪兽数量×200。
-- ②：这张卡战斗破坏对方怪兽的场合发动。给与对方为自己墓地的「次世代」怪兽数量×200伤害。
function c6588580.initial_effect(c)
	-- 将「次世代控制员」添加为该怪兽的特定同调素材代码列表
	aux.AddMaterialCodeList(c,68505803)
	-- 添加同调召唤手续：以「次世代控制员」为调整，调整以外的炎属性怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,68505803),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_FIRE),1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升自己墓地的炎属性怪兽数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c6588580.val)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽的场合发动。给与对方为自己墓地的「次世代」怪兽数量×200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6588580,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCondition(c6588580.damcon)
	e2:SetTarget(c6588580.damtg)
	e2:SetOperation(c6588580.damop)
	c:RegisterEffect(e2)
end
-- 计算攻击力上升值的辅助函数
function c6588580.val(e,c)
	-- 获取自己墓地的炎属性怪兽数量并乘以200
	return Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_FIRE)*200
end
-- 判断此卡是否在战斗中，且战斗破坏的卡是否为怪兽
function c6588580.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 伤害效果的发动准备，设置目标玩家为对方并注册伤害操作信息
function c6588580.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁的操作信息为给与对方玩家伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 伤害效果的执行函数，计算伤害并给与对方
function c6588580.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算自己墓地中「次世代」怪兽的数量并乘以200
	local d=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x2)*200
	-- 给与目标玩家相应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
