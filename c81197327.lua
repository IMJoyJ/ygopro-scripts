--E・HERO スチーム・ヒーラー
-- 效果：
-- 「元素英雄 爆热女郎」＋「元素英雄 水泡侠」
-- 这张卡不用融合召唤不能特殊召唤。这张卡战斗破坏怪兽送去墓地时，自己基本分回复破坏的怪兽的原本攻击力的数值。
function c81197327.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置「元素英雄 爆热女郎」与「元素英雄 水泡侠」为融合素材
	aux.AddFusionProcCode2(c,58932615,79979666,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制特殊召唤条件为只能通过融合召唤进行特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏怪兽送去墓地时，自己基本分回复破坏的怪兽的原本攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81197327,0))  --"LP回复"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c81197327.reccon)
	e2:SetTarget(c81197327.rectg)
	e2:SetOperation(c81197327.recop)
	c:RegisterEffect(e2)
end
c81197327.material_setcode=0x8
-- 判断此卡是否与战斗相关，且被战斗破坏的怪兽是否已送去墓地
function c81197327.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 效果发动的目标处理，获取被破坏怪兽的原本攻击力并设定回复参数
function c81197327.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local rec=bc:GetBaseAttack()
	if rec<0 then rec=0 end
	-- 设置回复生命值的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复生命值的数值为被破坏怪兽的原本攻击力
	Duel.SetTargetParam(rec)
	-- 设置连锁的操作信息，表明该效果包含回复生命值的操作
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果处理的执行函数，执行回复生命值的操作
function c81197327.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复操作，使目标玩家回复对应的生命值
	Duel.Recover(p,d,REASON_EFFECT)
end
