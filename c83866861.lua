--デストーイ・マッド・キマイラ
-- 效果：
-- 「魔玩具」怪兽×3
-- 这张卡不用融合召唤不能特殊召唤。「魔玩具·狂乱奇美拉」的②的效果1回合只能使用1次。
-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ②：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽的攻击力变成一半在自己场上特殊召唤。
-- ③：这张卡的攻击力上升原本持有者是对方的自己场上的怪兽数量×300。
function c83866861.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为3只「魔玩具」怪兽
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xad),3,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制只能通过融合召唤来特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(c83866861.actcon)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽的攻击力变成一半在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCountLimit(1,83866861)
	e3:SetCondition(c83866861.spcon)
	e3:SetTarget(c83866861.sptg)
	e3:SetOperation(c83866861.spop)
	c:RegisterEffect(e3)
	-- ③：这张卡的攻击力上升原本持有者是对方的自己场上的怪兽数量×300。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c83866861.atkval)
	c:RegisterEffect(e4)
end
-- 战斗时封锁对方效果发动的条件函数
function c83866861.actcon(e)
	-- 判断自身是否正在进行战斗（作为攻击方或被攻击方）
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- 判断是否满足战斗破坏对方怪兽并送去墓地的发动条件
function c83866861.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsFaceup() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 战斗破坏对方怪兽送去墓地时发动效果的目标选择与发动准备
function c83866861.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将战斗破坏的怪兽设为效果处理的对象
	Duel.SetTargetCard(bc)
	-- 设置效果处理信息为特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 战斗破坏对方怪兽送去墓地时发动效果的效果处理（攻击力减半特殊召唤）
function c83866861.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果处理对象的战斗破坏怪兽
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetAttack()
	-- 若目标怪兽仍符合效果条件，则尝试将其以表侧表示特殊召唤到自己场上
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽的攻击力变成一半
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 过滤原本持有者是对方的怪兽
function c83866861.atkfilter(c,p)
	return c:GetOwner()==p
end
-- 计算攻击力上升的数值
function c83866861.atkval(e,c)
	local tp=c:GetControler()
	-- 获取自己场上原本持有者是对方的怪兽数量并乘以300
	return Duel.GetMatchingGroupCount(c83866861.atkfilter,tp,LOCATION_MZONE,0,nil,1-tp)*300
end
