--DDD運命王ゼロ・ラプラス
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己的额外卡组选「DDD 命运王 零·拉普拉斯」以外的1只表侧表示的「DDD」灵摆怪兽加入手卡。
-- 【怪兽效果】
-- ①：这张卡可以把自己场上1只「DDD」怪兽解放从手卡特殊召唤。
-- ②：这张卡和对方怪兽进行战斗的伤害计算前才能发动。这张卡的攻击力直到伤害步骤结束时变成那只对方怪兽的原本攻击力的2倍。
-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ④：这张卡1回合只有1次不会被战斗破坏。那个时候，自己受到的战斗伤害变成0。
function c21686473.initial_effect(c)
	-- 为这张卡注册灵摆怪兽属性，使其能够作为灵摆卡放置在灵摆区并进行灵摆召唤（含灵摆卡发动）。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。从自己的额外卡组选「DDD 命运王 零·拉普拉斯」以外的1只表侧表示的「DDD」灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21686473,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,21686473)
	e1:SetTarget(c21686473.thtg)
	e1:SetOperation(c21686473.thop)
	c:RegisterEffect(e1)
	-- ①：这张卡可以把自己场上1只「DDD」怪兽解放从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c21686473.hspcon)
	e2:SetTarget(c21686473.hsptg)
	e2:SetOperation(c21686473.hspop)
	c:RegisterEffect(e2)
	-- ②：这张卡和对方怪兽进行战斗的伤害计算前才能发动。这张卡的攻击力直到伤害步骤结束时变成那只对方怪兽的原本攻击力的2倍。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21686473,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetCondition(c21686473.atkcon)
	e3:SetOperation(c21686473.atkop)
	c:RegisterEffect(e3)
	-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
	-- ④：这张卡1回合只有1次不会被战斗破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e5:SetCountLimit(1)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(c21686473.valcon)
	c:RegisterEffect(e5)
	-- 那个时候，自己受到的战斗伤害变成0。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e6:SetValue(c21686473.damlimit)
	c:RegisterEffect(e6)
end
-- 定义灵摆效果检索额外卡组时的过滤条件：表侧表示的「DDD」灵摆怪兽，且不是本卡，且能够加入手卡。
function c21686473.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10af) and c:IsType(TYPE_PENDULUM) and not c:IsCode(21686473) and c:IsAbleToHand()
end
-- 灵摆效果的发动条件和操作信息登记：主要阶段且额外卡组存在符合条件的『DDD』灵摆怪兽时才可发动，并登记为从额外卡组将1张卡加入手卡。
function c21686473.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：额外卡组中是否存在至少1张满足thfilter条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c21686473.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：该效果属于『加入手卡』分类，预定从持有者tp的额外卡组处理1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 实际处理：选择额外卡组中1张符合条件的『DDD』灵摆怪兽加入手卡，并让对方确认。
function c21686473.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的额外卡组选择1张满足thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c21686473.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因（REASON_EFFECT）加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手卡的卡，保证信息对双方公开。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义解放候选的过滤条件：该卡是「DDD」怪兽，解放后己方有怪兽区空格；并且该卡为自己控制或表侧表示（以保证可解放）。
function c21686473.hspfilter(c,tp)
	return c:IsSetCard(0x10af)
		-- 检查解放该候选卡后tp仍有可用怪兽区，且候选卡是tp控制的怪兽或表侧表示，满足作为解放对象的要求。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 手卡特殊召唤规则效果的发动条件：若存在可解放的「DDD」怪兽（且满足怪兽区空格等条件），则允许从手卡规则特殊召唤。
function c21686473.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查tp场上/手卡（实际用于场上）是否存在至少1只满足hspfilter条件的可解放「DDD」怪兽，作为特殊召唤手续的解放来源。
	return Duel.CheckReleaseGroupEx(tp,c21686473.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 选择要解放的怪兽：在过滤出的可解放DDD怪兽中选择1张，保存至效果LabelObject，供后续处理使用。
function c21686473.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取tp可解放（非上级召唤用）的怪兽组，并过滤出满足hspfilter的「DDD」怪兽。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c21686473.hspfilter,nil,tp)
	-- 显示选择提示，提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的解放处理：从LabelObject取出之前选择的怪兽并解放。
function c21686473.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤规则原因（REASON_SPSUMMON）解放该怪兽。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 攻击力变化效果（②）的发动条件：这张卡与对方怪兽进行伤害计算前，对方怪兽表侧且与战斗相关，且这张卡当前攻击力不等于对方原本攻击力的2倍。
function c21686473.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:GetBaseAttack()*2~=c:GetAttack()
end
-- 实际处理：将这张卡的攻击力变成对方怪兽原本攻击力的2倍，效果持续到伤害步骤结束。
function c21686473.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() then
		-- 这张卡的攻击力直到伤害步骤结束时变成那只对方怪兽的原本攻击力的2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(bc:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
-- 战破耐性计数效果的判定函数：当这张卡将要被战斗破坏时，返回true以发动『1回合1次不会被战斗破坏』，并记录本回合已使用过该效果。
function c21686473.valcon(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		e:GetHandler():RegisterFlagEffect(21686473,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		return true
	else return false end
end
-- 战斗伤害变为0效果的判定函数：本回合尚未使用过战破耐性时返回1，使本次自己受到的战斗伤害变成0；已使用过则返回0。
function c21686473.damlimit(e,c)
	if e:GetHandler():GetFlagEffect(21686473)==0 then
		return 1
	else return 0 end
end
