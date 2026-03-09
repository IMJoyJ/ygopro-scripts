--ハイドロ・ジェネクス
-- 效果：
-- 「次世代控制员」＋调整以外的水属性怪兽1只以上
-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。自己基本分回复那只怪兽的原本攻击力的数值。
function c47421985.initial_effect(c)
	-- 为该怪兽添加融合召唤所需的素材代码列表，允许使用卡牌代码68505803作为素材
	aux.AddMaterialCodeList(c,68505803)
	-- 设置该怪兽的同调召唤手续，要求1只调整且为水属性的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,68505803),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WATER),1)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。自己基本分回复那只怪兽的原本攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47421985,0))  --"回复LP"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCondition(c47421985.reccon)
	e1:SetTarget(c47421985.rectg)
	e1:SetOperation(c47421985.recop)
	c:RegisterEffect(e1)
end
-- 判断是否满足效果发动条件，检查攻击怪兽是否在墓地且为怪兽类型，并记录其攻击力
function c47421985.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗中被攻击的怪兽
	local t=Duel.GetAttackTarget()
	-- 若ev等于1，则获取当前攻击的怪兽（用于处理攻击方向）
	if ev==1 then t=Duel.GetAttacker() end
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	e:SetLabel(t:GetAttack())
	return t:IsLocation(LOCATION_GRAVE) and t:IsType(TYPE_MONSTER)
end
-- 设置效果的目标玩家和参数，准备执行回复LP操作
function c47421985.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前处理连锁的效果对象玩家设为处理该效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 将当前处理连锁的效果对象参数设为之前记录的攻击力值
	Duel.SetTargetParam(e:GetLabel())
	-- 设置连锁的操作信息，指定本次效果为回复LP效果，并设定回复数值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
end
-- 执行效果操作，根据连锁信息中的玩家和数值进行LP回复
function c47421985.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前处理的连锁中获取目标玩家和目标参数（即攻击力）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使指定玩家回复对应数值的LP
	Duel.Recover(p,d,REASON_EFFECT)
end
