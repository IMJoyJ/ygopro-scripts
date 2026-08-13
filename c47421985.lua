--ハイドロ・ジェネクス
-- 效果：
-- 「次世代控制员」＋调整以外的水属性怪兽1只以上
-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。自己基本分回复那只怪兽的原本攻击力的数值。
function c47421985.initial_effect(c)
	-- 声明此卡的素材卡名列表中包含「次世代控制员」（卡号68505803），用于同调素材的规则识别与校验。
	aux.AddMaterialCodeList(c,68505803)
	-- 为此卡添加同调召唤手续：调整必须是「次世代控制员」，调整以外必须为水属性怪兽，数量为1只以上。
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
-- 诱发效果的条件判定：确认进行战斗的这张卡仍与战斗相关且表侧表示，取被战斗破坏送入墓地的对方怪兽，记录其攻击力作为回复数值，并判定该怪兽确在墓地且为怪兽。
function c47421985.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 默认取本次战斗的攻击目标（防守怪兽），作为可能被战斗破坏的怪兽。
	local t=Duel.GetAttackTarget()
	-- 若战斗事件参数ev为1，则被战斗破坏的怪兽是攻击怪兽（即我方怪兽被攻击后反杀对方攻击者），因此将对象改为攻击怪兽。
	if ev==1 then t=Duel.GetAttacker() end
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	e:SetLabel(t:GetAttack())
	return t:IsLocation(LOCATION_GRAVE) and t:IsType(TYPE_MONSTER)
end
-- 效果发动时的目标设定：无需选择卡牌，只需将连锁的目标玩家设为自己、参数设为已记录的回复数值，并声明此连锁为回复效果，供后续处理与连锁检测使用。
function c47421985.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为效果发动者（自己），即此次回复LP的对象。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为之前保存的怪兽攻击力数值，作为实际回复的LP数值。
	Duel.SetTargetParam(e:GetLabel())
	-- 设置当前连锁的操作信息，声明这是一个回复LP的效果，目标玩家为tp、回复数值为e:GetLabel()，供其他卡进行效果互动或时点检测。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
end
-- 效果处理阶段：读取连锁中保存的对象玩家和回复数值，并执行基本分回复。
function c47421985.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家（回复者）和对象参数（回复数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）使玩家p回复d点基本分。
	Duel.Recover(p,d,REASON_EFFECT)
end
