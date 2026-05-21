--E-HERO マリシャス・デビル
-- 效果：
-- 「邪心英雄 恶刃魔」＋6星以上的恶魔族怪兽
-- 这张卡用「暗黑融合」的效果才能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，对方战斗阶段内，对方场上的全部怪兽变成表侧攻击表示，并在可以攻击的场合必须向这张卡作出攻击。
function c86676862.initial_effect(c)
	-- 将「暗黑融合」的卡片密码加入到此卡的关联卡片列表中
	aux.AddCodeList(c,94820406)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，素材为「邪心英雄 恶刃魔」和1只6星以上的恶魔族怪兽
	aux.AddFusionProcCodeFun(c,58554959,c86676862.ffilter,1,true,true)
	-- 这张卡用「暗黑融合」的效果才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定函数为暗黑融合限制函数
	e2:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，对方战斗阶段内，对方场上的全部怪兽变成表侧攻击表示
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_POSITION)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c86676862.poscon)
	e3:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e3)
	-- 并在可以攻击的场合必须向这张卡作出攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_MUST_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c86676862.poscon)
	e4:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e5:SetValue(c86676862.atklimit)
	c:RegisterEffect(e5)
end
c86676862.material_setcode=0x8
c86676862.dark_calling=true
-- 过滤融合素材中6星以上的恶魔族怪兽
function c86676862.ffilter(c)
	return c:IsRace(RACE_FIEND) and c:IsLevelAbove(6)
end
-- 定义对方战斗阶段的条件判断函数
function c86676862.poscon(e)
	-- 检查当前是否为对方回合且处于战斗阶段
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer()) and Duel.IsBattlePhase()
end
-- 限制对方怪兽攻击时必须选择这张卡作为攻击对象
function c86676862.atklimit(e,c)
	return c==e:GetHandler()
end
